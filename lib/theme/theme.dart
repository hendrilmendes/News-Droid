import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeType { light, dark, system }

class ThemeModel extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _useDynamicColors = true;
  bool get isDynamicColorsEnabled => _useDynamicColors;
  ThemeModeType _themeMode = ThemeModeType.system;
  SharedPreferences? _prefs;
  ColorScheme? _lightDynamicColorScheme;
  ColorScheme? _darkDynamicColorScheme;

  ThemeModel() {
    _loadThemePreference();
    _loadDynamicColors();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeModeType get themeMode => _themeMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _saveThemeModePreference(
      _isDarkMode ? ThemeModeType.dark : ThemeModeType.light,
    );
    notifyListeners();
  }

  void toggleDynamicColors() {
    _useDynamicColors = !_useDynamicColors;
    _saveDynamicColorPreference(_useDynamicColors);
    notifyListeners();
  }

  void changeThemeMode(ThemeModeType mode) {
    _themeMode = mode;
    _saveThemeModePreference(mode);
    notifyListeners();
  }

  void setDynamicColors(ColorScheme? light, ColorScheme? dark) {
    _lightDynamicColorScheme = light;
    _darkDynamicColorScheme = dark;
    _useDynamicColors = light != null && dark != null;
    _saveDynamicColorPreference(_useDynamicColors);
    notifyListeners();
  }

  ThemeData get lightTheme {
    if (_useDynamicColors && _lightDynamicColorScheme != null) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: _lightDynamicColorScheme,
        textTheme: Typography().black.apply(
          fontFamily: GoogleFonts.openSans().fontFamily,
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
            TargetPlatform.values,
            value: (_) => const FadeForwardsPageTransitionsBuilder(),
          ),
        ),
      );
    }
    return ThemeModel.getLightTheme();
  }

  ThemeData get darkTheme {
    if (_useDynamicColors && _darkDynamicColorScheme != null) {
      return ThemeData(
        useMaterial3: true,
        colorScheme: _darkDynamicColorScheme!.copyWith(
          brightness: Brightness.dark,
        ),
        textTheme: Typography().white.apply(
          fontFamily: GoogleFonts.openSans().fontFamily,
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
            TargetPlatform.values,
            value: (_) => const FadeForwardsPageTransitionsBuilder(),
          ),
        ),
      );
    }
    return ThemeModel.getDarkTheme();
  }

  Future<void> _loadThemePreference() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool('darkModeEnabled') ?? false;
    _useDynamicColors = _prefs?.getBool('useDynamicColors') ?? false;
    _themeMode = _getSavedThemeMode(
      _prefs?.getString('themeMode') ?? ThemeModeType.system.toString(),
    );

    // Certifique-se de que os esquemas de cores dinâmicos sejam carregados
    await _loadDynamicColors();
    notifyListeners();
  }

  Future<void> _loadDynamicColors() async {
    final dynamicPalette = await DynamicColorPlugin.getCorePalette();

    if (dynamicPalette != null) {
      _lightDynamicColorScheme = dynamicPalette.toColorScheme(
        brightness: Brightness.light,
      );
      _darkDynamicColorScheme = dynamicPalette.toColorScheme(
        brightness: Brightness.dark,
      );
    }

    notifyListeners();
  }

  Future<void> _saveThemeModePreference(ThemeModeType mode) async {
    await _prefs?.setString('themeMode', mode.toString());
    await _prefs?.setBool('darkModeEnabled', mode == ThemeModeType.dark);
  }

  Future<void> _saveDynamicColorPreference(bool value) async {
    await _prefs?.setBool('useDynamicColors', value);
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

  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(),
      scaffoldBackgroundColor: Colors.white,
      textTheme: Typography().black.apply(
        fontFamily: GoogleFonts.openSans().fontFamily,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        enableFeedback: true,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
          TargetPlatform.values,
          value: (_) => const FadeForwardsPageTransitionsBuilder(),
        ),
      ),
    );
  }

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(backgroundColor: Colors.black),
      textTheme: Typography().white.apply(
        fontFamily: GoogleFonts.openSans().fontFamily,
      ),
      bottomAppBarTheme: BottomAppBarTheme(color: Colors.black),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: Map<TargetPlatform, PageTransitionsBuilder>.fromIterable(
          TargetPlatform.values,
          value: (_) => const FadeForwardsPageTransitionsBuilder(),
        ),
      ),
    );
  }
}
