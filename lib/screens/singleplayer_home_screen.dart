import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'credits_screen.dart';
import 'game_screen.dart';
import '../widgets/arena_layout.dart';
import '../widgets/menu_button.dart';
import '../widgets/desktop_frame.dart';

class SingleplayerHomeScreen extends StatelessWidget {
  const SingleplayerHomeScreen({super.key});

  void _startGame(BuildContext context, int difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(difficulty: difficulty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DesktopFrame(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreditsScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: ArenaLayout(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MenuButton(
                text: 'EASY',
                onPressed: () => _startGame(context, 1),
              ),
              const SizedBox(height: 10),
              MenuButton(
                text: 'MEDIUM',
                onPressed: () => _startGame(context, 2),
              ),
              const SizedBox(height: 10),
              MenuButton(
                text: 'HARD',
                onPressed: () => _startGame(context, 3),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
