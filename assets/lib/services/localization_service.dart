import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationService {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  LocalizationService(this.locale);

  static LocalizationService? of(BuildContext context) {
    return Localizations.of<LocalizationService>(context, LocalizationService);
  }

  static const LocalizationsDelegate<LocalizationService> delegate =
      _LocalizationServiceDelegate();

  Future<bool> load() async {
    String jsonString =
        await rootBundle.loadString('assets/langs/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  static List<Locale> supportedLocales = const [
    Locale('ar', ''),
    Locale('fr', ''),
    Locale('en', ''),
  ];
}

class _LocalizationServiceDelegate
    extends LocalizationsDelegate<LocalizationService> {
  const _LocalizationServiceDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'fr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<LocalizationService> load(Locale locale) async {
    LocalizationService localization = LocalizationService(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_LocalizationServiceDelegate old) => false;
}

extension LocalizationExtension on String {
  String tr(BuildContext context) {
    return LocalizationService.of(context)?.translate(this) ?? this;
  }
}
