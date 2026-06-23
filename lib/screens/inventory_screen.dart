import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/constants.dart';
import '../app/game_art.dart';
import '../models/game_save.dart';
import '../models/general.dart';
import '../models/item.dart';
import '../widgets/game_backdrop_scaffold.dart';

class InventoryScreen extends StatefulWidget {
  final GameSave gameSave;

  const InventoryScreen({super.key, required this.gameSave});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late GameSave _save;
  final _tabs = ['全部', '装备', '消耗品', '材料', '宝物'];
  String _sortBy = 'quality'; // quality / type / quantity

  static const _equipTypes = [
    ItemType.weapon,
    ItemType.helmet,
    ItemType.armor,
    ItemType.boots,
    ItemType.mount,
    ItemType.book,
  ];

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

  List<GameItem> _getFilteredItems(List<ItemType>? types) {
    var items = _save.inventory.where((i) => i.quantity > 0).toList();
    if (types != null) {
      items = items.where((i) => types.contains(i.type)).toList();
    }
    switch (_sortBy) {
      case 'quality':
        items.sort((a, b) => b.quality.index.compareTo(a.quality.index));
        break;
      case 'quantity':
        items.sort((a, b) => b.quantity.compareTo(a.quantity));
        break;
      case 'type':
        items.sort((a, b) => a.type.index.compareTo(b.type.index));
        break;
    }
    return items;
  }

  int _getItemCount() => _save.inventory.where((i) => i.quantity > 0).length;
  int _getEquipCount() => _save.inventory
      .where((i) => i.quantity > 0 && _equipTypes.contains(i.type))
      .length;
  int _getConsumableCount() => _save.inventory
      .where((i) => i.quantity > 0 && i.type == ItemType.consumable)
      .length;

  bool _isEquipped(GameItem item) {
    return _save.generals.any((g) => g.equippedItemIds.contains(item.id));
  }

  General? _getEquippedGeneral(GameItem item) {
    for (final g in _save.generals) {
      if (g.equippedItemIds.contains(item.id)) return g;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('背包'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: '全部(${_getItemCount()})'),
            Tab(text: '装备(${_getEquipCount()})'),
            Tab(text: '消耗品(${_getConsumableCount()})'),
            const Tab(text: '材料'),
            const Tab(text: '宝物'),
          ],
        ),
      ),
      body: GamePageBackdrop(
        backgroundAsset: GameArt.recruitHallBackground,
        child: Column(
          children: [
            // 资源头栏
            _buildResourceHeader(),
            // 排序条
            _buildSortBar(),
            // 道具列表
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildItemGrid(null),
                  _buildItemGrid(_equipTypes),
                  _buildItemGrid([ItemType.consumable]),
                  _buildItemGrid([ItemType.material]),
                  _buildItemGrid([ItemType.treasure]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceHeader() {
    final res = _save.player.resources;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        border: Border(bottom: BorderSide(color: Color(0xFF4A3F30))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _resChip('💰', '铜钱', res['coin'] ?? 0, AppTheme.accentColor),
          _resChip('🌾', '粮草', res['grain'] ?? 0, AppTheme.successColor),
          _resChip('🪵', '木材', res['wood'] ?? 0, const Color(0xFF8B4513)),
          _resChip('⛏', '铁矿', res['iron'] ?? 0, Colors.grey),
        ],
      ),
    );
  }

  Widget _resChip(String emoji, String label, int value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 3),
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
              _formatNum(value),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: AppTheme.surfaceColor,
      child: Row(
        children: [
          const Icon(Icons.sort, size: 14, color: AppTheme.textSecondaryColor),
          const SizedBox(width: 4),
          const Text(
            '排序:',
            style: TextStyle(color: AppTheme.textSecondaryColor, fontSize: 11),
          ),
          const SizedBox(width: 8),
          ...['quality', 'type', 'quantity'].map((s) {
            final isActive = _sortBy == s;
            final label =
                {'quality': '品质', 'type': '类型', 'quantity': '数量'}[s] ?? s;
            return GestureDetector(
              onTap: () => setState(() => _sortBy = s),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.accentColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isActive
                        ? AppTheme.accentColor.withValues(alpha: 0.5)
                        : const Color(0xFF4A3F30),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? AppTheme.accentColor
                        : AppTheme.textSecondaryColor,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          Text(
            '共 ${_getItemCount()} 件',
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGrid(List<ItemType>? types) {
    final items = _getFilteredItems(types);
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            const Text(
              '空空如也',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '通过战斗、内政或招募获取更多道具',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.80,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _buildItemTile(items[i]),
    );
  }

  Widget _buildItemTile(GameItem item) {
    final qColor = qualityColors[item.quality] ?? AppTheme.textColor;
    final equipped = _isEquipped(item);
    final equippedBy = _getEquippedGeneral(item);

    return GestureDetector(
      onTap: () => _showItemDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: qColor.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: qColor.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: qColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_itemIcon(item.type), color: qColor, size: 20),
            ),
            const SizedBox(height: 4),
            // 名称
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: qColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // 数量
            if (item.quantity > 1)
              Text(
                '×${item.quantity}',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 9,
                ),
              ),
            // 品质标签
            if (item.type != ItemType.consumable &&
                item.type != ItemType.material)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                decoration: BoxDecoration(
                  color: qColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  qualityNames[item.quality] ?? '',
                  style: TextStyle(color: qColor, fontSize: 8),
                ),
              ),
            // 已装备标记
            if (equipped && equippedBy != null)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  equippedBy.name,
                  style: const TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 8,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showItemDetail(GameItem item) {
    final qColor = qualityColors[item.quality] ?? AppTheme.textColor;
    final isEquippable = _equipTypes.contains(item.type);
    final isUsable = item.type == ItemType.consumable;
    final equippedGeneral = _getEquippedGeneral(item);
    final sellPrice = _getSellPrice(item);

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
            // 道具头部
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: qColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: qColor.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(_itemIcon(item.type), color: qColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              color: qColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                              qualityNames[item.quality] ?? '',
                              style: TextStyle(
                                color: qColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_typeName(item.type)} · 数量 ${item.quantity}',
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
            // 描述
            Text(
              item.description,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            // 特殊效果
            if (item.specialEffect != null) ...[
              const SizedBox(height: 8),
              Text(
                '✦ ${item.specialEffect}',
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 13,
                ),
              ),
            ],
            // 属性加成
            if (item.attributes.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                '属性加成',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: item.attributes.entries.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_attrName(e.key)} +${e.value}',
                      style: const TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            // 已装备信息
            if (equippedGeneral != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.successColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '已装备给 ${equippedGeneral.name}',
                      style: const TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // 操作按钮
            Row(
              children: [
                // 关闭
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4A3F30)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      '关闭',
                      style: TextStyle(color: AppTheme.textSecondaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 出售
                if (item.quantity > 0 && equippedGeneral == null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _sellItem(item);
                      },
                      icon: const Icon(Icons.monetization_on, size: 16),
                      label: Text(
                        '出售 $sellPrice',
                        style: const TextStyle(
                          color: AppTheme.accentColor,
                          fontSize: 12,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppTheme.accentColor.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                // 装备/使用
                if (isEquippable && item.quantity > 0)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _showEquipToGeneral(item);
                      },
                      icon: const Icon(Icons.shield, size: 16),
                      label: Text(
                        equippedGeneral != null ? '更换' : '装备',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                if (isUsable && item.quantity > 0)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _showUseItemOptions(item);
                      },
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text(
                        '使用',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEquipToGeneral(GameItem item) {
    final generals = _save.generals;
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
            Text(
              '将【${item.name}】装备给',
              style: const TextStyle(
                color: AppTheme.accentColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '选择一名武将装备此${_typeName(item.type)}',
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: generals.length,
                itemBuilder: (ctx, i) {
                  final g = generals[i];
                  final qColor = qualityColors[g.quality] ?? AppTheme.textColor;
                  final alreadyEquipped = g.equippedItemIds.contains(item.id);
                  // 检查此槽位是否已有同类装备
                  final slotType = item.type;
                  final hasSameSlot = _hasSameSlotEquipped(
                    g,
                    slotType,
                    item.id,
                  );
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
                        if (alreadyEquipped) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              '已装备',
                              style: TextStyle(
                                color: AppTheme.successColor,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      'Lv.${g.level} · ${troopNames[g.troopType]}${hasSameSlot ? ' · 已有同类装备' : ''}',
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 11,
                      ),
                    ),
                    trailing: alreadyEquipped
                        ? const Icon(
                            Icons.check_circle,
                            color: AppTheme.successColor,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        // 移除已有的同类装备
                        if (hasSameSlot) {
                          _removeSameSlotItem(g, slotType);
                        }
                        // 先从其他武将身上移除（如果有的话）
                        for (final other in generals) {
                          other.equippedItemIds.remove(item.id);
                        }
                        g.equippedItemIds.add(item.id);
                      });
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${g.name}装备了${item.name}'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
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

  bool _hasSameSlotEquipped(General g, ItemType slotType, String excludeId) {
    for (final eqId in g.equippedItemIds) {
      if (eqId == excludeId) continue;
      final eqItem = _save.inventory.where((i) => i.id == eqId).firstOrNull;
      if (eqItem != null && eqItem.type == slotType) return true;
    }
    return false;
  }

  void _removeSameSlotItem(General g, ItemType slotType) {
    g.equippedItemIds.removeWhere((eqId) {
      final eqItem = _save.inventory.where((i) => i.id == eqId).firstOrNull;
      return eqItem != null && eqItem.type == slotType;
    });
  }

  void _showUseItemOptions(GameItem item) {
    if (item.id == 'recruit_token' || item.id == 'adv_recruit_token') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请前往酒馆使用招募令进行招募'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 药草/经验书 -> 选择武将使用
    if (item.id == 'herb' ||
        item.id == 'great_herb' ||
        item.id == 'exp_book_s' ||
        item.id == 'exp_book_m') {
      _showUseOnGeneral(item);
      return;
    }

    // 其他消耗品直接使用
    _useItemDirect(item);
  }

  void _showUseOnGeneral(GameItem item) {
    final generals = _save.generals;
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
            Text(
              '对谁使用【${item.name}】？',
              style: const TextStyle(
                color: AppTheme.accentColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: generals.length,
                itemBuilder: (ctx, i) {
                  final g = generals[i];
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
                    title: Text(
                      g.name,
                      style: TextStyle(
                        color: qColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Lv.${g.level} · ${troopNames[g.troopType]}',
                      style: const TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 11,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _applyItemToGeneral(item, g);
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

  void _applyItemToGeneral(GameItem item, General general) {
    String resultText = '';
    setState(() {
      if (item.id == 'herb') {
        resultText = '${general.name}使用了药草，士气提升！';
      } else if (item.id == 'great_herb') {
        resultText = '${general.name}使用了上等药草，体力充沛！';
      } else if (item.id == 'exp_book_s') {
        general.exp += 200;
        resultText = '${general.name}研读兵法心得，获得200经验！';
      } else if (item.id == 'exp_book_m') {
        general.exp += 500;
        resultText = '${general.name}精读兵法精要，获得500经验！';
      }
      item.quantity = (item.quantity - 1).clamp(0, 9999);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resultText),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _useItemDirect(GameItem item) {
    setState(() {
      item.quantity = (item.quantity - 1).clamp(0, 9999);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('使用了${item.name}'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _sellItem(GameItem item) {
    final price = _getSellPrice(item);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认出售'),
        content: Text('出售 ${item.name} ×1，获得 $price 铜钱？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item.quantity = (item.quantity - 1).clamp(0, 9999);
                _save.player.resources['coin'] =
                    (_save.player.resources['coin'] ?? 0) + price;
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('出售${item.name}，获得 $price 铜钱'),
                  backgroundColor: AppTheme.accentColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: AppTheme.primaryColor,
            ),
            child: const Text('确认出售'),
          ),
        ],
      ),
    );
  }

  int _getSellPrice(GameItem item) {
    const basePrice = {
      Quality.white: 50,
      Quality.green: 150,
      Quality.blue: 400,
      Quality.purple: 1000,
      Quality.orange: 3000,
      Quality.red: 8000,
    };
    return basePrice[item.quality] ?? 50;
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

  String _typeName(ItemType type) {
    const names = {
      ItemType.weapon: '武器',
      ItemType.helmet: '头盔',
      ItemType.armor: '铠甲',
      ItemType.boots: '战靴',
      ItemType.mount: '坐骑',
      ItemType.book: '兵书',
      ItemType.treasure: '宝物',
      ItemType.consumable: '消耗品',
      ItemType.material: '材料',
    };
    return names[type] ?? '';
  }

  String _attrName(String key) {
    const names = {
      'force': '武力',
      'intelligence': '智力',
      'command': '统率',
      'politics': '政治',
      'charm': '魅力',
      'speed': '速度',
      'attackPercent': '攻击%',
      'defensePercent': '防御%',
    };
    return names[key] ?? key;
  }

  String _formatNum(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}万';
    return '$n';
  }
}
