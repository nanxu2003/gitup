import 'package:flutter/material.dart';

/// A resilient image layer for scene and character artwork.
class GameArtLayer extends StatelessWidget {
  final String assetPath;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Widget? fallback;
  final double opacity;
  final Color? color;
  final BlendMode colorBlendMode;

  const GameArtLayer({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.fallback,
    this.opacity = 1,
    this.color,
    this.colorBlendMode = BlendMode.srcIn,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      key: ValueKey('game-art:$assetPath'),
      fit: fit,
      alignment: alignment,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: (context, error, stackTrace) =>
          fallback ?? const SizedBox.expand(),
    );
    return opacity == 1 ? image : Opacity(opacity: opacity, child: image);
  }
}
