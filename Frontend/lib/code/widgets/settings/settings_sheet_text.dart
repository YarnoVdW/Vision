import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thelab/code/constants.dart';
import 'package:thelab/code/event_bus.dart';
import 'package:thelab/code/widgets/settings/setting-dropdown.dart';
import 'package:thelab/code/widgets/settings/settings-checkbox.dart';
import 'package:thelab/code/widgets/settings/settings-number-input.dart';

class SettingsSheetText extends StatefulWidget {
  const SettingsSheetText({super.key});

  @override
  State<SettingsSheetText> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheetText> {
  bool _translateChecked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool?>(
        future: SharedPreferences.getInstance()
            .then((value) => value.getBool(S.of(context)!.translate)),
        builder: (context, snapshot) {
          bool translateLang = snapshot.data ?? false;
          return Container(
            color: Theme.of(context)
                .colorScheme
                .secondaryContainer
                .withOpacity(0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 55),
                Text(S.of(context)!.settings,
                    style: const TextStyle(fontSize: 20)),
                CustomDropDown<String>(
                  title: S.of(context)!.fontSize,
                  settingKey: S.of(context)!.fontSizeLowerCase,
                  items: FontSizes.sizes,
                  initialValue: "25",
                ),
                const SizedBox(height: 20),
                CustomDropDown<String>(
                  title: S.of(context)!.fontColour,
                  settingKey: S.of(context)!.fontColourLowerCase,
                  items: FontColors.colors,
                  initialValue: "Black",
                ),
                const SizedBox(height: 20),
                CustomDropDown<String>(
                  title: S.of(context)!.font,
                  settingKey: S.of(context)!.fontLowerCase,
                  items: FontFamilies.families,
                  initialValue: "Arial",
                ),
                const SizedBox(height: 10),
                CustomNumberInput(
                    initialValue: 1,
                    settingsKey: S.of(context)!.speedLowerCase,
                    label: S.of(context)!.speed),
                const SizedBox(height: 20),
                CustomDropDown<String>(
                    title: S.of(context)!.language,
                    settingKey: 'lang',
                    items: Language.languageCodes,
                    labels: Language.languageNames,
                    initialValue: "en-GB",
                    event: () {
                      EventBusService().eventBus.fire(CustomEvent());
                    }),
                const SizedBox(height: 10),
                CustomCheckbox(
                  initialValue: _translateChecked,
                  settingsKey: S.of(context)!.translate,
                  label: S.of(context)!.translate,
                  onChanged: (value) {
                    setState(() {
                      _translateChecked = value;
                    });
                    EventBusService().eventBus.fire(CustomEvent());
                  },
                ),
                const SizedBox(height: 20),
                if (translateLang || _translateChecked)
                  CustomDropDown<String>(
                    title: S.of(context)!.translateLanguage,
                    settingKey: 'translate_lang',
                    items: Language.languageCodes,
                    labels: Language.languageNames,
                    initialValue: "en-US",
                    event: () {
                      EventBusService().eventBus.fire(CustomEvent());
                    },
                  ),
                const SizedBox(height: 20)
              ],
            ),
          );
        });
  }
}
