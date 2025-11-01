import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar', ''); // Default to Arabic
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

  LanguageProvider() {
    // Don't call async method in constructor
    _initializeLanguage();
  }

  // Initialize language asynchronously
  Future<void> _initializeLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('language_code') ?? 'ar';
      _locale = Locale(languageCode, '');
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved language: $e');
      // Use default locale if loading fails
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!['ar', 'fr', 'en'].contains(locale.languageCode)) {
      return;
    }
    
    _locale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', locale.languageCode);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
  }

  bool isRTL() {
    return _locale.languageCode == 'ar';
  }
}
