import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeType { light, dark, system }

class ThemeModel extends ChangeNotifier {
  bool _isDarkMode = true;
  ThemeModeType _themeMode = ThemeModeType.light;
  SharedPreferences? _prefs;

  ThemeModel() {
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeModeType get themeMode => _themeMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _saveThemeModePreference(
        _isDarkMode ? ThemeModeType.dark : ThemeModeType.light);
    notifyListeners();
  }

  void changeThemeMode(ThemeModeType mode) {
    _themeMode = mode;
    _saveThemeModePreference(mode);
    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool('darkModeEnabled') ?? true;
    _themeMode = _getSavedThemeMode(
        _prefs?.getString('themeMode') ?? ThemeModeType.system.toString());
    notifyListeners();
  }

  Future<void> _saveThemeModePreference(ThemeModeType mode) async {
    await _prefs?.setString('themeMode', mode.toString());
    await _prefs?.setBool('darkModeEnabled', mode == ThemeModeType.dark);
  }

  ThemeModeType _getSavedThemeMode(String mode) {
    switch (mode) {
      case 'ThemeModeType.light':
        return ThemeModeType.light;
      case 'ThemeModeType.dark':
        return ThemeModeType.dark;
      case 'ThemeModeType.system':
        return ThemeModeType.system;
      default:
        return ThemeModeType.system;
    }
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      textTheme: Typography()
          .black
          .apply(fontFamily: GoogleFonts.openSans().fontFamily),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white70,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
            color: Colors.black,
            fontFamily: GoogleFonts.openSans().fontFamily,
            fontSize: 24),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.black),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        enableFeedback: true,
        backgroundColor: Colors.white,
        selectedItemColor: Color.fromARGB(255, 97, 184, 255),
      ),
      cardTheme: const CardTheme(
        color: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.black),
        labelStyle: TextStyle(color: Colors.black),
      ),
      dialogTheme: const DialogTheme(backgroundColor: Colors.white),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.black,
        textColor: Colors.black,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        useIndicator: true,
        backgroundColor: Colors.white,
        indicatorColor: Colors.black,
        selectedLabelTextStyle: TextStyle(color: Colors.black),
        unselectedLabelTextStyle: TextStyle(color: Colors.black),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
        ),
      ),
      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(backgroundColor: Colors.white),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(),
      scaffoldBackgroundColor: Colors.black,
      textTheme: Typography()
          .white
          .apply(fontFamily: GoogleFonts.openSans().fontFamily),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.openSans().fontFamily,
            fontSize: 24),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(color: Colors.black),
      iconTheme: const IconThemeData(color: Colors.white),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Color.fromARGB(255, 97, 184, 255),
      ),
      cardTheme: const CardTheme(
        color: Colors.black87,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white),
        labelStyle: TextStyle(color: Colors.white),
      ),
      dialogTheme: const DialogTheme(backgroundColor: Colors.black),
      listTileTheme: const ListTileThemeData(
        tileColor: Color.fromARGB(212, 23, 23, 23),
        iconColor: Colors.white,
        textColor: Colors.white,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        useIndicator: true,
        backgroundColor: Colors.black,
        indicatorColor: Colors.white,
        selectedLabelTextStyle: TextStyle(color: Colors.white),
        unselectedLabelTextStyle: TextStyle(color: Colors.white),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
        ),
      ),
      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(backgroundColor: Colors.blue),
    );
  }
}
