import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, amoled, system }
enum AppAccentColor { blue, red, green, violet }

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  static const String _themeKey = 'app_theme_mode';
  static const String _accentKey = 'app_accent_color';

  AppThemeMode _themeMode = AppThemeMode.system;
  AppAccentColor _accentColor = AppAccentColor.blue;
  AppAccentColor get accentColor => _accentColor;

  AppThemeMode get themeMode => _themeMode;

  ThemeMode get currentThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(_themeKey);
    final savedAccent = prefs.getInt(_accentKey);

    if (savedIndex != null) {
      _themeMode = AppThemeMode.values[savedIndex];
      notifyListeners();
    }
    if (savedAccent != null) {
      _accentColor = AppAccentColor.values[savedAccent];
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setAccentColor(AppAccentColor color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentKey, color.index);
    notifyListeners();
  }
}