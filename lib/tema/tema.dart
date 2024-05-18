import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeType { light, dark, system }

class ThemeModel extends ChangeNotifier {
  bool _isDarkMode = true;
  ThemeModeType _themeMode = ThemeModeType.light;

  ThemeModel() {
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeModeType get themeMode => _themeMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void changeThemeMode(ThemeModeType mode) {
    _themeMode = mode;
    saveThemeModePreference(mode);
    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkModeEnabled') ?? true;
    _themeMode = _getSavedThemeMode(prefs.getString('themeMode'));
    notifyListeners();
  }

  void saveThemeModePreference(ThemeModeType mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', mode.toString());
  }

  ThemeModeType _getSavedThemeMode(String? mode) {
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

  static ThemeData lightTheme({
    required BuildContext context,
  }) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      textTheme: Typography().black.apply(fontFamily: 'OpenSans'),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
            color: Colors.black, fontFamily: 'OpenSans', fontSize: 24),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.black),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
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
    );
  }

  static ThemeData darkTheme({
    required BuildContext context,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(),
      scaffoldBackgroundColor: Colors.black,
      textTheme: Typography().white.apply(fontFamily: 'OpenSans'),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black87,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
            color: Colors.white, fontFamily: 'OpenSans', fontSize: 24),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(color: Colors.black),
      iconTheme: const IconThemeData(color: Colors.white),
      bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(backgroundColor: Colors.black),
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
    );
  }
}
