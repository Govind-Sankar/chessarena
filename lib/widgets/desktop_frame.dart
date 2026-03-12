import 'package:flutter/material.dart';

class DesktopFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double breakpoint;
  final Color? backgroundColor;

  const DesktopFrame({
    super.key,
    required this.child,
    this.maxWidth = 640,
    this.breakpoint = 900,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageColor = backgroundColor ?? theme.scaffoldBackgroundColor;
    final sideColor = Color.alphaBlend(
      theme.colorScheme.primary.withOpacity(0.08),
      pageColor,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return child;
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [sideColor, pageColor, sideColor],
            ),
          ),
          child: Center(
            child: SizedBox(
              width: maxWidth,
              height: constraints.maxHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: pageColor,
                  border: Border.symmetric(
                    vertical: BorderSide(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.35),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
