
import 'package:flutter/material.dart';
import '../data/shared_prefs_helper.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr');
  final SharedPrefsHelper _prefs = SharedPrefsHelper();

  Locale get locale => _locale;

  LocaleProvider() {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    String languageCode = _prefs.getString('language_code', defaultValue: 'fr');
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _prefs.saveString('language_code', locale.languageCode);
    notifyListeners();
  }
}
