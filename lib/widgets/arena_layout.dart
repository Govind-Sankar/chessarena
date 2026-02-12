import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ArenaLayout extends StatelessWidget {
  final Widget child;

  const ArenaLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 120),
            Row(
              children: [
                Icon(
                  Symbols.chess_knight,
                  size: 128,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CHESS',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                      ),
                    ),
                    Text(
                      'ARENA',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 80),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: child,
              ),
            ),
            const Text(
              'Made with ♡ by Govind Sankar',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
