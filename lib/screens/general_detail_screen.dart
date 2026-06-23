import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/constants.dart';
import '../app/game_art.dart';
import '../models/general.dart';
import '../models/game_save.dart';
import '../models/item.dart';
import '../services/game_data_service.dart';
import '../widgets/stat_row.dart';
import '../widgets/section_header.dart';
import '../widgets/game_backdrop_scaffold.dart';

class GeneralDetailScreen extends StatefulWidget {
  final General general;
  final GameSave gameSave;

  const GeneralDetailScreen({
    super.key,
    required this.general,
    required this.gameSave,
  });

  @override
  State<GeneralDetailScreen> createState() => _GeneralDetailScreenState();
}

class _GeneralDetailScreenState extends State<GeneralDetailScreen>
    with SingleTickerProviderStateMixin {
  late General _general;
  late AnimationController _levelUpCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _general = widget.general;
    _levelUpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _levelUpCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _levelUpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qColor = qualityColors[_general.quality] ?? AppTheme.textColor;
    final skills = _general.skillIds
        .map((sid) => GameDataService.findSkill(sid))
        .where((s) => s != null)
        .cast()
        .toList();
    final equipped = widget.gameSave.inventory
        .where((i) => _general.equippedItemIds.contains(i.id))
        .toList();
    final upgradeCost = _general.level * 200;
    final power = _calculatePower();

    return Scaffold(
      body: GamePageBackdrop(
        backgroundAsset: GameArt.recruitHallBackground,
        child: CustomScrollView(
          slivers: [
            // 顶部头部 - 品质渐变背景
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: AppTheme.primaryColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.accentColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                // 升级按钮
                AnimatedBuilder(
                  animation: _scaleAnim,
                  builder: (ctx, child) =>
                      Transform.scale(scale: _scaleAnim.value, child: child),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton.icon(
                      onPressed: () => _levelUp(upgradeCost),
                      icon: const Icon(Icons.arrow_upward, size: 16),
                      label: Text('升级 $upgradeCost'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor.withValues(
                          alpha: 0.2,
                        ),
                        foregroundColor: AppTheme.accentColor,
                        side: const BorderSide(
                          color: AppTheme.accentColor,
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        qColor.withValues(alpha: 0.3),
                        AppTheme.primaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                      child: Row(
                        children: [
                          // 大头像
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: qColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: qColor, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: qColor.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _general.name[0],
                                style: TextStyle(
                                  color: qColor,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _general.name,
                                      style: TextStyle(
                                        color: qColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: qColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        qualityNames[_general.quality] ?? '',
                                        style: TextStyle(
                                          color: qColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_general.title.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      _general.title,
                                      style: const TextStyle(
                                        color: AppTheme.textSecondaryColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    _tag(
                                      troopNames[_general.troopType] ?? '',
                                      Colors.cyan,
                                    ),
                                    _tag('${_general.camp}阵营', Colors.orange),
                                    _tag(
                                      '★' * _general.star,
                                      AppTheme.accentColor,
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
                ),
              ),
            ),

            // 战力 + 等级 + 经验条
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  border: Border(bottom: BorderSide(color: Color(0xFF4A3F30))),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statPill(
                          Icons.local_fire_department,
                          '战力',
                          '$power',
                          Colors.orange,
                        ),
                        _statPill(
                          Icons.star,
                          '等级',
                          'Lv.${_general.level}',
                          AppTheme.accentColor,
                        ),
                        _statPill(
                          Icons.favorite,
                          '生命',
                          '${_general.hp}',
                          AppTheme.hpColor,
                        ),
                        _statPill(
                          Icons.shield,
                          '防御',
                          '${_general.defense}',
                          Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 经验条
                    Row(
                      children: [
                        const Text(
                          'EXP',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: (_general.exp % 100) / 100.0,
                              backgroundColor: const Color(0xFF333333),
                              valueColor: AlwaysStoppedAnimation(
                                AppTheme.accentColor.withValues(alpha: 0.7),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_general.exp % 100}/100',
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 上阵切换按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleDeploy(),
                        icon: Icon(
                          _general.isDeployed
                              ? Icons.person_remove
                              : Icons.person_add,
                          size: 16,
                        ),
                        label: Text(
                          _general.isDeployed ? '取消上阵' : '上阵武将',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _general.isDeployed
                              ? AppTheme.dangerColor.withValues(alpha: 0.15)
                              : AppTheme.successColor.withValues(alpha: 0.15),
                          foregroundColor: _general.isDeployed
                              ? AppTheme.dangerColor
                              : AppTheme.successColor,
                          side: BorderSide(
                            color: _general.isDeployed
                                ? AppTheme.dangerColor.withValues(alpha: 0.5)
                                : AppTheme.successColor.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 传记
            if (_general.bio.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF4A3F30)),
                    ),
                    child: Text(
                      _general.bio,
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

            // 六维属性
            SliverToBoxAdapter(child: _sectionWithPadding('六维属性')),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    StatRow(
                      label: '武力',
                      value: _general.attributes.force,
                      color: AppTheme.hpColor,
                    ),
                    StatRow(
                      label: '智力',
                      value: _general.attributes.intelligence,
                      color: Colors.blue,
                    ),
                    StatRow(
                      label: '统率',
                      value: _general.attributes.command,
                      color: AppTheme.accentColor,
                    ),
                    StatRow(
                      label: '政治',
                      value: _general.attributes.politics,
                      color: AppTheme.successColor,
                    ),
                    StatRow(
                      label: '魅力',
                      value: _general.attributes.charm,
                      color: Colors.pink,
                    ),
                    StatRow(
                      label: '速度',
                      value: _general.attributes.speed,
                      color: Colors.cyan,
                    ),
                  ],
                ),
              ),
            ),

            // 战斗属性
            SliverToBoxAdapter(child: _sectionWithPadding('战斗属性')),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _infoRow(
                      '攻击力',
                      '${_general.attackPower}',
                      AppTheme.hpColor,
                    ),
                    _infoRow('防御力', '${_general.defense}', Colors.blue),
                    _infoRow(
                      '兵种',
                      troopNames[_general.troopType] ?? '',
                      Colors.cyan,
                    ),
                    _infoRow('克制', _getAdvantageText(), AppTheme.successColor),
                  ],
                ),
              ),
            ),

            // 兵种克制关系
            SliverToBoxAdapter(child: _sectionWithPadding('兵种克制')),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTroopAdvantageDiagram(),
              ),
            ),

            // 装备
            SliverToBoxAdapter(child: _sectionWithPadding('装备栏')),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildEquipSlots(equipped),
              ),
            ),

            // 技能
            SliverToBoxAdapter(child: _sectionWithPadding('技能')),
            SliverList(
              delegate: SliverChildBuilderDelegate((ctx, i) {
                final s = skills[i];
                final isPassive = s.type == SkillType.passive;
                final isCombo = s.type == SkillType.combo;
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    i == skills.length - 1 ? 16 : 6,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color:
                              (isPassive
                                      ? Colors.grey
                                      : isCombo
                                      ? Colors.purple
                                      : AppTheme.accentColor)
                                  .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isPassive
                              ? Icons.visibility_off
                              : isCombo
                              ? Icons.group
                              : Icons.auto_awesome,
                          color: isPassive
                              ? Colors.grey
                              : isCombo
                              ? Colors.purple
                              : AppTheme.accentColor,
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            s.name,
                            style: const TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (isPassive) _skillTag('被动', Colors.grey),
                          if (isCombo) _skillTag('合击', Colors.purple),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${s.description}\n'
                          '${s.costRage > 0 ? '怒气: ${s.costRage} | ' : ''}'
                          '冷却: ${s.cooldown}回合 | 倍率: ${(s.multiplier * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }, childCount: skills.length),
            ),

            // 底部间距
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _sectionWithPadding(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: SectionHeader(title: title),
    );
  }

  Widget _statPill(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondaryColor,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10)),
    );
  }

  Widget _skillTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 9)),
    );
  }

  Widget _infoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipSlots(List<GameItem> equipped) {
    const slotNames = ['武器', '铠甲', '坐骑', '兵书', '宝物', '头盔'];
    const slotIcons = [
      Icons.gps_fixed,
      Icons.shield,
      Icons.pets,
      Icons.book,
      Icons.diamond,
      Icons.shield_outlined,
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.0,
      children: List.generate(6, (i) {
        final item = i < equipped.length ? equipped[i] : null;
        final itemColor = item != null
            ? (qualityColors[item.quality] ?? AppTheme.textColor)
            : AppTheme.textSecondaryColor;
        return GestureDetector(
          onTap: () => _showEquipOptions(i, item),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: item != null
                    ? itemColor.withValues(alpha: 0.6)
                    : const Color(0xFF4A3F30),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(slotIcons[i], size: 22, color: itemColor),
                const SizedBox(height: 4),
                Text(
                  slotNames[i],
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item?.name ?? '空',
                  style: TextStyle(
                    color: itemColor,
                    fontSize: 11,
                    fontWeight: item != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _toggleDeploy() {
    final deployedCount = widget.gameSave.generals
        .where((g) => g.isDeployed)
        .length;
    if (!_general.isDeployed && deployedCount >= maxDeployedGenerals) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('上阵人数已满（最多5人），请先下阵其他武将')));
      return;
    }
    setState(() => _general.isDeployed = !_general.isDeployed);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _general.isDeployed ? '${_general.name}已上阵' : '${_general.name}已下阵',
        ),
        backgroundColor: _general.isDeployed
            ? AppTheme.successColor
            : Colors.grey,
      ),
    );
  }

  Widget _buildTroopAdvantageDiagram() {
    final currentTroop = _general.troopType;
    final advantage = troopAdvantage[currentTroop];
    // Find what counters current troop
    TroopType? counteredBy;
    for (final entry in troopAdvantage.entries) {
      if (entry.value == currentTroop) {
        counteredBy = entry.key;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A3F30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 克制方
              if (counteredBy != null)
                _troopNode(
                  troopNames[counteredBy] ?? '',
                  counteredBy,
                  AppTheme.dangerColor,
                  '克制我',
                ),
              const SizedBox(width: 12),
              // 箭头
              if (counteredBy != null)
                const Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: AppTheme.dangerColor,
                ),
              const SizedBox(width: 12),
              // 当前兵种
              _troopNode(
                troopNames[currentTroop] ?? '',
                currentTroop,
                AppTheme.accentColor,
                '当前',
              ),
              const SizedBox(width: 12),
              // 箭头
              if (advantage != null)
                const Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: AppTheme.successColor,
                ),
              const SizedBox(width: 12),
              // 被克制方
              if (advantage != null)
                _troopNode(
                  troopNames[advantage] ?? '',
                  advantage,
                  AppTheme.successColor,
                  '我克制',
                ),
            ],
          ),
          if (advantage != null) ...[
            const SizedBox(height: 8),
            Text(
              '攻击${troopNames[advantage]}时伤害+20%，受到${counteredBy != null ? troopNames[counteredBy] : ''}攻击时伤害+20%',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (currentTroop == TroopType.strategist)
            const Text(
              '谋士不参与基础兵种克制，伤害受智力影响',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  Widget _troopNode(String name, TroopType type, Color color, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Center(
            child: Text(
              name[0],
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 9),
        ),
      ],
    );
  }

  void _levelUp(int cost) {
    if ((widget.gameSave.player.resources['coin'] ?? 0) < cost) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('铜钱不足，需要 $cost 铜钱')));
      return;
    }

    setState(() {
      widget.gameSave.player.resources['coin'] =
          (widget.gameSave.player.resources['coin'] ?? 0) - cost;
      _general.level++;
      _general.exp += 100;
      _general.attributes.force += 2;
      _general.attributes.intelligence += 2;
      _general.attributes.command += 2;
      _general.attributes.politics += 1;
      _general.attributes.charm += 1;
      _general.attributes.speed += 1;
    });

    _levelUpCtrl.forward(from: 0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.arrow_upward,
              color: AppTheme.accentColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '${_general.name} 升级到 Lv.${_general.level}！',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEquipOptions(int slotIndex, GameItem? currentItem) {
    final slotTypes = [
      [ItemType.weapon],
      [ItemType.armor],
      [ItemType.mount],
      [ItemType.book],
      [ItemType.treasure],
      [ItemType.helmet],
    ];

    final availableItems = widget.gameSave.inventory
        .where(
          (i) =>
              slotTypes[slotIndex].contains(i.type) &&
              !_general.equippedItemIds.contains(i.id),
        )
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 拖拽指示条
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              currentItem != null ? '更换装备' : '装备道具',
              style: const TextStyle(
                color: AppTheme.accentColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (currentItem != null)
              ListTile(
                leading: const Icon(
                  Icons.remove_circle,
                  color: AppTheme.dangerColor,
                ),
                title: Text(
                  '卸下 ${currentItem.name}',
                  style: const TextStyle(color: AppTheme.textColor),
                ),
                onTap: () {
                  setState(
                    () => _general.equippedItemIds.remove(currentItem.id),
                  );
                  Navigator.of(ctx).pop();
                },
              ),
            if (availableItems.isEmpty && currentItem == null)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    '没有可装备的道具',
                    style: TextStyle(color: AppTheme.textSecondaryColor),
                  ),
                ),
              ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView(
                shrinkWrap: true,
                children: availableItems.map((item) {
                  final qColor =
                      qualityColors[item.quality] ?? AppTheme.textColor;
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: qColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _itemIcon(item.type),
                        color: qColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        color: qColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      item.description,
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 11,
                      ),
                    ),
                    onTap: () {
                      setState(() => _general.equippedItemIds.add(item.id));
                      Navigator.of(ctx).pop();
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _itemIcon(ItemType type) {
    const icons = {
      ItemType.weapon: Icons.gps_fixed,
      ItemType.helmet: Icons.shield,
      ItemType.armor: Icons.shield_outlined,
      ItemType.boots: Icons.directions_walk,
      ItemType.mount: Icons.pets,
      ItemType.book: Icons.book,
      ItemType.treasure: Icons.diamond,
      ItemType.consumable: Icons.local_drink,
      ItemType.material: Icons.category,
    };
    return icons[type] ?? Icons.inventory_2;
  }

  int _calculatePower() {
    return _general.attackPower +
        _general.defense +
        _general.hp ~/ 10 +
        _general.attributes.force +
        _general.attributes.intelligence +
        _general.attributes.command;
  }

  String _getAdvantageText() {
    final adv = troopAdvantage[_general.troopType];
    if (adv == null) return '无特殊克制';
    return '克制${troopNames[adv]}（+20%伤害）';
  }
}
