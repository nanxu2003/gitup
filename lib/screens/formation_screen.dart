import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/constants.dart';
import '../app/game_art.dart';
import '../models/game_save.dart';
import '../models/formation.dart';
import '../models/general.dart';
import '../widgets/game_backdrop_scaffold.dart';

class FormationScreen extends StatefulWidget {
  final GameSave gameSave;

  const FormationScreen({super.key, required this.gameSave});

  @override
  State<FormationScreen> createState() => _FormationScreenState();
}

class _FormationScreenState extends State<FormationScreen> {
  late GameSave _save;
  int _selectedFormation = 0;

  @override
  void initState() {
    super.initState();
    _save = widget.gameSave;
  }

  int _getPower(General g) {
    return g.attackPower +
        g.defense +
        g.hp ~/ 10 +
        g.attributes.force +
        g.attributes.intelligence +
        g.attributes.command;
  }

  int _getTeamPower(Formation formation) {
    final ids = formation.deployedGeneralIds;
    int total = 0;
    for (final id in ids) {
      final g = _save.generals.where((x) => x.id == id).firstOrNull;
      if (g != null) total += _getPower(g);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final formations = _save.formations;
    if (formations.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('布阵')),
        body: const GamePageBackdrop(
          backgroundAsset: GameArt.battlefieldBackground,
          child: Center(
            child: Text('暂无阵型', style: TextStyle(color: AppTheme.textColor)),
          ),
        ),
      );
    }

    final formation = formations[_selectedFormation];
    final teamPower = _getTeamPower(formation);
    final deployedCount = formation.deployedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('布阵'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high, color: AppTheme.accentColor),
            tooltip: '自动布阵',
            onPressed: () => _autoFill(formation),
          ),
          IconButton(
            icon: const Icon(
              Icons.clear_all,
              color: AppTheme.textSecondaryColor,
            ),
            tooltip: '清空布阵',
            onPressed: () => _clearFormation(formation),
          ),
        ],
      ),
      body: GamePageBackdrop(
        backgroundAsset: GameArt.battlefieldBackground,
        child: Column(
          children: [
            // 阵型选择区
            _buildFormationSelector(formations),
            // 阵型信息条
            _buildFormationInfoBar(formation, teamPower, deployedCount),
            // 布阵网格
            Expanded(child: _buildFormationGrid(formation)),
            // 底部操作栏
            _buildBottomBar(formation, teamPower, deployedCount),
          ],
        ),
      ),
    );
  }

  Widget _buildFormationSelector(List<Formation> formations) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        border: Border(bottom: BorderSide(color: Color(0xFF4A3F30))),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: formations.length,
        itemBuilder: (ctx, i) {
          final f = formations[i];
          final isSelected = i == _selectedFormation;
          return GestureDetector(
            onTap: () {
              if (!isSelected) setState(() => _selectedFormation = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentColor.withValues(alpha: 0.15)
                    : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.accentColor
                      : const Color(0xFF4A3F30),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    f.name,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.accentColor
                          : AppTheme.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    runSpacing: 2,
                    children: f.bonuses.entries
                        .take(2)
                        .map(
                          (e) => Text(
                            '${_bonusName(e.key)}+${(e.value * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.successColor
                                  : AppTheme.textSecondaryColor,
                              fontSize: 9,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormationInfoBar(
    Formation formation,
    int teamPower,
    int deployedCount,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AppTheme.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 阵型描述
          if (formation.description.isNotEmpty)
            Text(
              formation.description,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              // 阵型效果
              ...formation.bonuses.entries.map(
                (e) => Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${_bonusName(e.key)} +${(e.value * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppTheme.successColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // 战力
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$teamPower',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // 人数
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.people,
                    size: 14,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$deployedCount/$maxDeployedGenerals',
                    style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormationGrid(Formation formation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 前排
          _buildRowLabel('前 排', '承受伤害', AppTheme.hpColor),
          const SizedBox(height: 6),
          _buildSlotRow(formation, 0),
          const SizedBox(height: 16),
          // 中排
          _buildRowLabel('中 排', '输出核心', AppTheme.accentColor),
          const SizedBox(height: 6),
          _buildSlotRow(formation, 1),
          const SizedBox(height: 16),
          // 后排
          _buildRowLabel('后 排', '谋士/远程', Colors.cyan),
          const SizedBox(height: 6),
          _buildSlotRow(formation, 2),
          const SizedBox(height: 16),
          // 兵种构成
          _buildTroopComposition(formation),
        ],
      ),
    );
  }

  Widget _buildRowLabel(String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          subtitle,
          style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildSlotRow(Formation formation, int row) {
    if (row >= formation.slots.length) return const SizedBox();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(formation.slots[row].length, (col) {
        final generalId = formation.slots[row][col];
        final general = generalId != null
            ? _save.generals.where((g) => g.id == generalId).firstOrNull
            : null;
        return _buildSlot(formation, row, col, general);
      }),
    );
  }

  Widget _buildSlot(Formation formation, int row, int col, General? general) {
    final qColor = general != null
        ? (qualityColors[general.quality] ?? AppTheme.textColor)
        : null;
    return GestureDetector(
      onTap: () => _onSlotTap(formation, row, col, general),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 95,
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: general != null ? AppTheme.cardColor : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: general != null
                ? qColor!.withValues(alpha: 0.6)
                : const Color(0xFF4A3F30),
            width: general != null ? 2 : 1,
          ),
          boxShadow: general != null
              ? [
                  BoxShadow(
                    color: qColor!.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: general != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 头像
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: qColor!.withValues(alpha: 0.2),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    general.name,
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Lv.${general.level}',
                    style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // 兵种标签
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      troopNames[general.troopType] ?? '',
                      style: const TextStyle(color: Colors.cyan, fontSize: 8),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF4A3F30),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppTheme.textSecondaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '空位',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTroopComposition(Formation formation) {
    final ids = formation.deployedGeneralIds;
    if (ids.isEmpty) return const SizedBox();

    final troopCounts = <TroopType, int>{};
    for (final id in ids) {
      final g = _save.generals.where((x) => x.id == id).firstOrNull;
      if (g != null) {
        troopCounts[g.troopType] = (troopCounts[g.troopType] ?? 0) + 1;
      }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A3F30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '兵种构成',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: troopCounts.entries.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${troopNames[e.key]} ×${e.value}',
                  style: const TextStyle(
                    color: Colors.cyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    Formation formation,
    int teamPower,
    int deployedCount,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        border: Border(top: BorderSide(color: Color(0xFF4A3F30))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${formation.name}  |  ${formation.slots.fold<int>(0, (s, r) => s + r.length)}个位置',
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: Colors.orange,
                      ),
                      Text(
                        ' 战力 $teamPower',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(_save),
              icon: const Icon(Icons.check, size: 16),
              label: const Text(
                '保存布阵',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSlotTap(Formation formation, int row, int col, General? current) {
    if (current != null) {
      // 已有武将 - 弹出选择：移除 或 替换
      _showSlotOptions(formation, row, col, current);
    } else {
      // 空位 - 选择武将
      _showGeneralPicker(formation, row, col);
    }
  }

  void _showSlotOptions(
    Formation formation,
    int row,
    int col,
    General current,
  ) {
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
          children: [
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
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        (qualityColors[current.quality] ?? AppTheme.textColor)
                            .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      current.name[0],
                      style: TextStyle(
                        color: qualityColors[current.quality],
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current.name,
                      style: const TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Lv.${current.level} ${troopNames[current.troopType]} 战力${_getPower(current)}',
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(
                Icons.swap_horiz,
                color: AppTheme.accentColor,
              ),
              title: const Text(
                '替换武将',
                style: TextStyle(color: AppTheme.textColor),
              ),
              subtitle: const Text(
                '选择其他武将替换此位置',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 11,
                ),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _showGeneralPicker(formation, row, col, replace: true);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.remove_circle_outline,
                color: AppTheme.dangerColor,
              ),
              title: const Text(
                '移除武将',
                style: TextStyle(color: AppTheme.dangerColor),
              ),
              subtitle: const Text(
                '将此武将移出阵型',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 11,
                ),
              ),
              onTap: () {
                setState(() {
                  formation.slots[row][col] = null;
                  current.isDeployed = false;
                });
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGeneralPicker(
    Formation formation,
    int row,
    int col, {
    bool replace = false,
  }) {
    final deployedIds = formation.deployedGeneralIds.toSet();
    final available = _save.generals
        .where((g) => !deployedIds.contains(g.id))
        .toList();

    // 按战力排序
    available.sort((a, b) => _getPower(b).compareTo(_getPower(a)));

    if (available.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('没有可用的武将')));
      return;
    }

    if (!replace && formation.deployedCount >= maxDeployedGenerals) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('上阵人数已满（最多5人）')));
      return;
    }

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
            const Text(
              '选择武将',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '按战力排序 · 可选${available.length}人',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: available.length,
                itemBuilder: (ctx, i) {
                  final g = available[i];
                  final qColor = qualityColors[g.quality] ?? AppTheme.textColor;
                  return ListTile(
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: qColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          g.name[0],
                          style: TextStyle(
                            color: qColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          g.name,
                          style: TextStyle(
                            color: qColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: qColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            qualityNames[g.quality] ?? '',
                            style: TextStyle(color: qColor, fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Lv.${g.level} · ${troopNames[g.troopType]} · 战力${_getPower(g)}',
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 11,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                    onTap: () {
                      setState(() {
                        if (replace) {
                          final oldId = formation.slots[row][col];
                          if (oldId != null) {
                            final oldGeneral = _save.generals
                                .where((x) => x.id == oldId)
                                .firstOrNull;
                            oldGeneral?.isDeployed = false;
                          }
                        }
                        formation.slots[row][col] = g.id;
                        g.isDeployed = true;
                      });
                      Navigator.of(ctx).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _autoFill(Formation formation) {
    // 按战力排序取前N个
    final sorted = List<General>.from(_save.generals)
      ..sort((a, b) => _getPower(b).compareTo(_getPower(a)));
    int filledCount = 0;

    setState(() {
      // 先清空
      for (final g in _save.generals) {
        g.isDeployed = false;
      }
      for (int r = 0; r < formation.slots.length; r++) {
        for (int c = 0; c < formation.slots[r].length; c++) {
          formation.slots[r][c] = null;
        }
      }

      // 按槽位填充
      for (
        int r = 0;
        r < formation.slots.length && filledCount < maxDeployedGenerals;
        r++
      ) {
        for (
          int c = 0;
          c < formation.slots[r].length && filledCount < maxDeployedGenerals;
          c++
        ) {
          if (filledCount < sorted.length) {
            formation.slots[r][c] = sorted[filledCount].id;
            sorted[filledCount].isDeployed = true;
            filledCount++;
          }
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已自动布阵，上阵 $filledCount 名武将'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _clearFormation(Formation formation) {
    setState(() {
      for (final g in _save.generals) {
        g.isDeployed = false;
      }
      for (int r = 0; r < formation.slots.length; r++) {
        for (int c = 0; c < formation.slots[r].length; c++) {
          formation.slots[r][c] = null;
        }
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已清空布阵')));
  }

  String _bonusName(String key) {
    const names = {
      'attackPercent': '攻击',
      'defensePercent': '防御',
      'speedPercent': '速度',
    };
    return names[key] ?? key;
  }
}
