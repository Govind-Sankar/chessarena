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
      default: return 'System';
    }
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
