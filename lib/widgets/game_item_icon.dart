import 'package:flutter/material.dart';

import '../app/game_art.dart';

enum GameItemArt {
  recruitOrder,
  ingot,
  jade,
  helmet,
  scroll,
  crystal,
  chest,
  coin,
}

enum GameItemRarity { common, rare, epic, legendary }

class GameItemIcon extends StatelessWidget {
  final GameItemArt item;
  final GameItemRarity rarity;
  final EdgeInsets padding;

  const GameItemIcon({
    super.key,
    required this.item,
    this.rarity = GameItemRarity.rare,
    this.padding = const EdgeInsets.all(5),
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (rarity) {
      GameItemRarity.common => const Color(0xFFC7BBA8),
      GameItemRarity.rare => const Color(0xFF46D2DF),
      GameItemRarity.epic => const Color(0xFFD36CFF),
      GameItemRarity.legendary => const Color(0xFFFFB642),
    };
    return DecoratedBox(
      key: ValueKey('item-rarity-${rarity.name}'),
      decoration: BoxDecoration(
        color: const Color(0xB3150B0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.42), blurRadius: 10),
          const BoxShadow(color: Colors.black87, blurRadius: 8),
        ],
      ),
      child: Padding(
        padding: padding,
        child: _AtlasCell(item: item),
      ),
    );
  }
}

class _AtlasCell extends StatelessWidget {
  final GameItemArt item;

  const _AtlasCell({required this.item});

  @override
  Widget build(BuildContext context) {
    final index = item.index;
    final column = index % 4;
    final row = index ~/ 4;
    final horizontal = -1 + (column * 2 / 3);
    final vertical = row == 0 ? -1.0 : 1.0;

    return ClipRect(
      child: Align(
        alignment: Alignment(horizontal, vertical),
        widthFactor: 0.25,
        heightFactor: 0.5,
        child: Image.asset(
          GameArt.rewardItems,
          key: ValueKey('item-atlas-${item.name}'),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
