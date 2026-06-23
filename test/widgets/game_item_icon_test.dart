import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgzb/widgets/game_item_icon.dart';

void main() {
  testWidgets('item icon selects an atlas cell and renders rarity frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 72,
            height: 72,
            child: GameItemIcon(
              item: GameItemArt.jade,
              rarity: GameItemRarity.epic,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('item-atlas-jade')), findsOneWidget);
    expect(find.byKey(const ValueKey('item-rarity-epic')), findsOneWidget);
  });
}
