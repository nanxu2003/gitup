import 'package:flutter/material.dart';

/// Displays one cell from a regularly spaced raster atlas.
class GameAtlasCell extends StatelessWidget {
  final String assetPath;
  final int columns;
  final int rows;
  final int index;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Widget? fallback;

  const GameAtlasCell({
    super.key,
    required this.assetPath,
    required this.columns,
    required this.rows,
    required this.index,
    this.fit = BoxFit.fill,
    this.alignment = Alignment.center,
    this.fallback,
  }) : assert(columns > 0),
       assert(rows > 0),
       assert(index >= 0),
       assert(index < columns * rows);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
          return fallback ?? const SizedBox.shrink();
        }
        final cellWidth = constraints.maxWidth;
        final cellHeight = constraints.maxHeight;
        final column = index % columns;
        final row = index ~/ columns;

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: -column * cellWidth,
                top: -row * cellHeight,
                width: cellWidth * columns,
                height: cellHeight * rows,
                child: Image.asset(
                  assetPath,
                  key: ValueKey('atlas-$assetPath-$index'),
                  fit: fit,
                  alignment: alignment,
                  errorBuilder: (context, error, stackTrace) => SizedBox(
                    width: cellWidth * columns,
                    height: cellHeight * rows,
                    child:
                        fallback ?? const ColoredBox(color: Color(0xFF24120F)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
