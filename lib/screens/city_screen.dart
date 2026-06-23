import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/constants.dart';
import '../app/game_art.dart';
import '../models/game_save.dart';
import '../models/building.dart';
import '../services/resource_service.dart';
import '../widgets/game_backdrop_scaffold.dart';

class CityScreen extends StatefulWidget {
  final GameSave gameSave;

  const CityScreen({super.key, required this.gameSave});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  late GameSave _save;
  String? _upgradingId;

  @override
  void initState() {
    super.initState();
    _save = widget.gameSave;
    _checkUpgrades();
  }

  void _checkUpgrades() {
    bool changed = false;
    for (final b in _save.buildings) {
      if (b.isUpgrading && b.upgradeEndTime != null) {
        if (DateTime.now().isAfter(b.upgradeEndTime!)) {
          b.level++;
          b.isUpgrading = false;
          b.upgradeEndTimeStr = null;
          changed = true;
        }
      }
    }
    if (changed && mounted) setState(() {});
  }

  int _getGovLevel() =>
      _save.buildings
          .where((b) => b.type == BuildingType.government)
          .firstOrNull
          ?.level ??
      0;

  int _getUpgradingCount() =>
      _save.buildings.where((b) => b.isUpgrading).length;

  int _getTotalLevel() =>
      _save.buildings.fold<int>(0, (sum, b) => sum + b.level);

  Map<String, int> _getDailyIncome() => ResourceService.calculateDailyIncome(
    _save.buildings,
    _save.player.morale,
  );

  @override
  Widget build(BuildContext context) {
    final govLevel = _getGovLevel();
    final totalLevel = _getTotalLevel();
    final upgrading = _getUpgradingCount();
    final income = _getDailyIncome();

    return Scaffold(
      appBar: AppBar(title: Text('${_save.player.cityName}城 · 建设')),
      body: GamePageBackdrop(
        backgroundAsset: GameArt.recruitHallBackground,
        child: Column(
          children: [
            // 城池总览头部
            _buildCityHeader(govLevel, totalLevel, upgrading),
            // 每日产出条
            _buildIncomeStrip(income),
            // 升级队列提示
            if (upgrading > 0) _buildUpgradeQueueBar(upgrading),
            // 建筑列表
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  _categoryHeader('资源产出', Icons.grain, AppTheme.successColor),
                  ..._buildingsOfType([
                    BuildingType.farm,
                    BuildingType.market,
                    BuildingType.lumberMill,
                    BuildingType.ironWorks,
                  ]),
                  const SizedBox(height: 8),
                  _categoryHeader('军事设施', Icons.shield, AppTheme.hpColor),
                  ..._buildingsOfType([
                    BuildingType.barracks,
                    BuildingType.wall,
                    BuildingType.trainingGround,
                  ]),
                  const SizedBox(height: 8),
                  _categoryHeader(
                    '民事建筑',
                    Icons.account_balance,
                    AppTheme.accentColor,
                  ),
                  ..._buildingsOfType([
                    BuildingType.government,
                    BuildingType.tavern,
                    BuildingType.blacksmith,
                    BuildingType.academy,
                    BuildingType.postStation,
                  ]),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildingsOfType(List<BuildingType> types) {
    return _save.buildings
        .where((b) => types.contains(b.type))
        .map((b) => _buildBuildingCard(b))
        .toList();
  }

  Widget _buildCityHeader(int govLevel, int totalLevel, int upgrading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.accentColor.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: const Border(bottom: BorderSide(color: Color(0xFF4A3F30))),
      ),
      child: Row(
        children: [
          // 城池图标
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.castle,
              color: AppTheme.accentColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _save.player.cityName,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _headerStat('官府等级', 'Lv.$govLevel', AppTheme.accentColor),
                    const SizedBox(width: 12),
                    _headerStat('总建筑等级', '$totalLevel', Colors.cyan),
                  ],
                ),
              ],
            ),
          ),
          // 建筑总数
          Column(
            children: [
              Text(
                '${_save.buildings.length}',
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '座建筑',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeStrip(Map<String, int> income) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppTheme.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '每日产出',
            style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _incomeItem(
                '💰',
                '铜钱',
                income['coin'] ?? 0,
                AppTheme.accentColor,
              ),
              _incomeItem(
                '🌾',
                '粮草',
                income['grain'] ?? 0,
                AppTheme.successColor,
              ),
              _incomeItem(
                '🪵',
                '木材',
                income['wood'] ?? 0,
                const Color(0xFF8B4513),
              ),
              _incomeItem('⛏', '铁矿', income['iron'] ?? 0, Colors.grey),
              _incomeItem('⚔', '兵力', income['soldiers'] ?? 0, AppTheme.hpColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _incomeItem(String emoji, String label, int value, Color color) {
    return Column(
      children: [
        Text(
          '$emoji$label',
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 10,
          ),
        ),
        Text(
          '+$value',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeQueueBar(int upgrading) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.construction, size: 16, color: Colors.orange),
          const SizedBox(width: 6),
          Text(
            '施工中: $upgrading / $maxBuildingUpgrades',
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            upgrading >= maxBuildingUpgrades
                ? '队列已满'
                : '还可升级 ${maxBuildingUpgrades - upgrading} 座',
            style: TextStyle(
              color: upgrading >= maxBuildingUpgrades
                  ? AppTheme.dangerColor
                  : AppTheme.textSecondaryColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingCard(Building b) {
    final cost = ResourceService.getUpgradeCost(b);
    final canUpgrade = ResourceService.canUpgradeBuilding(
      b,
      _save.player,
      _save.buildings,
    );
    final govLevel = _getGovLevel();
    final blockedByGov =
        b.type != BuildingType.government && b.level >= govLevel;
    final queueFull =
        _getUpgradingCount() >= maxBuildingUpgrades && !b.isUpgrading;
    final isJustUpgraded = _upgradingId == b.type.name;
    final color = _buildingColor(b.type);
    final levelProgress = b.maxLevel > 0 ? b.level / b.maxLevel : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: AnimatedScale(
        scale: isJustUpgraded ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部行：图标 + 名称 + 等级 + 状态
              Row(
                children: [
                  // 图标
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: color.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Icon(_buildingIcon(b.type), color: color, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              b.name,
                              style: const TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Lv.${b.level}',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (b.isMaxLevel) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.dangerColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  'MAX',
                                  style: TextStyle(
                                    color: AppTheme.dangerColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        // 等级进度条
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: levelProgress,
                            backgroundColor: const Color(0xFF333333),
                            valueColor: AlwaysStoppedAnimation(
                              color.withValues(alpha: 0.8),
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 当前效果 + 升级后效果
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '当前效果',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          b.effectDescription,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (!b.isMaxLevel && !b.isUpgrading) ...[
                      const Divider(height: 8, color: Color(0xFF4A3F30)),
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            size: 12,
                            color: AppTheme.successColor,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '升级后',
                            style: TextStyle(
                              color: AppTheme.successColor,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _nextLevelEffect(b),
                            style: const TextStyle(
                              color: AppTheme.successColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 升级费用 + 按钮
              if (!b.isMaxLevel) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    // 费用标签
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: cost.entries.map((e) {
                          final enough =
                              (_save.player.resources[e.key] ?? 0) >= e.value;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (enough
                                          ? Colors.orange
                                          : AppTheme.dangerColor)
                                      .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${_resIcon(e.key)}${_resName(e.key)} ${e.value}',
                              style: TextStyle(
                                color: enough
                                    ? Colors.orange
                                    : AppTheme.dangerColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 升级按钮
                    if (b.isUpgrading)
                      _buildUpgradingIndicator(b)
                    else
                      _buildUpgradeButton(
                        b,
                        canUpgrade,
                        blockedByGov,
                        queueFull,
                      ),
                  ],
                ),
              ],

              // 升级中状态
              if (b.isUpgrading) ...[
                const SizedBox(height: 6),
                _buildUpgradingBar(b),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradingIndicator(Building b) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.orange,
            ),
          ),
          SizedBox(width: 6),
          Text(
            '施工中',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradingBar(Building b) {
    final endTime = b.upgradeEndTime;
    if (endTime == null) return const SizedBox();
    final remaining = endTime.difference(DateTime.now());
    final text = remaining.inSeconds > 0
        ? '${remaining.inSeconds}秒后完成'
        : '即将完成';

    return Row(
      children: [
        const Icon(Icons.timer, size: 14, color: Colors.orange),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.orange, fontSize: 11)),
        const Spacer(),
        GestureDetector(
          onTap: () => _instantComplete(b),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '立即完成',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeButton(
    Building b,
    bool canUpgrade,
    bool blockedByGov,
    bool queueFull,
  ) {
    String label = '升级';
    Color btnColor = AppTheme.accentColor;
    bool enabled = canUpgrade;

    if (blockedByGov) {
      label = '需官府Lv.${b.level + 1}';
      btnColor = Colors.grey;
      enabled = false;
    } else if (queueFull) {
      label = '队列已满';
      btnColor = Colors.grey;
      enabled = false;
    } else if (!canUpgrade) {
      label = '资源不足';
      btnColor = AppTheme.dangerColor;
      enabled = false;
    }

    return GestureDetector(
      onTap: enabled ? () => _confirmUpgrade(b) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: enabled
              ? btnColor.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? btnColor.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              enabled ? Icons.arrow_upward : Icons.lock_outline,
              size: 14,
              color: enabled ? btnColor : Colors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: enabled ? btnColor : Colors.grey.withValues(alpha: 0.4),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _nextLevelEffect(Building b) {
    final nextLevel = b.level + 1;
    switch (b.type) {
      case BuildingType.government:
        return '主城等级上限 $nextLevel';
      case BuildingType.farm:
        return '粮草产出 +${nextLevel * 200}/日';
      case BuildingType.market:
        return '铜钱收入 +${nextLevel * 150}/日';
      case BuildingType.lumberMill:
        return '木材产出 +${nextLevel * 150}/日';
      case BuildingType.ironWorks:
        return '铁矿产出 +${nextLevel * 100}/日';
      case BuildingType.barracks:
        return '兵力恢复 +${nextLevel * 50}/日';
      case BuildingType.trainingGround:
        return '武将经验 +${nextLevel * 5}%';
      case BuildingType.tavern:
        return '招募品质提升';
      case BuildingType.blacksmith:
        return '锻造等级 $nextLevel';
      case BuildingType.academy:
        return '科技等级 $nextLevel';
      case BuildingType.postStation:
        return '情报范围 $nextLevel';
      case BuildingType.wall:
        return '耐久 ${nextLevel * 10000}';
    }
  }

  void _confirmUpgrade(Building b) {
    final cost = ResourceService.getUpgradeCost(b);
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('升级 ${b.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Lv.${b.level}',
                  style: const TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppTheme.successColor,
                ),
                Text(
                  'Lv.${b.level + 1}',
                  style: const TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '当前: ${b.effectDescription}',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 13,
              ),
            ),
            Text(
              '升级后: ${_nextLevelEffect(b)}',
              style: const TextStyle(
                color: AppTheme.successColor,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '消耗资源:',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            ...cost.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Text(
                  '${_resName(e.key)} -${e.value}',
                  style: const TextStyle(color: Colors.orange, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            child: const Text(
              '确认升级',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) _upgradeBuilding(b);
    });
  }

  void _upgradeBuilding(Building b) {
    final cost = ResourceService.getUpgradeCost(b);
    if (!ResourceService.canAfford(_save.player, cost)) return;

    setState(() {
      _save.player = ResourceService.deductResources(_save.player, cost);
      b.isUpgrading = true;
      b.upgradeEndTime = DateTime.now().add(
        Duration(seconds: b.upgradeTimeSeconds),
      );
      _upgradingId = b.type.name;
    });

    // 短暂动画后复位
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _upgradingId = null);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.construction, color: Colors.orange, size: 18),
            const SizedBox(width: 8),
            Text('${b.name} 开始升级到 Lv.${b.level + 1}'),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _instantComplete(Building b) {
    setState(() {
      b.level++;
      b.isUpgrading = false;
      b.upgradeEndTimeStr = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text('${b.name} 升级到 Lv.${b.level}！'),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _buildingColor(BuildingType type) {
    const colors = {
      BuildingType.government: AppTheme.accentColor,
      BuildingType.farm: AppTheme.successColor,
      BuildingType.market: AppTheme.accentColor,
      BuildingType.lumberMill: Color(0xFF8B4513),
      BuildingType.ironWorks: Colors.grey,
      BuildingType.barracks: AppTheme.hpColor,
      BuildingType.trainingGround: Colors.purple,
      BuildingType.tavern: Colors.orange,
      BuildingType.blacksmith: Colors.blue,
      BuildingType.academy: Colors.cyan,
      BuildingType.postStation: Colors.pink,
      BuildingType.wall: Colors.brown,
    };
    return colors[type] ?? AppTheme.accentColor;
  }

  IconData _buildingIcon(BuildingType type) {
    const icons = {
      BuildingType.government: Icons.account_balance,
      BuildingType.farm: Icons.grain,
      BuildingType.market: Icons.store,
      BuildingType.lumberMill: Icons.forest,
      BuildingType.ironWorks: Icons.hardware,
      BuildingType.barracks: Icons.military_tech,
      BuildingType.trainingGround: Icons.fitness_center,
      BuildingType.tavern: Icons.local_bar,
      BuildingType.blacksmith: Icons.build,
      BuildingType.academy: Icons.school,
      BuildingType.postStation: Icons.local_post_office,
      BuildingType.wall: Icons.shield,
    };
    return icons[type] ?? Icons.home;
  }

  String _resName(String key) {
    const names = {'coin': '铜钱', 'grain': '粮草', 'wood': '木材', 'iron': '铁矿'};
    return names[key] ?? key;
  }

  String _resIcon(String key) {
    const icons = {'coin': '💰', 'grain': '🌾', 'wood': '🪵', 'iron': '⛏'};
    return icons[key] ?? '';
  }
}
