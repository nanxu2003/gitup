import 'package:flutter/material.dart';

import 'game_art_layer.dart';

/// Adds an image background beneath the existing body of a regular [Scaffold].
class GamePageBackdrop extends StatelessWidget {
  final String backgroundAsset;
  final Widget child;
  final AlignmentGeometry backgroundAlignment;
  final List<Color> scrimColors;
  final List<double>? scrimStops;

  const GamePageBackdrop({
    super.key,
    required this.backgroundAsset,
    required this.child,
    this.backgroundAlignment = Alignment.center,
    this.scrimColors = const [Color(0xAD120908), Color(0xD91A100E)],
    this.scrimStops,
  });

  const GamePageBackdrop.reading({
    super.key,
    required this.backgroundAsset,
    required this.child,
    this.backgroundAlignment = Alignment.center,
  }) : scrimColors = const [Color(0xE8110A09), Color(0xF21A100E)],
       scrimStops = null;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: ValueKey('page-backdrop:$backgroundAsset'),
      fit: StackFit.expand,
      children: [
        GameArtLayer(
          assetPath: backgroundAsset,
          fit: BoxFit.cover,
          alignment: backgroundAlignment,
          fallback: const ColoredBox(color: Color(0xFF160C0A)),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: scrimColors,
              stops: scrimStops,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Shared full-screen composition used by image-backed game pages.
class GameBackdropScaffold extends StatelessWidget {
  final String backgroundAsset;
  final Widget body;
  final List<Widget> foreground;
  final List<Color> scrimColors;
  final List<double>? scrimStops;
  final AlignmentGeometry backgroundAlignment;
  final bool useSafeArea;
  final bool resizeToAvoidBottomInset;

  const GameBackdropScaffold({
    super.key,
    required this.backgroundAsset,
    required this.body,
    this.foreground = const [],
    this.scrimColors = const [
      Color(0xB3140908),
      Color(0x26000000),
      Color(0xD9140908),
    ],
    this.scrimStops = const [0, 0.48, 1],
    this.backgroundAlignment = Alignment.center,
    this.useSafeArea = true,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = useSafeArea ? SafeArea(child: body) : body;
    return Scaffold(
      backgroundColor: const Color(0xFF100706),
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Stack(
        key: const ValueKey('game-backdrop'),
        fit: StackFit.expand,
        children: [
          GameArtLayer(
            assetPath: backgroundAsset,
            fit: BoxFit.cover,
            alignment: backgroundAlignment,
            fallback: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF472014), Color(0xFF100706)],
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: scrimColors,
                stops: scrimStops,
              ),
            ),
          ),
          ...foreground,
          content,
        ],
      ),
    );
  }
}
