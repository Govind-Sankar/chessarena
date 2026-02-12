import 'package:flutter/material.dart';
import '../theme/theme_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Map<String, dynamic>> _themes = [
    {'name': 'Light', 'mode': AppThemeMode.light},
    {'name': 'Dark', 'mode': AppThemeMode.dark},
    {'name': 'System', 'mode': AppThemeMode.system},
    // {'name': 'Amoled', 'mode': AppThemeMode.amoled},
  ];

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager();

    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Appearance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(_getThemeName(themeManager.themeMode)),
                leading: const Icon(Icons.palette_outlined),
                onTap: () => _showThemeDialog(themeManager),
              ),
              const Divider(),
              ListTile(
                title: const Text('Accent Color'),
                subtitle: Text(_getAccentName(themeManager.accentColor)),
                leading: const Icon(Icons.color_lens_outlined),
                onTap: () => _showAccentDialog(themeManager),
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  String _getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light: return 'Light';
      case AppThemeMode.dark: return 'Dark';
      case AppThemeMode.system: return 'System';
      // case AppThemeMode.amoled: return 'Amoled';
      default: return 'System';
    }
  }

  String _getAccentName(AppAccentColor color) {
    switch (color) {
      case AppAccentColor.red: return 'Red';
      case AppAccentColor.green: return 'Green';
      case AppAccentColor.violet: return 'Violet';
      case AppAccentColor.blue:
      default: return 'Blue';
    }
  }

  void _showAccentDialog(ThemeManager themeManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Accent Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppAccentColor.values.map((color) {
            return RadioListTile<AppAccentColor>(
              title: Text(_getAccentName(color)),
              value: color,
              groupValue: themeManager.accentColor,
              onChanged: (value) {
                themeManager.setAccentColor(value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog(ThemeManager themeManager) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _themes
              .map((theme) => RadioListTile<AppThemeMode>(
                    title: Text(theme['name']),
                    value: theme['mode'],
                    groupValue: themeManager.themeMode == AppThemeMode.amoled 
                        ? AppThemeMode.dark 
                        : themeManager.themeMode,
                    onChanged: (value) {
                      themeManager.setThemeMode(value!);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
