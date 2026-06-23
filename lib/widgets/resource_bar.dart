import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/game_ui_art.dart';
import 'game_atlas_cell.dart';
import 'game_feature_tile.dart';
import 'game_surface.dart';

class ResourceBar extends StatelessWidget {
  final Map<String, int> resources;

  const ResourceBar({super.key, required this.resources});

  @override
  Widget build(BuildContext context) {
    return GameSurface(
      style: GameSurfaceStyle.iron,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: SizedBox(
        height: 48,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _resourceItem(
                GameFeatureIcon.coins,
                '铜钱',
                resources['coin'] ?? 0,
                const Color(0xFFFFD54F),
              ),
              _resourceItem(
                GameFeatureIcon.grain,
                '粮草',
                resources['grain'] ?? 0,
                const Color(0xFF81C784),
              ),
              _resourceItem(
                GameFeatureIcon.timber,
                '木材',
                resources['wood'] ?? 0,
                const Color(0xFFCFB49B),
              ),
              _resourceItem(
                GameFeatureIcon.iron,
                '铁矿',
                resources['iron'] ?? 0,
                const Color(0xFFB0BEC5),
              ),
              _resourceItem(
                GameFeatureIcon.soldiers,
                '兵力',
                resources['soldiers'] ?? 0,
                const Color(0xFFFF9F8D),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resourceItem(
    GameFeatureIcon icon,
    String label,
    int value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 34,
            child: GameAtlasCell(
              assetPath: GameUiArt.featureIcons,
              columns: 5,
              rows: 4,
              index: icon.index,
              fallback: Icon(Icons.circle, color: color, size: 18),
            ),
          ),
          const SizedBox(width: 5),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 9,
                ),
              ),
              Text(
                _formatNumber(value),
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}万';
    return '$n';
  }
}
