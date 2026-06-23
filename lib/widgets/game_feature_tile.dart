import 'package:flutter/material.dart';

import '../app/game_ui_art.dart';
import 'game_atlas_cell.dart';
import 'game_surface.dart';

enum GameFeatureIcon {
  government,
  construction,
  recruit,
  expedition,
  storyEvent,
  quests,
  generals,
  formation,
  inventory,
  settings,
  grain,
  coins,
  timber,
  iron,
  soldiers,
  save,
  calendar,
  morale,
  reputation,
  help,
}

class GameFeatureTile extends StatefulWidget {
  final GameFeatureIcon icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final VoidCallback? onTap;
  final double iconSize;

  const GameFeatureTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.onTap,
    this.iconSize = 78,
  });

  @override
  State<GameFeatureTile> createState() => _GameFeatureTileState();
}

class _GameFeatureTileState extends State<GameFeatureTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = false),
        onTapCancel: widget.onTap == null
            ? null
            : () => setState(() => _pressed = false),
        child: GameSurface(
          style: GameSurfaceStyle.lacquer,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 9),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox.square(
                    dimension: widget.iconSize,
                    child: GameAtlasCell(
                      key: ValueKey('feature-icon-${widget.icon.name}'),
                      assetPath: GameUiArt.featureIcons,
                      columns: 5,
                      rows: 4,
                      index: widget.icon.index,
                      fallback: Icon(
                        Icons.shield,
                        color: const Color(0xFFD4A017),
                        size: widget.iconSize * 0.55,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFFE7AF),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFC5B6A6),
                        fontSize: 9,
                      ),
                    ),
                ],
              ),
              if (widget.badge != null)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 22,
                      minHeight: 22,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD73A24),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD477)),
                      boxShadow: const [
                        BoxShadow(color: Color(0xAAFF3D1F), blurRadius: 8),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
