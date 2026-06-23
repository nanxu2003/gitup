import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgzb/app/game_art.dart';
import 'package:sgzb/widgets/game_art_layer.dart';

void main() {
  testWidgets('game art layer exposes a semantic image key', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: GameArtLayer(assetPath: GameArt.mapGuide)),
    );

    expect(
      find.byKey(const ValueKey('game-art:${GameArt.mapGuide}')),
      findsOneWidget,
    );
  });

  testWidgets('game art layer shows fallback when loading fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GameArtLayer(
          assetPath: 'assets/images/missing.png',
          fallback: ColoredBox(
            key: ValueKey('art-fallback'),
            color: Colors.red,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('art-fallback')), findsOneWidget);
  });
}
