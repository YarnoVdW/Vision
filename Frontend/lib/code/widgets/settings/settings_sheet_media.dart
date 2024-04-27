import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thelab/code/widgets/settings/settings-checkbox.dart';
import 'package:thelab/code/widgets/settings/settings-number-input.dart';

class SettingsSheetMedia extends StatefulWidget {
  const SettingsSheetMedia({Key? key}) : super(key: key);

  @override
  State<SettingsSheetMedia> createState() => _SettingsSheetMediaState();
}

class _SettingsSheetMediaState extends State<SettingsSheetMedia> {
  late Future<bool> _isLimitedFuture;

  @override
  void initState() {
    super.initState();
    _isLimitedFuture = _loadIsLimited();
  }

  Future<bool> _loadIsLimited() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(S.of(context)!.limitedTimeLowerCase) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLimitedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Or any other loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          bool _isLimited = snapshot.data!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 55),
              const Text("Settings", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              CustomCheckbox(
                initialValue: _isLimited,
                settingsKey: S.of(context)!.limitedTimeLowerCase,
                label: S.of(context)!.limitedTime,
                onChanged: (value) async {
                  setState(() {
                    _isLimitedFuture = Future.value(value);
                  });
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool(S.of(context)!.limitedTimeLowerCase, value);
                },
              ),
              const SizedBox(height: 20),
              if (_isLimited)
                CustomNumberInput(
                  initialValue: 10,
                  settingsKey: S.of(context)!.screenTimeSettingsKey,
                  label: S.of(context)!.screenTime,
                ),
            ],
          );
        }
      },
    );
  }
}
