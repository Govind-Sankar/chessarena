import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import '../logic/chess_game_logic.dart';
import '../widgets/chess_board.dart';

class GameScreen extends StatefulWidget {
  final int difficulty;
  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ChessGameLogic _logic = ChessGameLogic();
  List<int>? _selectedSquare;
  List<String> _validMoves = [];
  late int _difficultyDepth;

  @override
  void initState() {
    super.initState();
    _difficultyDepth = widget.difficulty;
  }

  void _onSquareTap(int row, int col) {
    if (_logic.turnColor == chess_lib.Color.BLACK) return; 

    setState(() {
      String currentSquare = _coordsToAlgebraic(row, col);
      if (_selectedSquare == null) {
        var piece = _logic.board[row][col];
        if (piece != null && piece.color == chess_lib.Color.WHITE) {
          _selectedSquare = [row, col];
          _validMoves = _logic.getValidMoves(currentSquare);
        }
      } else {
        String from = _coordsToAlgebraic(_selectedSquare![0], _selectedSquare![1]);
        bool isValidMove = _validMoves.contains(currentSquare);

        if (isValidMove) {
          bool success = _logic.makeMove(from, currentSquare);
          if (success) {
            _clearSelection();
            if (_logic.isGameOver) {
              _showGameOverDialog();
            } else {
              Future.delayed(const Duration(milliseconds: 500), _makeAiMove);
            }
          }
        } else {
          var piece = _logic.board[row][col];
          if (piece != null && piece.color == chess_lib.Color.WHITE) {
            _selectedSquare = [row, col];
            _validMoves = _logic.getValidMoves(currentSquare);
          } else {
            _clearSelection();
          }
        }
      }
    });
  }

  void _makeAiMove() {
    if (!mounted) return;
    setState(() {
      _logic.makeAiMove(depth: _difficultyDepth);
      if (_logic.isGameOver) {
        _showGameOverDialog();
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
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quit Game?', textAlign: TextAlign.center),
            content: const Text(
              'Your progress will not be saved. Are you sure you want to quit?',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Winner: ${_logic.game.turn == chess_lib.Color.WHITE ? 'Black' : 'White'}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _logic.reset();
                _clearSelection();
              });
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Home'),
          ),
        ],
      ),
    );
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
          title: const Text('Singleplayer'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _logic.reset();
                  _clearSelection();
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Turn: ${_logic.turn}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _difficultyDepth == 1 ? "Easy" : _difficultyDepth == 2 ? "Medium" : "Hard",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ChessBoard(
                board: _logic.board,
                onSquareTap: _onSquareTap,
                selectedSquare: _selectedSquare,
                validMoves: _validMoves,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
