import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/constants.dart';
import '../app/game_art.dart';
import '../models/game_save.dart';
import '../models/quest.dart';
import '../services/resource_service.dart';
import '../widgets/game_backdrop_scaffold.dart';

class QuestScreen extends StatefulWidget {
  final GameSave gameSave;

  const QuestScreen({super.key, required this.gameSave});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late GameSave _save;
  final _tabs = ['主线', '支线', '每日', '成就'];
  final _tabIcons = [
    Icons.flag,
    Icons.explore,
    Icons.today,
    Icons.emoji_events,
  ];

  String? _claimingId;

  @override
  void initState() {
    super.initState();
    _save = widget.gameSave;
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _countClaimable() => _save.quests
      .where((q) => q.isComplete && q.status == QuestStatus.active)
      .length;

  int _countCompleted() =>
      _save.quests.where((q) => q.status == QuestStatus.claimed).length;

  int _countActive() =>
      _save.quests.where((q) => q.status == QuestStatus.active).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('任务'),
        bottom: TabBar(
          controller: _tabController,
          tabs: List.generate(_tabs.length, (i) {
            final type = [
              QuestType.main,
              QuestType.side,
              QuestType.daily,
              QuestType.achievement,
            ][i];
            final count = _save.quests
                .where((q) => q.type == type && q.status == QuestStatus.active)
                .length;
            return Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_tabIcons[i], size: 16),
                  const SizedBox(width: 4),
                  Text(_tabs[i]),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ),
      body: GamePageBackdrop(
        backgroundAsset: GameArt.worldMapBackground,
        child: Column(
          children: [
            // 总览头部
            _buildSummaryHeader(),
            // 任务列表
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildQuestList(QuestType.main),
                  _buildQuestList(QuestType.side),
                  _buildQuestList(QuestType.daily),
                  _buildQuestList(QuestType.achievement),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final claimable = _countClaimable();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        border: Border(bottom: BorderSide(color: Color(0xFF4A3F30))),
      ),
      child: Row(
        children: [
          // 已完成数
          _summaryStat(
            Icons.check_circle,
            '已完成',
            '${_countCompleted()}',
            AppTheme.successColor,
          ),
          const SizedBox(width: 16),
          // 进行中
          _summaryStat(
            Icons.play_circle,
            '进行中',
            '${_countActive()}',
            Colors.orange,
          ),
          const SizedBox(width: 16),
          // 总数
          _summaryStat(
            Icons.list,
            '总任务',
            '${_save.quests.length}',
            AppTheme.textColor,
          ),
          const Spacer(),
          // 一键领取
          if (claimable > 0)
            ElevatedButton.icon(
              onPressed: _claimAll,
              icon: const Icon(Icons.card_giftcard, size: 16),
              label: Text(
                '一键领取($claimable)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryStat(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Column(
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
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestList(QuestType type) {
    final quests = _save.quests.where((q) => q.type == type).toList();
    if (quests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == QuestType.main
                  ? Icons.flag_outlined
                  : type == QuestType.side
                  ? Icons.explore_outlined
                  : type == QuestType.daily
                  ? Icons.today_outlined
                  : Icons.emoji_events_outlined,
              size: 56,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              '暂无${_tabs[[QuestType.main, QuestType.side, QuestType.daily, QuestType.achievement].indexOf(type)]}任务',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '继续游戏解锁更多任务',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: quests.length,
      itemBuilder: (ctx, i) => _buildQuestCard(quests[i]),
    );
  }

  Widget _buildQuestCard(Quest quest) {
    final isComplete = quest.isComplete;
    final isClaimable = isComplete && quest.status == QuestStatus.active;
    final isClaimed = quest.status == QuestStatus.claimed;
    final isLocked = quest.status == QuestStatus.locked;
    final typeColor = _questTypeColor(quest.type);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isClaimed ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isLocked
              ? AppTheme.cardColor.withValues(alpha: 0.6)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isClaimable
                ? AppTheme.successColor.withValues(alpha: 0.5)
                : isClaimed
                ? const Color(0xFF4A3F30)
                : typeColor.withValues(alpha: 0.3),
            width: isClaimable ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: typeColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      isClaimed
                          ? Icons.check_circle
                          : isLocked
                          ? Icons.lock
                          : _questTypeIcon(quest.type),
                      color: isClaimed
                          ? AppTheme.successColor
                          : isLocked
                          ? Colors.grey
                          : typeColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                quest.name,
                                style: TextStyle(
                                  color: isLocked
                                      ? AppTheme.textSecondaryColor
                                      : AppTheme.textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (quest.requiredLevel > 1 && isLocked)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  'Lv.${quest.requiredLevel}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          quest.description,
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 11,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _statusBadge(quest.status),
                ],
              ),

              // 目标进度
              if (!isLocked && quest.objectives.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...quest.objectives.map((obj) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          obj.isComplete
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: obj.isComplete
                              ? AppTheme.successColor
                              : AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _objectiveLabel(obj),
                                style: TextStyle(
                                  color: obj.isComplete
                                      ? AppTheme.successColor
                                      : AppTheme.textColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 3),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: obj.progress.clamp(0.0, 1.0),
                                  backgroundColor: const Color(0xFF333333),
                                  valueColor: AlwaysStoppedAnimation(
                                    obj.isComplete
                                        ? AppTheme.successColor
                                        : typeColor,
                                  ),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${obj.currentCount}/${obj.requiredCount}',
                          style: TextStyle(
                            color: obj.isComplete
                                ? AppTheme.successColor
                                : AppTheme.textSecondaryColor,
                            fontSize: 11,
                            fontWeight: obj.isComplete
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              // 奖励行 + 领取按钮
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      size: 14,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 4),
                    if (quest.rewards.coin > 0)
                      _rewardChip(
                        '💰${quest.rewards.coin}',
                        AppTheme.accentColor,
                      ),
                    if (quest.rewards.grain > 0)
                      _rewardChip(
                        '🌾${quest.rewards.grain}',
                        AppTheme.successColor,
                      ),
                    if (quest.rewards.exp > 0)
                      _rewardChip('⭐${quest.rewards.exp}', Colors.cyan),
                    if (quest.rewards.reputation > 0)
                      _rewardChip(
                        '🏆+${quest.rewards.reputation}',
                        Colors.purple,
                      ),
                    const Spacer(),
                    if (isClaimable)
                      AnimatedScale(
                        scale: _claimingId == quest.id ? 0.9 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: ElevatedButton(
                          onPressed: () => _claimReward(quest),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Text(
                            '领取',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    if (isClaimed)
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check,
                            size: 14,
                            color: AppTheme.successColor,
                          ),
                          SizedBox(width: 2),
                          Text(
                            '已领取',
                            style: TextStyle(
                              color: AppTheme.successColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _objectiveLabel(QuestObjective obj) {
    switch (obj.type) {
      case 'battle':
        return '通关关卡 ${obj.targetId}';
      case 'battle_total':
        return '完成${obj.requiredCount}场战斗';
      case 'recruit':
        return '招募${obj.requiredCount}名武将';
      case 'build':
        return '升级建筑${obj.requiredCount}次';
      case 'politics':
        return '进行${obj.requiredCount}次内政治理';
      case 'equip':
        return '装备${obj.requiredCount}件道具';
      case 'general_level':
        return '武将达到5级';
      case 'chapter_clear':
        return '通关第${obj.targetId}章';
      case 'generals_count':
        return '拥有${obj.requiredCount}名武将';
      case 'coin_reach':
        return '拥有${obj.requiredCount}铜钱';
      case 'tax':
        return '征收赋税${obj.requiredCount}次';
      default:
        return '完成目标 ${obj.currentCount}/${obj.requiredCount}';
    }
  }

  Widget _rewardChip(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(QuestStatus status) {
    const labels = {
      QuestStatus.locked: '未解锁',
      QuestStatus.active: '进行中',
      QuestStatus.completed: '可领取',
      QuestStatus.claimed: '已领取',
    };
    const colors = {
      QuestStatus.locked: Colors.grey,
      QuestStatus.active: Colors.orange,
      QuestStatus.completed: AppTheme.successColor,
      QuestStatus.claimed: AppTheme.textSecondaryColor,
    };
    final c = colors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: status == QuestStatus.completed
            ? Border.all(color: AppTheme.successColor.withValues(alpha: 0.5))
            : null,
      ),
      child: Text(
        labels[status] ?? '',
        style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _questTypeColor(QuestType type) {
    switch (type) {
      case QuestType.main:
        return AppTheme.dangerColor;
      case QuestType.side:
        return Colors.blue;
      case QuestType.daily:
        return AppTheme.successColor;
      case QuestType.achievement:
        return AppTheme.accentColor;
    }
  }

  IconData _questTypeIcon(QuestType type) {
    switch (type) {
      case QuestType.main:
        return Icons.flag;
      case QuestType.side:
        return Icons.explore;
      case QuestType.daily:
        return Icons.today;
      case QuestType.achievement:
        return Icons.emoji_events;
    }
  }

  void _claimReward(Quest quest) {
    setState(() => _claimingId = quest.id);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _applyReward(quest);
      setState(() => _claimingId = null);
      _showClaimedSnackBar(quest);
    });
  }

  void _claimAll() {
    final claimable = _save.quests
        .where((q) => q.isComplete && q.status == QuestStatus.active)
        .toList();

    if (claimable.isEmpty) return;

    int totalCoin = 0, totalGrain = 0, totalExp = 0, totalRep = 0;
    for (final q in claimable) {
      q.status = QuestStatus.claimed;
      totalCoin += q.rewards.coin;
      totalGrain += q.rewards.grain;
      totalExp += q.rewards.exp;
      totalRep += q.rewards.reputation;
    }

    setState(() {
      _save.player = ResourceService.addResources(_save.player, {
        'coin': totalCoin,
        'grain': totalGrain,
      });
      _save.player.exp += totalExp;
      _save.player.reputation += totalRep;
    });

    final parts = <String>[];
    if (totalCoin > 0) parts.add('铜钱+$totalCoin');
    if (totalGrain > 0) parts.add('粮草+$totalGrain');
    if (totalExp > 0) parts.add('经验+$totalExp');
    if (totalRep > 0) parts.add('声望+$totalRep');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '一键领取 ${claimable.length} 个任务奖励',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(parts.join('  '), style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _applyReward(Quest quest) {
    setState(() {
      quest.status = QuestStatus.claimed;
      _save.player = ResourceService.addResources(_save.player, {
        'coin': quest.rewards.coin,
        'grain': quest.rewards.grain,
      });
      _save.player.exp += quest.rewards.exp;
      _save.player.reputation += quest.rewards.reputation;
    });
  }

  void _showClaimedSnackBar(Quest quest) {
    final rewards = <String>[];
    if (quest.rewards.coin > 0) rewards.add('铜钱+${quest.rewards.coin}');
    if (quest.rewards.grain > 0) rewards.add('粮草+${quest.rewards.grain}');
    if (quest.rewards.exp > 0) rewards.add('经验+${quest.rewards.exp}');
    if (quest.rewards.reputation > 0) {
      rewards.add('声望+${quest.rewards.reputation}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '任务完成：${quest.name}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(rewards.join('  '), style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
