import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:thelab/code/audio-recorder.dart';
import 'package:thelab/code/bluetooth/BluetoothHandler.dart';
import 'package:thelab/code/widgets/settings/language_info_widget.dart';
import 'package:thelab/code/widgets/settings/menu_button.dart';

import '../code/widgets/settings/settings_sheet_text.dart';

class RecorderApp extends StatefulWidget {
  final BluetoothHandler bluetoothHandler;

  const RecorderApp({super.key, required this.bluetoothHandler});

  @override
  State<RecorderApp> createState() => _MyRecorderAppState();
}

class _MyRecorderAppState extends State<RecorderApp> {
  bool showPlayer = false;
  String? audioPath;

  @override
  void initState() {
    showPlayer = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          backgroundColor:
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
          shadowColor: Colors.transparent,
          leading: CustomIconButton(
            icon: Icons.settings,
            onPressed: () {
              SideSheet.left(body: const SettingsSheetText(), context: context);
            },
          ),
          actions: [
            LanguageInfoButton(onPressed: () {
              SideSheet.left(body: const SettingsSheetText(), context: context);
            })
          ],
        ),
        body: Center(
          child: Recorder(
            bluetoothHandler: widget.bluetoothHandler,
            onStop: (path) {
              if (kDebugMode) print('Recorded file path: $path');
              setState(() {
                audioPath = path;
                showPlayer = true;
              });
            },
          ),
        ));
  }
}
