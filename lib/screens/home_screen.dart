import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/constants.dart';
import '../app/game_art.dart';
import '../models/game_save.dart';
import '../models/item.dart';
import '../services/save_service.dart';
import '../services/resource_service.dart';
import '../widgets/login_reward_overlay.dart';
import '../widgets/game_backdrop_scaffold.dart';
import '../widgets/resource_bar.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  final GameSave gameSave;
  final SaveService saveService;

  const HomeScreen({
    super.key,
    required this.gameSave,
    required this.saveService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GameSave _save;
  bool _loginRewardScheduled = false;

  @override
  void initState() {
    super.initState();
    _save = widget.gameSave;
    WidgetsBinding.instance.addPostFrameCallback((_) => _showLoginReward());
  }

  void _showLoginReward() {
    if (!mounted || _loginRewardScheduled) return;
    final rewardDay = _save.player.day.clamp(1, 3);
    final claimedDays = <int>{
      for (var day = 1; day <= 3; day++)
        if (_save.storyFlags['login_reward_day_$day'] == true) day,
    };
    if (claimedDays.contains(rewardDay)) return;
    _loginRewardScheduled = true;

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 420),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return LoginRewardOverlay(
          currentDay: rewardDay,
          claimedDays: claimedDays,
          onClose: () => Navigator.of(dialogContext).pop(),
          onClaim: () {
            _claimLoginReward(rewardDay);
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  void _claimLoginReward(int day) {
    if (_save.storyFlags['login_reward_day_$day'] == true) return;
    const coinRewards = [0, 600, 1200, 2000];
    const grainRewards = [0, 300, 600, 1000];
    _save.player.resources['coin'] =
        (_save.player.resources['coin'] ?? 0) + coinRewards[day];
    _save.player.resources['grain'] =
        (_save.player.resources['grain'] ?? 0) + grainRewards[day];
    _save.player.reputation += day * 5;
    if (day == 1) {
      final existing = _save.inventory
          .where((item) => item.id == 'recruit_token')
          .firstOrNull;
      if (existing == null) {
        _save.inventory.add(
          GameItem(
            id: 'recruit_token',
            name: '招募令',
            description: '用于高级招募。',
            quality: Quality.purple,
          ),
        );
      } else {
        existing.quantity += 1;
      }
    }
    _save.storyFlags['login_reward_day_$day'] = true;
    setState(() {});
    widget.saveService.autoSave(_save);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已领取第$day日豪礼'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deployedCount = _save.generals.where((g) => g.isDeployed).length;
    final activeQuestCount = _save.quests
        .where((q) => q.status == QuestStatus.active && q.isComplete)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_save.player.cityName}城'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 22),
            tooltip: '设置',
            onPressed: () => _navigateTo('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.save, size: 22),
            tooltip: '保存游戏',
            onPressed: () async {
              await widget.saveService.autoSave(_save);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('游戏已保存'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
          ),
        ],
      ),
      body: GamePageBackdrop(
        backgroundAsset: GameArt.recruitHallBackground,
        child: Column(
          children: [
            ResourceBar(resources: _save.player.resources),
            // 城池信息条
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withValues(alpha: 0.6),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFF4A3F30), width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoItem('第 ${_save.player.day} 日', Icons.calendar_today),
                  _infoItem('Lv.${_save.player.level}', Icons.star),
                  _infoItem('民心 ${_save.player.morale}', Icons.favorite),
                  _infoItem(
                    '声望 ${_save.player.reputation}',
                    Icons.emoji_events,
                  ),
                ],
              ),
            ),
            // 主功能区（九宫格）
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    const SectionHeader(title: '城池政务'),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.15,
                      children: [
                        _gridButton(
                          '内政治理',
                          Icons.gavel,
                          AppTheme.accentColor,
                          () => _navigateTo('/politics'),
                        ),
                        _gridButton(
                          '城池建设',
                          Icons.castle,
                          Colors.brown,
                          () => _navigateTo('/city'),
                        ),
                        _gridButton(
                          '招募贤才',
                          Icons.person_add,
                          Colors.purple,
                          () => _navigateTo('/recruit'),
                        ),
                        _gridButton(
                          '出征讨伐',
                          Icons.map,
                          AppTheme.dangerColor,
                          () => _navigateTo('/world_map'),
                        ),
                        _gridButton(
                          '随机事件',
                          Icons.auto_stories,
                          Colors.cyan,
                          () => _navigateTo('/story_event'),
                        ),
                        _gridButton(
                          '任务列表',
                          Icons.list_alt,
                          AppTheme.successColor,
                          () => _navigateTo('/quests'),
                          badge: activeQuestCount > 0
                              ? '$activeQuestCount'
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 城池概况
                    const SectionHeader(title: '城池概况'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF4A3F30),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.menu_book,
                                size: 16,
                                color: AppTheme.accentColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '第${_save.player.chapter}章 · ${_chapterName(_save.player.chapter)}',
                                style: const TextStyle(
                                  color: AppTheme.accentColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.bolt,
                                      size: 14,
                                      color: AppTheme.accentColor,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '行动点 ${_save.player.actionPoints}/${_save.player.maxActionPoints}',
                                      style: const TextStyle(
                                        color: AppTheme.accentColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _getCityDescription(),
                            style: TextStyle(
                              color: AppTheme.textColor.withValues(alpha: 0.9),
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _statChip(
                                '武将',
                                '${_save.generals.length}人',
                                Colors.cyan,
                              ),
                              const SizedBox(width: 8),
                              _statChip(
                                '上阵',
                                '$deployedCount人',
                                AppTheme.successColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // 底部导航：快捷功能入口（与九宫格不重复）
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) {
          switch (i) {
            case 0:
              _navigateTo('/generals');
              break;
            case 1:
              _navigateTo('/formation');
              break;
            case 2:
              _navigateTo('/inventory');
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: '武将'),
          const BottomNavigationBarItem(icon: Icon(Icons.grid_on), label: '布阵'),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: _save.inventory
                  .where((i) => i.quantity > 0)
                  .isNotEmpty,
              label: Text(
                '${_save.inventory.where((i) => i.quantity > 0).length}',
                style: const TextStyle(fontSize: 9),
              ),
              child: const Icon(Icons.inventory_2),
            ),
            label: '背包',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _endDay,
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(
          Icons.nights_stay,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        label: const Text(
          '结束一天',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.accentColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: TextStyle(
              color: color.withValues(alpha: 0.85),
              fontSize: 12,
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
    );
  }

  Widget _gridButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(String route) async {
    final result = await Navigator.of(
      context,
    ).pushNamed(route, arguments: _save);
    setState(() {});
    widget.saveService.autoSave(_save);
    if (result is GameSave) {
      setState(() => _save = result);
    }
  }

  void _endDay() {
    final income = ResourceService.calculateDailyIncome(
      _save.buildings,
      _save.player.morale,
    );
    _save.player = ResourceService.addResources(_save.player, income);
    _save.player.day++;
    _save.player.actionPoints = _save.player.maxActionPoints;

    for (final b in _save.buildings) {
      if (b.isUpgrading && b.upgradeEndTime != null) {
        if (DateTime.now().isAfter(b.upgradeEndTime!)) {
          b.level++;
          b.isUpgrading = false;
          b.upgradeEndTimeStr = null;
        }
      }
    }

    for (final q in _save.quests) {
      if (q.status == QuestStatus.locked &&
          _save.player.level >= q.requiredLevel) {
        q.status = QuestStatus.active;
      }
    }

    setState(() {});
    widget.saveService.autoSave(_save);

    _showDaySummary(_save.player.day, income);
  }

  void _showDaySummary(int day, Map<String, int> income) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部装饰条 + 标题
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.nights_stay,
                        color: AppTheme.accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '第$day日开始',
                          style: const TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '新的一天已经到来',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: AppTheme.accentColor.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 12),
                // 收入标题
                const Text(
                  '今日结算收入',
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                // 收入明细
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.accentColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _incomeItem('💰', '铜钱', income['coin'] ?? 0),
                      _incomeItem('🌾', '粮草', income['grain'] ?? 0),
                      _incomeItem('🌳', '木材', income['wood'] ?? 0),
                      _incomeItem('⛏️', '铁矿', income['iron'] ?? 0),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 关闭按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '继续',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _incomeItem(String emoji, String label, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '+$value',
          style: const TextStyle(
            color: AppTheme.accentColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _chapterName(int chapter) {
    const names = {1: '黄巾乱起', 2: '董卓入京', 3: '群雄割据', 4: '赤壁之战', 5: '问鼎天下'};
    return names[chapter] ?? '未知';
  }

  String _getCityDescription() {
    final morale = _save.player.morale;
    if (morale >= 80) {
      return '城中百姓安居乐业，民心归附。\n街市繁华，士兵巡逻有序，城防坚固。';
    } else if (morale >= 50) {
      return '烽烟四起，百姓流离。你站在城楼上，远处黄尘滚滚。\n斥候来报：贼众已在十里之外！';
    } else if (morale >= 30) {
      return '城中粮草不足，百姓怨声载道。\n士兵士气低落，需尽快整顿内政。';
    } else {
      return '城池岌岌可危，民心尽失。\n若不尽快采取措施，恐生变故！';
    }
  }
}
