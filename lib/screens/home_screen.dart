import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'settings_screen.dart';
import 'credits_screen.dart';
import 'singleplayer_home_screen.dart';
import 'multiplayer_home_screen.dart';
import 'package:chessarena/widgets/menu_button.dart';
import 'package:chessarena/widgets/arena_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: const ArenaLayout(
        child: _HomeButtons(),
      ),
    );
  }
}

class _HomeButtons extends StatelessWidget {
  const _HomeButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MenuButton(
          text: 'SINGLEPLAYER',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SingleplayerHomeScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        MenuButton(
          text: 'MULTIPLAYER',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MultiplayerHomeScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

