import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/constants.dart';
import '../models/general.dart';

class GeneralCard extends StatelessWidget {
  final General general;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showDeployed;

  const GeneralCard({
    super.key,
    required this.general,
    this.onTap,
    this.onLongPress,
    this.showDeployed = true,
  });

  @override
  Widget build(BuildContext context) {
    final qColor = qualityColors[general.quality] ?? AppTheme.textColor;
    final power = _calculatePower();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: qColor.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: qColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部区域：头像 + 品质渐变条
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(9),
                ),
                gradient: LinearGradient(
                  colors: [qColor.withValues(alpha: 0.15), AppTheme.cardColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  // 头像
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: qColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: qColor.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        general.name[0],
                        style: TextStyle(
                          color: qColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 名字 + 品质
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                general.name,
                                style: TextStyle(
                                  color: qColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: qColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                qualityNames[general.quality] ?? '',
                                style: TextStyle(
                                  color: qColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // 称号
                        Text(
                          general.title.isNotEmpty ? general.title : '—',
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 信息行
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  // 星级
                  Text(
                    '★' * general.star,
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  // 兵种标签
                  _miniTag(troopNames[general.troopType] ?? '', Colors.cyan),
                  const SizedBox(width: 4),
                  // 等级
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'Lv.${general.level}',
                      style: const TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 属性迷你条
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _miniStat('武', general.attributes.force, AppTheme.hpColor),
                  const SizedBox(width: 6),
                  _miniStat('智', general.attributes.intelligence, Colors.blue),
                  const SizedBox(width: 6),
                  _miniStat(
                    '统',
                    general.attributes.command,
                    AppTheme.accentColor,
                  ),
                ],
              ),
            ),

            // 经验条
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
              child: Row(
                children: [
                  const Text(
                    'EXP',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: (general.exp % 100) / 100.0,
                        backgroundColor: const Color(0xFF333333),
                        valueColor: AlwaysStoppedAnimation(
                          AppTheme.accentColor.withValues(alpha: 0.6),
                        ),
                        minHeight: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 底部：战力 + 上阵标记
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 13,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$power',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (showDeployed && general.isDeployed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.successColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        '已上阵',
                        style: TextStyle(
                          color: AppTheme.successColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 9)),
    );
  }

  Widget _miniStat(String label, int value, Color color) {
    return Expanded(
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: value / 100.0,
                backgroundColor: const Color(0xFF333333),
                valueColor: AlwaysStoppedAnimation(
                  color.withValues(alpha: 0.8),
                ),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 2),
          SizedBox(
            width: 20,
            child: Text(
              '$value',
              style: TextStyle(color: color, fontSize: 9),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  int _calculatePower() {
    return general.attackPower +
        general.defense +
        general.hp ~/ 10 +
        general.attributes.force +
        general.attributes.intelligence +
        general.attributes.command;
  }
}
