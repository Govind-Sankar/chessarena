import 'package:flutter/material.dart';
import 'package:chess/chess.dart' as chess_lib;
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';

class ChessBoard extends StatelessWidget {
  final List<List<chess_lib.Piece?>> board;
  final Function(int row, int col) onSquareTap;
  final List<int>? selectedSquare;
  final List<String> validMoves;

  const ChessBoard({
    super.key,
    required this.board,
    required this.onSquareTap,
    this.selectedSquare,
    this.validMoves = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Fixed slate/blue-grey theme for the board
    // final darkSquareColor = Colors.blueGrey[800]!;
    // final lightSquareColor = Colors.blueGrey[300]!;
    // final selectedColor = Colors.amber[600]!;
    final darkSquareColor = theme.colorScheme.primary;
    final lightSquareColor = theme.colorScheme.primary.withOpacity(0.3);
    final selectedColor = theme.colorScheme.secondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        double boardSize = constraints.maxWidth;
        double squareSize = boardSize / 8;

        return Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            border: Border.all(color: darkSquareColor.withOpacity(0.5), width: 4),
            borderRadius: BorderRadius.circular(4),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
            ),
            itemCount: 64,
            itemBuilder: (context, index) {
              int row = index ~/ 8;
              int col = index % 8;
              bool isDarkSquare = (row + col) % 2 == 1;
              var piece = board[row][col];
              bool isSelected = selectedSquare != null &&
                  selectedSquare![0] == row &&
                  selectedSquare![1] == col;

              String squareAlgebraic = _coordsToAlgebraic(row, col);
              bool isValidMove = validMoves.contains(squareAlgebraic);
              bool isCapture = isValidMove && piece != null;

              return GestureDetector(
                onTap: () => onSquareTap(row, col),
                child: Container(
                  color: isSelected
                      ? selectedColor.withOpacity(0.8)
                      : (isDarkSquare ? darkSquareColor : lightSquareColor),
                  child: Stack(
                    children: [
                      Center(
                        child: piece != null
                            ? _getPieceWidget(piece, squareSize * 0.8)
                            : null,
                      ),
                      if (isValidMove)
                        Center(
                          child: isCapture
                              ? Container(
                                  width: squareSize * 0.8,
                                  height: squareSize * 0.8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.redAccent.withOpacity(0.8),
                                      width: 4,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: squareSize * 0.25,
                                  height: squareSize * 0.25,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _coordsToAlgebraic(int row, int col) {
    String file = String.fromCharCode('a'.codeUnitAt(0) + col);
    String rank = (8 - row).toString();
    return '$file$rank';
  }

  Widget _getPieceWidget(chess_lib.Piece piece, double size) {
    if (piece.color == chess_lib.Color.WHITE) {
      switch (piece.type) {
        case chess_lib.PieceType.PAWN: return WhitePawn(size: size);
        case chess_lib.PieceType.ROOK: return WhiteRook(size: size);
        case chess_lib.PieceType.KNIGHT: return WhiteKnight(size: size);
        case chess_lib.PieceType.BISHOP: return WhiteBishop(size: size);
        case chess_lib.PieceType.QUEEN: return WhiteQueen(size: size);
        case chess_lib.PieceType.KING: return WhiteKing(size: size);
        default: return const SizedBox.shrink();
      }
    } else {
      switch (piece.type) {
        case chess_lib.PieceType.PAWN: return BlackPawn(size: size);
        case chess_lib.PieceType.ROOK: return BlackRook(size: size);
        case chess_lib.PieceType.KNIGHT: return BlackKnight(size: size);
        case chess_lib.PieceType.BISHOP: return BlackBishop(size: size);
        case chess_lib.PieceType.QUEEN: return BlackQueen(size: size);
        case chess_lib.PieceType.KING: return BlackKing(size: size);
        default: return const SizedBox.shrink();
      }
    }
  }
}
