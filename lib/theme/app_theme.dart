import 'package:chessarena/theme/theme_manager.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static Color getAccentColor(AppAccentColor accent) {
    switch (accent) {
      case AppAccentColor.red:
        return const Color(0xFFB71C1C);
      case AppAccentColor.green:
        return const Color(0xFF1B5E20);
      case AppAccentColor.violet:
        return const Color(0xFF4A148C);
      case AppAccentColor.blue:
      default:
        return const Color(0xFF455A64);
    }
  }

  static ThemeData lightTheme(AppAccentColor accent) {
    final primary = getAccentColor(accent);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  static ThemeData darkTheme(AppAccentColor accent) {
    final primary = getAccentColor(accent);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  static ThemeData amoledTheme(AppAccentColor accent) {
    final primary = getAccentColor(accent);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        surface: Colors.black,
        onSurface: Colors.white,
      ).copyWith(
        surface: Colors.black,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.black,
      canvasColor: Colors.black,
      cardColor: Colors.black,
      dialogBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
