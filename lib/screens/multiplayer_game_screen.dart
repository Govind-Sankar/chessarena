import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:chess/chess.dart' as chess_lib;
import '../logic/chess_game_logic.dart';
import '../logic/multiplayer_provider.dart';
import '../widgets/chess_board.dart';

class MultiplayerGameScreen extends StatefulWidget {
  final String gameCode;
  final bool isCreator;
  final bool showRoomCode;

  const MultiplayerGameScreen({
    super.key,
    required this.gameCode,
    required this.isCreator,
    this.showRoomCode = true,
  });

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> {
  final ChessGameLogic _logic = ChessGameLogic();
  final MultiplayerProvider _multiplayerProvider = MultiplayerProvider();
  late StreamSubscription<DatabaseEvent> _roomSubscription;

  List<int>? _selectedSquare;
  List<String> _validMoves = [];
  bool _isWaitingForOpponent = true;
  String _lastMove = '';
  bool _gameOverShown = false;
  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
    _isWaitingForOpponent = widget.isCreator;
    _listenToRoom();
  }

  void _listenToRoom() {
    _roomSubscription = _multiplayerProvider.getRoomStream(widget.gameCode).listen((event) {
      if (!mounted) return;
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        if (_isLeaving) return;
        _showOpponentLeftDialog();
        return;
      }

      if (mounted) {
        setState(() {
          if (data['status'] == 'playing') _isWaitingForOpponent = false;

          final lastMove = data['lastMove'] as String? ?? '';
          if (lastMove.isNotEmpty && lastMove != _lastMove) {
            _lastMove = lastMove;
            final parts = lastMove.split('-');
            _logic.makeMove(parts[0], parts[1]);
          }

          if (data['gameOver'] == true && !_gameOverShown) {
            _gameOverShown = true;
            _showGameOverDialog(data['winner']);
          }
        });
      }
    });
  }

  void _showOpponentLeftDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Opponent Disconnected", textAlign: TextAlign.center),
        content: const Text(
          "The other player has left the game.",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _onSquareTap(int row, int col) {
    if (_isWaitingForOpponent) return;

    final myColor = widget.isCreator ? chess_lib.Color.WHITE : chess_lib.Color.BLACK;
    if (_logic.turnColor != myColor) return;

    setState(() {
      String currentSquare = _coordsToAlgebraic(row, col);

      if (_selectedSquare == null) {
        var piece = _logic.board[row][col];
        if (piece != null && piece.color == myColor) {
          _selectedSquare = [row, col];
          _validMoves = _logic.getValidMoves(currentSquare);
        }
      } else {
        String from = _coordsToAlgebraic(_selectedSquare![0], _selectedSquare![1]);
        bool isValidMove = _validMoves.contains(currentSquare);

        if (isValidMove) {
          if (_logic.makeMove(from, currentSquare)) {
            _lastMove = '$from-$currentSquare';
            bool isGameOver = _logic.isGameOver;
            String winner = '';
            if (isGameOver) {
              winner = _logic.game.turn == chess_lib.Color.WHITE ? 'Black' : 'White';
            }
            _multiplayerProvider.makeMove(
              widget.gameCode,
              _lastMove,
              _logic.turnColor == chess_lib.Color.WHITE ? 'white' : 'black',
              gameOver: isGameOver,
              winner: winner,
            );
            _clearSelection();
          }
        } else {
          var piece = _logic.board[row][col];
          if (piece != null && piece.color == myColor) {
            _selectedSquare = [row, col];
            _validMoves = _logic.getValidMoves(currentSquare);
          } else {
            _clearSelection();
          }
        }
      }
    });
  }

  void _clearSelection() {
    _selectedSquare = null;
    _validMoves = [];
  }

  String _coordsToAlgebraic(int row, int col) {
    String file = String.fromCharCode('a'.codeUnitAt(0) + col);
    String rank = (8 - row).toString();
    return '$file$rank';
  }

  Future<bool> _onWillPop() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Game?', textAlign: TextAlign.center),
        content: const Text(
          'This will delete the game for both players.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes')),
        ],
      ),
    ) ??
        false;
    if (confirm) {
      _isLeaving = true;
      await _multiplayerProvider.removeRoom(widget.gameCode);
      return true;
    }
    return false;
  }

  void _showGameOverDialog(String winner) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Winner: $winner', textAlign: TextAlign.center),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (widget.isCreator) {
                await _multiplayerProvider.removeRoom(widget.gameCode);
              }
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Home'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _roomSubscription.cancel();
    if (widget.isCreator && !_isLeaving) {
       _multiplayerProvider.removeRoom(widget.gameCode);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Multiplayer'),
          actions: [
            if (widget.showRoomCode)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    'Code: ${widget.gameCode}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            if (_isWaitingForOpponent)
              const Column(children: [CircularProgressIndicator(), SizedBox(height: 20), Text('Waiting for opponent to join...')])
            else
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Turn: ${_logic.turn}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 20),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(widget.isCreator ? "Playing as White" : "Playing as Black",
                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold))),
              ]),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ChessBoard(board: _logic.board, onSquareTap: _onSquareTap, selectedSquare: _selectedSquare, validMoves: _validMoves),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
