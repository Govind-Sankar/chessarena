import 'package:flutter/material.dart';
import 'multiplayer_game_screen.dart';
import '../logic/multiplayer_provider.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  void _joinGame() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await MultiplayerProvider().joinRoom(code);

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MultiplayerGameScreen(
              gameCode: code,
              isCreator: false,
            ),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Room not found. Please check the code.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Game'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ENTER GAME CODE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                counterText: "",
                hintText: '000000',
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _joinGame,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('JOIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
