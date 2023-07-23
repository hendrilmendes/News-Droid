import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Metodo para tema escuro e claro
class ThemeModel extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference(_isDarkMode);
    notifyListeners();
  }

  // Salvar o tema definifo pelo usuário
  void _saveThemePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkModeEnabled', value);
  }
}
