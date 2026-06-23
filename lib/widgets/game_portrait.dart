import 'package:flutter/material.dart';

import '../app/game_ui_art.dart';
import 'game_atlas_cell.dart';

class GamePortrait extends StatelessWidget {
  final int index;
  final String? name;
  final Color qualityColor;
  final double size;

  const GamePortrait({
    super.key,
    required this.index,
    this.name,
    this.qualityColor = const Color(0xFFD4A017),
    this.size = 64,
  }) : assert(index >= 0 && index < 12);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: ValueKey('general-portrait-$index'),
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFF160B08),
              border: Border.all(color: qualityColor, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: qualityColor.withValues(alpha: 0.35),
                  blurRadius: 9,
                ),
              ],
            ),
            child: GameAtlasCell(
              assetPath: GameUiArt.generalPortraits,
              columns: 4,
              rows: 3,
              index: index,
              fallback: const Icon(Icons.person, color: Color(0xFFD4A017)),
            ),
          ),
          if (name != null) ...[
            const SizedBox(height: 3),
            Text(
              name!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFFFE7AF),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
