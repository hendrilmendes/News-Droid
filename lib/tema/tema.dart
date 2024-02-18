import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModel extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _isDynamicColorsEnabled = true;

  ThemeModel() {
    _loadThemePreference(); // Verifica o tema definido quando abre o app
  }

  bool get isDarkMode => _isDarkMode;
  bool get isDynamicColorsEnabled => _isDynamicColorsEnabled;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    saveThemePreference(_isDarkMode);
    notifyListeners();
  }

  void toggleDynamicColors() {
    _isDynamicColorsEnabled = !_isDynamicColorsEnabled;
    notifyListeners();
  }

  // Carregar o tema salvo
  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkModeEnabled') ?? true;
    _isDynamicColorsEnabled = prefs.getBool('dynamicColorsEnabled') ?? true;
    notifyListeners();
  }

  // Salvar o tema
  void saveThemePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkModeEnabled', value);
  }

  void saveDynamicPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('dynamicColorsEnabled', value);
  }
}
