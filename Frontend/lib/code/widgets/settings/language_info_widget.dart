import 'package:flutter/material.dart';
import 'package:thelab/code/audio-recorder.dart';
import 'package:thelab/code/event_bus.dart';

class LanguageInfoButton extends StatefulWidget {
  final VoidCallback onPressed;

  const LanguageInfoButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  State<LanguageInfoButton> createState() => _LanguageInfoButtonState();
}

class _LanguageInfoButtonState extends State<LanguageInfoButton> {
  late String language = "English";
  late bool isTranslated = false;
  late String translatedLanguage;

  @override
  void initState() {
    super.initState();
    _loadInitialValue();

    EventBusService().eventBus.on<CustomEvent>().listen((event) {
      print('Received event:');
      _loadInitialValue();
    });
  }

  Future<void> _loadInitialValue() async {
    var tempLanguage = await getLanguageCodeFromSharedPreferences();
    var tempIsTranslated = await getTranslateStateFromSharedPreferences();
    var tempTranslatedLanguage =
        await getTranslateLanguageCodeFromSharedPreferences();

    setState(() {
      language = tempLanguage;
      isTranslated = tempIsTranslated;
      translatedLanguage = tempTranslatedLanguage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(
              language,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            if (isTranslated && language != translatedLanguage) ...[
              const Icon(
                Icons.arrow_forward,
                size: 15,
                color: Colors.grey,
              ),
              Text(
                translatedLanguage,
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              )
            ],
          ],
        ),
      ),
    );
  }
}
