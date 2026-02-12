import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'join_game_screen.dart';
import 'multiplayer_game_screen.dart';
import 'network_error_screen.dart';
import '../logic/multiplayer_provider.dart';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'credits_screen.dart';

enum HomeMenuState { main, singleplayer, multiplayer }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeMenuState _menuState = HomeMenuState.main;

  Future<bool> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none) && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const NetworkErrorScreen()),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _menuState == HomeMenuState.main,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _menuState = HomeMenuState.main;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreditsScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            const SizedBox(width: 10),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Symbols.chess_knight,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 128,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'CHESS',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'ARENA',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                              height: 1.0,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 60),
                  _buildMenuContent(),
                ],
              ),
            ),
            const Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Text(
                'Made with ♡ by Govind Sankar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuContent() {
    switch (_menuState) {
      case HomeMenuState.main:
        return Column(
          children: [
            _MenuButton(
              text: 'SINGLEPLAYER',
              onPressed: () {
                setState(() {
                  _menuState = HomeMenuState.singleplayer;
                });
              },
            ),
            const SizedBox(height: 20),
            _MenuButton(
              text: 'MULTIPLAYER',
              onPressed: () {
                setState(() {
                  _menuState = HomeMenuState.multiplayer;
                });
              },
            ),
          ],
        );

      case HomeMenuState.singleplayer:
        return Column(
          children: [
            _MenuButton(
              text: 'EASY',
              onPressed: () => _startSinglePlayerGame(1),
              isSmall: true,
            ),
            const SizedBox(height: 10),
            _MenuButton(
              text: 'MEDIUM',
              onPressed: () => _startSinglePlayerGame(2),
              isSmall: true,
            ),
            const SizedBox(height: 10),
            _MenuButton(
              text: 'HARD',
              onPressed: () => _startSinglePlayerGame(3),
              isSmall: true,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() {
                  _menuState = HomeMenuState.main;
                });
              },
              child: const Text('Back'),
            ),
          ],
        );

      case HomeMenuState.multiplayer:
        return Column(
          children: [
            _MenuButton(
              text: 'CREATE GAME',
              onPressed: _createMultiplayerGame,
              isSmall: true,
            ),
            const SizedBox(height: 10),
            _MenuButton(
              text: 'JOIN GAME',
              onPressed: () async {
                if (await _checkConnectivity()) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const JoinGameScreen()),
                  );
                }
              },
              isSmall: true,
            ),
            const SizedBox(height: 10),
            _MenuButton(
              text: 'JOIN ONLINE',
              onPressed: () async {
                if (!await _checkConnectivity()) return;
                final provider = MultiplayerProvider();
                final result = await provider.joinOnlineMatch();
                if (!mounted) return;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiplayerGameScreen(
                      gameCode: result['roomId'],
                      isCreator: result['isCreator'],
                      showRoomCode: false,
                    )
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() {
                  _menuState = HomeMenuState.main;
                });
              },
              child: const Text('Back'),
            ),
          ],
        );
    }
  }

  void _startSinglePlayerGame(int difficulty) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => GameScreen(difficulty: difficulty),
          ),
        )
        .then((_) {
      if (mounted) {
        setState(() {
          _menuState = HomeMenuState.main;
        });
      }
    });
  }

  void _createMultiplayerGame() async {
    if (!await _checkConnectivity()) return;

    String gameCode = (100000 + Random().nextInt(900000)).toString();
    
    await MultiplayerProvider().createRoom(gameCode);
    
    if (!mounted) return;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => MultiplayerGameScreen(
              gameCode: gameCode,
              isCreator: true,
              showRoomCode: true,
            ),
          ),
        )
        .then((_) {
      if (mounted) {
        setState(() {
          _menuState = HomeMenuState.main;
        });
      }
    });
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSmall;

  const _MenuButton({
    required this.text,
    required this.onPressed,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: isSmall
            ? ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )
            : null,
        child: Text(text),
      ),
    );
  }
}