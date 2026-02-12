import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'credits_screen.dart';
import 'join_game_screen.dart';
import 'multiplayer_game_screen.dart';
import '../logic/multiplayer_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'network_error_screen.dart';
import 'dart:math';
import '../widgets/arena_layout.dart';
import '../widgets/menu_button.dart';

class MultiplayerHomeScreen extends StatelessWidget {
  const MultiplayerHomeScreen({super.key});

  Future<bool> _checkConnectivity(BuildContext context) async {
    var result = await Connectivity().checkConnectivity();
    if (result.contains(ConnectivityResult.none) && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NetworkErrorScreen()),
      );
      return false;
    }
    return true;
  }

  Future<void> _createGame(BuildContext context) async {
    if (!await _checkConnectivity(context)) return;

    String code = (100000 + Random().nextInt(900000)).toString();
    await MultiplayerProvider().createRoom(code);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiplayerGameScreen(
            gameCode: code,
            isCreator: true,
            showRoomCode: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              text: 'CREATE GAME',
              onPressed: () => _createGame(context),
            ),
            const SizedBox(height: 10),
            MenuButton(
              text: 'JOIN GAME',
              onPressed: () async {
                if (await _checkConnectivity(context)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const JoinGameScreen()),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            MenuButton(
              text: 'JOIN ONLINE',
              onPressed: () async {
                if (!await _checkConnectivity(context)) return;
                final provider = MultiplayerProvider();
                final result = await provider.joinOnlineMatch();

                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiplayerGameScreen(
                        gameCode: result['roomId'],
                        isCreator: result['isCreator'],
                        showRoomCode: false,
                      ),
                    ),
                  );
                }
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
