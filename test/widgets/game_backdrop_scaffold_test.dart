import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgzb/app/game_art.dart';
import 'package:sgzb/widgets/game_backdrop_scaffold.dart';

void main() {
  testWidgets(
    'backdrop scaffold composes background, safe body and foreground',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GameBackdropScaffold(
            backgroundAsset: GameArt.recruitHallBackground,
            foreground: [Text('前景角色')],
            body: Text('页面内容'),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('game-backdrop')), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.text('页面内容'), findsOneWidget);
      expect(find.text('前景角色'), findsOneWidget);
    },
  );

  testWidgets('page backdrop keeps existing body above the art', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GamePageBackdrop(
            backgroundAsset: GameArt.worldMapBackground,
            child: Text('原页面内容'),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('page-backdrop:${GameArt.worldMapBackground}')),
      findsOneWidget,
    );
    expect(find.text('原页面内容'), findsOneWidget);
  });
}
