import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:google_translate/components/google_translate.dart';
import 'package:google_translate/extensions/string_extension.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thelab/code/widgets/homescreen/build_record_button.dart';
import 'package:thelab/code/widgets/homescreen/lock_screen.dart';
import 'package:thelab/code/widgets/homescreen/recognize_content.dart';
import 'package:thelab/code/widgets/onboarding/onboarding_widget.dart';
import 'package:thelab/code/widgets/transcriptions/transcription_list.dart';
import 'package:thelab/pages/gallery_picker.dart';
import 'package:thelab/secret/Secret.dart';
import 'package:thelab/secret/SecretLoader.dart';

import 'audiorecorder/audio_recorder_platform.dart';
import 'bluetooth/BluetoothHandler.dart';

class Recorder extends StatefulWidget {
  final void Function(String path) onStop;
  final BluetoothHandler bluetoothHandler;

  const Recorder(
      {super.key, required this.onStop, required this.bluetoothHandler});

  @override
  State<Recorder> createState() => _RecorderState();
}

Future<String> getLanguageCodeFromSharedPreferences() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('lang') ?? 'en-US';
}

Future<String> getTranslateLanguageCodeFromSharedPreferences() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('translate_lang') ?? 'en-US';
}

Future<bool> getTranslateStateFromSharedPreferences() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool("Translate") ?? false;
}

class _RecorderState extends State<Recorder>
    with AudioRecorderMixin, WidgetsBindingObserver {
  int _recordDuration = 0;
  Timer? _timer;
  late final AudioRecorder _audioRecorder;
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Amplitude? _amplitude;
  String text = "";
  String transcription = "";
  String translatedText = "";
  late final BluetoothHandler _bluetoothHandler;
  late bool _isLocked;
  late bool _showSavedIcon;

  late bool _isVisionXReady;
  late bool _isVisionXConnected;

  @override
  void initState() {
    super.initState();
    _bluetoothHandler = widget.bluetoothHandler;
    _isVisionXReady = widget.bluetoothHandler.bluetoothConnection != null;
    _isVisionXConnected = widget.bluetoothHandler.bluetoothConnection != null;

    _audioRecorder = AudioRecorder();
    _isLocked = false;
    _showSavedIcon = false;

    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      _updateRecordState(recordState);
    });

    _amplitudeSub = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amp) {
      setState(() => _amplitude = amp);
    });
    widget.bluetoothHandler.getConnectedBluetoothDevice();
    widget.bluetoothHandler.connectionStateStream.listen((event) {
      setState(() {
        _isVisionXConnected = event;
      });
    });
    widget.bluetoothHandler.readyStateStream.listen((event) {
      setState(() {
        _isVisionXReady = event;
      });
    });

    WidgetsBinding.instance.addObserver(this);
  }

  Future<RecognitionConfig> _getConfig() async {
    final String languageCode = await getLanguageCodeFromSharedPreferences();

    return RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.latest_long,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 48000,
      languageCode: languageCode,
    );
  }

  Future<void> _start() async {
    try {
      final serviceAccount = ServiceAccount.fromString(
        await rootBundle.loadString(/*API_KEY_HERE*/),
      );
      final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
      final config = await _getConfig();

      if (await _audioRecorder.hasPermission()) {
        const encoder = AudioEncoder.pcm16bits;

        if (!await _isEncoderSupported(encoder)) {
          return;
        }

        const recordStreamConfig =
            RecordConfig(encoder: encoder, numChannels: 1);

        // Record to stream
        final responseStream = speechToText.streamingRecognize(
          StreamingRecognitionConfig(config: config, interimResults: true),
          await recordStream(_audioRecorder, recordStreamConfig),
        );
        String previousText = "";
        responseStream.listen(
          (data) {
            Future<void> processSpeech() async {
              text = data.results
                  .map((e) => e.alternatives.first.transcript)
                  .join(' ');

              if (previousText.length > text.length - 1) {
                transcription += previousText;
              }
              previousText = text;

              print("translatestate: ");
              getTranslateStateFromSharedPreferences().then((value) async {
                print(value.toString());

                if (value) {
                  final sourceLanguage =
                      await getLanguageCodeFromSharedPreferences();
                  final targetLanguage =
                      await getTranslateLanguageCodeFromSharedPreferences();

                  Future<Secret> secret =
                      SecretLoader(secretPath: "assets/secrets.json").load();
                  secret.then((value) async {
                    GoogleTranslate.initialize(
                      apiKey: value.apiKey,
                      sourceLanguage: sourceLanguage,
                      targetLanguage: targetLanguage,
                    );

                    text.translate().then((value) {
                      translatedText = value;
                      _bluetoothHandler.sendTextOverBluetooth(context, value);
                    });
                  });
                } else {
                  if (mounted) {
                    _bluetoothHandler.sendTextOverBluetooth(context, text);
                  }
                }
              });
            }

            processSpeech();
          },
          onDone: () {
            print('done');
          },
        );

        _recordDuration = 0;

        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _stop() async {
    final path = await _audioRecorder.stop();

    if (path != null) {
      widget.onStop(path);

      downloadWebData(path);
    }

    if (transcription.isEmpty) {
      return;
    }

    final dir = await getApplicationDocumentsDirectory();

    DateTime dateTime = DateTime.now();

    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    String formattedTime = DateFormat('HH:mm:ss').format(dateTime);

    final String title = "${formattedDate}_$formattedTime";

    final file =
        await File('${dir.path}/transcriptions/$title').create(recursive: true);

    file.writeAsString(jsonEncode(transcription));

    setState(() {
      transcription = "";
      text = "";
      _showSavedIcon = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showSavedIcon = false;
      });
    });
    File('${dir.path}/transcriptions/$title')
        .readAsString()
        .then((String contents) {
      // Print the contents of the file
    }).catchError((e) {
      print('Error reading file: $e');
    });
  }

  Future<void> _pause() => _audioRecorder.pause();

  Future<void> _resume() => _audioRecorder.resume();

  Future<void> _updateRecordState(RecordState recordState) async {
    setState(() => _recordState = recordState);

    switch (recordState) {
      case RecordState.pause:
        _timer?.cancel();
        break;
      case RecordState.record:
        _startTimer();
        break;
      case RecordState.stop:
        _timer?.cancel();
        _recordDuration = 0;
        break;
    }
  }

  Future<bool> _isEncoderSupported(AudioEncoder encoder) async {
    final isSupported = await _audioRecorder.isEncoderSupported(
      encoder,
    );

    if (!isSupported) {
      debugPrint('${encoder.name} is not supported on this platform.');
      debugPrint('Supported encoders are:');

      for (final e in AudioEncoder.values) {
        if (await _audioRecorder.isEncoderSupported(e)) {
          debugPrint('- ${encoder.name}');
        }
      }
    }

    return isSupported;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Theme.of(context)!
              .colorScheme
              .secondaryContainer
              .withOpacity(0.2),
          body: _isVisionXReady
              ? _buildRecorderWidget()
              : _buildNoVisionXWidget()),
    );
  }

  Widget _buildNoVisionXWidget() {
    final connButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          Theme.of(context).colorScheme.secondary,
        ),
      ),
      onPressed: () {
        AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
      },
      child: Text(
        'Connect',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    );

    final retryButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          Theme.of(context).colorScheme.secondary,
        ),
      ),
      onPressed: () {
        widget.bluetoothHandler.getConnectedBluetoothDevice();
      },
      child: Text(
        'Retry',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    );
    // Check if _isVisionXReady is true
    if (_isVisionXConnected) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OnboardingWidget(
            title: 'Oops!',
            image: 'assets/images/btfail.jpg',
            description:
                'Something went wrong when trying to start VisionX.\n\nPlease restart the VisionX device.',
            button: retryButton,
          ),
        ],
      );
    } else {
      // If _isVisionXReady is false, return a column with a different description
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OnboardingWidget(
            title: 'VisionX Device Not Connected',
            image: 'assets/images/btfail.jpg',
            description:
                'The VisionX device is not yet connected via Bluetooth.\n\nTap the button below to access your device\'s Bluetooth settings and connect to VisionX.',
            button: connButton,
          ),
        ],
      );
    }
  }

  Widget _buildRecorderWidget() {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                BuildRecordButton(
                  recordState: _recordState,
                  onPressed: () {
                    if (_isLocked) return;
                    if (_recordState == RecordState.stop) {
                      _start();
                    } else {
                      _stop();
                    }
                  },
                ),
                const SizedBox(height: 50),
                // Changed width to height for SizedBox
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_recordState == RecordState.record) _buildStopControl(),
                    _buildPauseResumeControl(),
                  ],
                ),
              ],
            ),
            _buildText(),
            RecognizeContent(
              text: text,
            )
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: BottomAppBar(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(
                    Icons.photo,
                    size: 48,
                  ),
                  onPressed: () {
                    if (_isLocked) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GalleryAccess(
                          bluetoothHandler: _bluetoothHandler,
                        ),
                      ),
                    );
                  },
                  color: _isLocked
                      ? Colors.grey
                      : Theme.of(context).colorScheme.primary,
                ),
                GestureDetector(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showSavedIcon
                        ? const Icon(
                            Icons.save,
                            size: 48.0,
                            color: Colors.green,
                          )
                        : Icon(
                            Icons.expand_less,
                            size: 48.0,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                  onVerticalDragStart: (_) {
                    showModalBottomSheet<void>(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return const FractionallySizedBox(
                            heightFactor: 0.33, child: TranscriptionList());
                      },
                    );
                  },
                ),
                _recordState == RecordState.record
                    ? LockScreen(
                        onPressed: () {
                          _isLocked = true;
                        },
                        onLongPressed: () {
                          _isLocked = false;
                        },
                        isLocked: _isLocked,
                      )
                    : const SizedBox(
                        width: 48,
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      widget.bluetoothHandler.getConnectedBluetoothDevice();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _audioRecorder.dispose();
    _bluetoothHandler.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _buildStopControl() {
    late Image icon;

    icon = Image.asset("assets/images/stop.png",
        color: _isLocked ? Colors.grey.withOpacity(0.8) : Colors.black);

    return InkWell(
      child: SizedBox(width: 56, height: 56, child: icon),
      onTap: () {
        if (_isLocked) return;
        _stop();
      },
    );
  }

  Widget _buildPauseResumeControl() {
    if (_recordState == RecordState.stop) {
      return const SizedBox.shrink();
    }

    late Icon icon;

    if (_recordState == RecordState.record) {
      icon = Icon(Icons.pause,
          color: _isLocked ? Colors.grey.withOpacity(0.8) : Colors.red,
          size: 40);
    } else {
      icon = Icon(Icons.play_arrow,
          color: _isLocked ? Colors.grey.withOpacity(0.8) : Colors.red,
          size: 40);
    }

    return InkWell(
      child: SizedBox(width: 56, height: 56, child: icon),
      onTap: () {
        if (_isLocked) return;
        (_recordState == RecordState.pause) ? _resume() : _pause();
      },
    );
  }

  Widget _buildText() {
    if (_recordState != RecordState.stop) {
      return _buildTimer();
    }

    return (translatedText.isNotEmpty)
        ? Text(translatedText)
        : const Text("waiting to record");
  }

  Widget _buildTimer() {
    final String minutes = _formatNumber(_recordDuration ~/ 60);
    final String seconds = _formatNumber(_recordDuration % 60);

    return Text(
      '$minutes : $seconds',
      style: const TextStyle(color: Colors.red),
    );
  }

  String _formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }

    return numberStr;
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }
}
