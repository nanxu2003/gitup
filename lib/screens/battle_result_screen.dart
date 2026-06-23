import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/game_art.dart';
import '../models/battle.dart';
import '../models/game_save.dart';
import '../widgets/styled_button.dart';
import '../widgets/section_header.dart';
import '../widgets/game_backdrop_scaffold.dart';

class BattleResultScreen extends StatefulWidget {
  final BattleResult result;
  final GameSave gameSave;
  final String stageId;

  const BattleResultScreen({
    super.key,
    required this.result,
    required this.gameSave,
    required this.stageId,
  });

  @override
  State<BattleResultScreen> createState() => _BattleResultScreenState();
}

class _BattleResultScreenState extends State<BattleResultScreen> {
  late GameSave _save;

  @override
  void initState() {
    super.initState();
    _save = widget.gameSave;
    _applyRewards();
  }

  void _applyRewards() {
    if (!widget.result.isVictory) return;

    // 加资源
    _save.player.resources['coin'] =
        (_save.player.resources['coin'] ?? 0) + widget.result.coinGained;
    _save.player.exp += widget.result.expGained;
    _save.player.reputation += widget.result.reputationGained;

    // 更新关卡完成状态
    for (final chapter in _save.chapters) {
      for (final stage in chapter.stages) {
        if (stage.id == widget.stageId) {
          stage.isCompleted = true;
          stage.starsEarned = widget.result.rounds <= 5
              ? 3
              : widget.result.rounds <= 10
              ? 2
              : 1;
        }
      }
    }

    // 更新任务进度
    for (final quest in _save.quests) {
      for (final obj in quest.objectives) {
        if (obj.type == 'battle' && obj.targetId == widget.stageId) {
          obj.currentCount++;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return Scaffold(
      body: GamePageBackdrop(
        backgroundAsset: GameArt.battlefieldBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Icon(
                  r.isVictory
                      ? Icons.emoji_events
                      : Icons.sentiment_dissatisfied,
                  size: 64,
                  color: r.isVictory
                      ? AppTheme.accentColor
                      : AppTheme.dangerColor,
                ),
                const SizedBox(height: 12),
                Text(
                  r.isVictory ? '战斗胜利！' : '战斗失败',
                  style: TextStyle(
                    color: r.isVictory
                        ? AppTheme.accentColor
                        : AppTheme.dangerColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (r.isVictory) ...[
                  const SizedBox(height: 8),
                  Text(
                    '★' *
                        (r.rounds <= 5
                            ? 3
                            : r.rounds <= 10
                            ? 2
                            : 1),
                    style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 24,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const SectionHeader(title: '战斗数据'),
                _statRow('战斗回合', '${r.rounds}'),
                _statRow('MVP', r.mvpName),
                _statRow('造成伤害', '${r.totalDamage}'),
                _statRow('承受伤害', '${r.totalTaken}'),
                if (r.isVictory) ...[
                  const SizedBox(height: 8),
                  const SectionHeader(title: '获得奖励'),
                  _statRow('经验', '+${r.expGained}'),
                  _statRow('铜钱', '+${r.coinGained}'),
                  _statRow('声望', '+${r.reputationGained}'),
                ],
                if (!r.isVictory && r.failureReasons.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const SectionHeader(title: '失败分析'),
                  ...r.failureReasons.map(
                    (reason) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            reason,
                            style: const TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SectionHeader(title: '提升建议'),
                  ...r.suggestions.map(
                    (s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            size: 14,
                            color: AppTheme.accentColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s,
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StyledButton(
                      text: '返回',
                      icon: Icons.home,
                      onPressed: () {
                        // pop回世界地图，世界地图会刷新状态
                        Navigator.of(context).pop(_save);
                      },
                    ),
                    if (r.isVictory) ...[
                      const SizedBox(width: 16),
                      StyledButton(
                        text: '确定',
                        icon: Icons.check,
                        onPressed: () {
                          Navigator.of(context).pop(_save);
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
