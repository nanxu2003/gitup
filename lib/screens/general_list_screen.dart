import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/constants.dart';
import '../app/game_art.dart';
import '../models/game_save.dart';
import '../models/general.dart';
import '../widgets/general_card.dart';
import '../widgets/game_backdrop_scaffold.dart';

class GeneralListScreen extends StatefulWidget {
  final GameSave gameSave;

  const GeneralListScreen({super.key, required this.gameSave});

  @override
  State<GeneralListScreen> createState() => _GeneralListScreenState();
}

class _GeneralListScreenState extends State<GeneralListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _camps = ['全部', '蜀', '魏', '吴', '群雄'];
  String _sortBy = 'power';
  bool _onlyDeployed = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _camps.length, vsync: this);
    _searchCtrl.addListener(() {
      if (_searchCtrl.text != _searchQuery) {
        setState(() => _searchQuery = _searchCtrl.text);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  int _getPower(General g) {
    return g.attackPower +
        g.defense +
        g.hp ~/ 10 +
        g.attributes.force +
        g.attributes.intelligence +
        g.attributes.command;
  }

  int _getTotalPower() =>
      widget.gameSave.generals.fold<int>(0, (sum, g) => sum + _getPower(g));

  List<General> _getFilteredGenerals(String camp) {
    var generals = camp == '全部'
        ? List<General>.from(widget.gameSave.generals)
        : widget.gameSave.generals.where((g) => g.camp == camp).toList();

    // 上阵筛选
    if (_onlyDeployed) {
      generals = generals.where((g) => g.isDeployed).toList();
    }

    // 搜索筛选
    if (_searchQuery.isNotEmpty) {
      generals = generals
          .where(
            (g) =>
                g.name.contains(_searchQuery) ||
                g.title.contains(_searchQuery) ||
                (troopNames[g.troopType] ?? '').contains(_searchQuery) ||
                (qualityNames[g.quality] ?? '').contains(_searchQuery),
          )
          .toList();
    }

    // 排序
    switch (_sortBy) {
      case 'level':
        generals.sort((a, b) => b.level.compareTo(a.level));
        break;
      case 'force':
        generals.sort(
          (a, b) => b.attributes.force.compareTo(a.attributes.force),
        );
        break;
      case 'quality':
        generals.sort((a, b) => b.quality.index.compareTo(a.quality.index));
        break;
      case 'power':
        generals.sort((a, b) => _getPower(b).compareTo(_getPower(a)));
        break;
    }
    return generals;
  }

  // 各品质武将数量统计
  Map<Quality, int> _getQualityDistribution() {
    final dist = <Quality, int>{};
    for (final g in widget.gameSave.generals) {
      dist[g.quality] = (dist[g.quality] ?? 0) + 1;
    }
    return dist;
  }

  @override
  Widget build(BuildContext context) {
    final totalPower = _getTotalPower();
    final deployed = widget.gameSave.generals.where((g) => g.isDeployed).length;
    final qualityDist = _getQualityDistribution();

    return Scaffold(
      appBar: AppBar(
        title: const Text('武将'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _camps.map((c) {
            final count = c == '全部'
                ? widget.gameSave.generals.length
                : widget.gameSave.generals.where((g) => g.camp == c).length;
            return Tab(text: '$c($count)');
          }).toList(),
          isScrollable: true,
        ),
      ),
      body: GamePageBackdrop(
        backgroundAsset: GameArt.recruitHallBackground,
        child: Column(
          children: [
            // 顶部统计面板
            _buildStatsHeader(totalPower, deployed, qualityDist),
            // 搜索 + 筛选条
            _buildFilterBar(),
            // 武将列表
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _camps
                    .map((camp) => _buildGeneralList(camp))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(
    int totalPower,
    int deployed,
    Map<Quality, int> dist,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        border: Border(bottom: BorderSide(color: Color(0xFF4A3F30))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _headerStat(
                Icons.people,
                '武将',
                '${widget.gameSave.generals.length}',
              ),
              const SizedBox(width: 14),
              _headerStat(
                Icons.grid_on,
                '上阵',
                '$deployed/$maxDeployedGenerals',
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '总战力',
                          style: TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '$totalPower',
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
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.sort,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
                tooltip: '排序',
                color: AppTheme.surfaceColor,
                onSelected: (v) => setState(() => _sortBy = v),
                itemBuilder: (ctx) => [
                  _sortItem('power', '按战力', Icons.local_fire_department),
                  _sortItem('level', '按等级', Icons.star),
                  _sortItem('force', '按武力', Icons.gps_fixed),
                  _sortItem('quality', '按品质', Icons.diamond),
                ],
              ),
            ],
          ),
          // 品质分布条
          const SizedBox(height: 6),
          _buildQualityBar(dist),
        ],
      ),
    );
  }

  Widget _buildQualityBar(Map<Quality, int> dist) {
    final total = widget.gameSave.generals.length;
    if (total == 0) return const SizedBox();
    return SizedBox(
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Row(
          children: Quality.values.reversed.map((q) {
            final count = dist[q] ?? 0;
            if (count == 0) return const SizedBox();
            return Expanded(
              flex: count,
              child: Container(color: qualityColors[q] ?? Colors.grey),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: AppTheme.surfaceColor,
      child: Row(
        children: [
          // 搜索框
          Expanded(
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF4A3F30)),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.search,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        hintText: '搜索武将...',
                        hintStyle: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 上阵筛选
          GestureDetector(
            onTap: () => setState(() => _onlyDeployed = !_onlyDeployed),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _onlyDeployed
                    ? AppTheme.successColor.withValues(alpha: 0.15)
                    : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _onlyDeployed
                      ? AppTheme.successColor.withValues(alpha: 0.5)
                      : const Color(0xFF4A3F30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _onlyDeployed
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 14,
                    color: _onlyDeployed
                        ? AppTheme.successColor
                        : AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '上阵',
                    style: TextStyle(
                      color: _onlyDeployed
                          ? AppTheme.successColor
                          : AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.accentColor),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _sortItem(String value, String label, IconData icon) {
    final isActive = _sortBy == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive
                ? AppTheme.accentColor
                : AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.accentColor : AppTheme.textColor,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isActive) const Spacer(),
          if (isActive)
            const Icon(Icons.check, size: 16, color: AppTheme.accentColor),
        ],
      ),
    );
  }

  Widget _buildGeneralList(String camp) {
    final generals = _getFilteredGenerals(camp);
    if (generals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 56,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? '未找到匹配“$_searchQuery”的武将'
                  : _onlyDeployed
                  ? '暂无上阵武将'
                  : '暂无武将',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _searchQuery.isNotEmpty
                  ? '换个关键词试试'
                  : _onlyDeployed
                  ? '前往布阵界面上阵武将'
                  : '前往酒馆招募武将',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.76,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: generals.length,
      itemBuilder: (ctx, i) {
        return GeneralCard(
          general: generals[i],
          onTap: () {
            Navigator.of(context).pushNamed(
              '/general_detail',
              arguments: {'general': generals[i], 'gameSave': widget.gameSave},
            );
          },
          onLongPress: () => _showQuickActions(generals[i]),
        );
      },
    );
  }

  void _showQuickActions(General g) {
    final canDeploy =
        g.isDeployed ||
        widget.gameSave.generals.where((x) => x.isDeployed).length <
            maxDeployedGenerals;
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
                    color: (qualityColors[g.quality] ?? AppTheme.textColor)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      g.name[0],
                      style: TextStyle(
                        color: qualityColors[g.quality],
                        fontSize: 20,
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
                      Text(
                        g.name,
                        style: const TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Lv.${g.level} ${troopNames[g.troopType]} 战力${_getPower(g)}',
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.person, color: AppTheme.accentColor),
              title: const Text(
                '查看详情',
                style: TextStyle(color: AppTheme.textColor),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushNamed(
                  '/general_detail',
                  arguments: {'general': g, 'gameSave': widget.gameSave},
                );
              },
            ),
            ListTile(
              leading: Icon(
                g.isDeployed ? Icons.person_remove : Icons.person_add,
                color: g.isDeployed
                    ? AppTheme.dangerColor
                    : AppTheme.successColor,
              ),
              title: Text(
                g.isDeployed ? '取消上阵' : '上阵武将',
                style: TextStyle(
                  color: g.isDeployed
                      ? AppTheme.dangerColor
                      : AppTheme.successColor,
                ),
              ),
              enabled: canDeploy || g.isDeployed,
              onTap: () {
                setState(() => g.isDeployed = !g.isDeployed);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      g.isDeployed ? '${g.name}已上阵' : '${g.name}已下阵',
                    ),
                    backgroundColor: g.isDeployed
                        ? AppTheme.successColor
                        : Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
