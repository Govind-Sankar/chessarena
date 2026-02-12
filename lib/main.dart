import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ChessApp());
}

class ChessApp extends StatelessWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager(),
      builder: (context, _) {
        final themeManager = ThemeManager();

        ThemeData theme;
        if (themeManager.themeMode == AppThemeMode.amoled) {
          theme = AppTheme.amoledTheme();
        } else if (themeManager.themeMode == AppThemeMode.dark) {
          theme = AppTheme.darkTheme();
        } else {
          theme = AppTheme.lightTheme();
        }

        return MaterialApp(
          title: 'Chess',
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeManager.currentThemeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
