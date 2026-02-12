import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, amoled, system }

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  AppThemeMode _themeMode = AppThemeMode.system;

  final Color _primaryBlue = const Color(0xFF455A64);

  AppThemeMode get themeMode => _themeMode;
  Color get primaryBlue => _primaryBlue;

  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

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
}
