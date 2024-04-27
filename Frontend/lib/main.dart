import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/s.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:thelab/pages/onboarding.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff00989b),
          secondary: const Color(0xff7b9696),
          tertiary: const Color(0xff7f92b1)),
    ),
    locale: const Locale('en', 'US'),
    supportedLocales: const [Locale('nl'), Locale('en')],
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const OnBoardingVision(),
  ));
}
