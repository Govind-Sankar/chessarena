import 'package:chess/chess.dart' as chess_lib;

class ChessGameLogic {
  late chess_lib.Chess game;

  ChessGameLogic() {
    game = chess_lib.Chess();
  }

  List<List<chess_lib.Piece?>> get board {
    List<List<chess_lib.Piece?>> board = List.generate(8, (_) => List.generate(8, (_) => null));
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        String square = String.fromCharCode('a'.codeUnitAt(0) + c) + (8 - r).toString();
        board[r][c] = game.get(square);
      }
    }
    return board;
  }

  List<String> getValidMoves(String square) {
    var moves = game.generate_moves({'square': square});
    return moves.map((m) => m.toAlgebraic).toList();
  }

  bool makeMove(String from, String to) {
    bool moved = game.move({'from': from, 'to': to});
    return moved;
  }

  void makeAiMove({int depth = 2}) {
    var moves = game.moves();
    if (moves.isEmpty) return;

    dynamic bestMove;
    int bestValue = -99999;
    int alpha = -100000;
    int beta = 100000;

    moves.shuffle();

    for (var move in moves) {
      game.move(move);
      int boardValue = _minimax(depth - 1, alpha, beta, false);
      game.undo();

      if (boardValue > bestValue) {
        bestValue = boardValue;
        bestMove = move;
      }
      if (boardValue > alpha) alpha = boardValue;
    }

    if (bestMove != null) {
      game.move(bestMove);
    }
  }

  int _minimax(int depth, int alpha, int beta, bool isMaximizingPlayer) {
    if (depth == 0 || game.game_over) {
      return -_evaluateBoard();
    }

    var moves = game.moves();

    if (isMaximizingPlayer) {
      int bestValue = -99999;
      for (var move in moves) {
        game.move(move);
        bestValue = _max(bestValue, _minimax(depth - 1, alpha, beta, !isMaximizingPlayer));
        game.undo();
        alpha = _max(alpha, bestValue);
        if (beta <= alpha) return bestValue;
      }
      return bestValue;
    } else {
      int bestValue = 99999;
      for (var move in moves) {
        game.move(move);
        bestValue = _min(bestValue, _minimax(depth - 1, alpha, beta, !isMaximizingPlayer));
        game.undo();
        beta = _min(beta, bestValue);
        if (beta <= alpha) return bestValue;
      }
      return bestValue;
    }
  }

  int _max(int a, int b) => a > b ? a : b;
  int _min(int a, int b) => a < b ? a : b;

  int _evaluateBoard() {
    int totalEvaluation = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        String square = String.fromCharCode('a'.codeUnitAt(0) + c) + (8 - r).toString();
        var piece = game.get(square);
        if (piece != null) {
          totalEvaluation += _getPieceValue(piece.type, piece.color);
        }
      }
    }
    return totalEvaluation;
  }

  int _getPieceValue(chess_lib.PieceType type, chess_lib.Color color) {
    int value = 0;
    switch (type) {
      case chess_lib.PieceType.PAWN: value = 100; break;
      case chess_lib.PieceType.KNIGHT: value = 320; break;
      case chess_lib.PieceType.BISHOP: value = 330; break;
      case chess_lib.PieceType.ROOK: value = 500; break;
      case chess_lib.PieceType.QUEEN: value = 900; break;
      case chess_lib.PieceType.KING: value = 20000; break;
    }
    return color == chess_lib.Color.WHITE ? value : -value;
  }

  bool get isGameOver => game.game_over;
  String? get turn => game.turn == chess_lib.Color.WHITE ? 'White' : 'Black';
  chess_lib.Color get turnColor => game.turn;

  void reset() {
    game = chess_lib.Chess();
  }
}
