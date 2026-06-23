import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/game_art.dart';
import '../models/game_save.dart';
import '../widgets/game_backdrop_scaffold.dart';

/// 内政行动定义
class _PoliticsAction {
  final String id;
  final String title;
  final String description;
  final String flavorText;
  final IconData icon;
  final Color color;
  final String category;
  final Map<String, int> cost;
  final Map<String, int> reward;
  final Map<String, int> effects;

  const _PoliticsAction({
    required this.id,
    required this.title,
    required this.description,
    this.flavorText = '',
    required this.icon,
    required this.color,
    this.category = 'civil',
    this.cost = const {},
    this.reward = const {},
    this.effects = const {},
  });
}

class PoliticsScreen extends StatefulWidget {
  final GameSave gameSave;

  const PoliticsScreen({super.key, required this.gameSave});

  @override
  State<PoliticsScreen> createState() => _PoliticsScreenState();
}

class _PoliticsScreenState extends State<PoliticsScreen>
    with SingleTickerProviderStateMixin {
  late GameSave _save;
  late AnimationController _pulseCtrl;
  String? _lastAction;
  final List<String> _actionLog = [];

  // 所有内政行动定义
  late final List<_PoliticsAction> _actions = [
    _PoliticsAction(
      id: 'patrol',
      title: '巡查城池',
      description: '巡视城防，安抚百姓',
      flavorText: '城主亲临街巷，军民振奋。',
      icon: Icons.search,
      color: Colors.cyan,
      category: 'civil',
      effects: {'morale': 2},
    ),
    _PoliticsAction(
      id: 'relief',
      title: '开仓赈济',
      description: '开仓放粮，救济灾民',
      flavorText: '百姓跪谢恩德，民心大振。',
      icon: Icons.volunteer_activism,
      color: AppTheme.successColor,
      category: 'civil',
      cost: {'grain': 300},
      effects: {'morale': 10, 'reputation': 5},
    ),
    _PoliticsAction(
      id: 'tax',
      title: '征收赋税',
      description: '向城中商户征收税款',
      flavorText: '税吏四出，府库渐丰，然百姓颇有怨言。',
      icon: Icons.monetization_on,
      color: AppTheme.accentColor,
      category: 'economy',
      reward: {'coin': 500},
      effects: {'morale': -5},
    ),
    _PoliticsAction(
      id: 'recruit_soldiers',
      title: '招募乡勇',
      description: '在城中招募壮丁入伍',
      flavorText: '壮士应募而来，校场操练之声不绝。',
      icon: Icons.people,
      color: AppTheme.hpColor,
      category: 'military',
      cost: {'coin': 200, 'grain': 100},
      reward: {'soldiers': 100},
    ),
    _PoliticsAction(
      id: 'reform',
      title: '整顿吏治',
      description: '考核官员，惩治贪腐',
      flavorText: '吏治清明，百姓安居，税收渐增。',
      icon: Icons.gavel,
      color: Colors.purple,
      category: 'civil',
      effects: {'reputation': 3},
    ),
    _PoliticsAction(
      id: 'repair_wall',
      title: '修缮城防',
      description: '加固城墙，修筑箭楼',
      flavorText: '工匠日夜赶工，城墙愈发坚固。',
      icon: Icons.shield,
      color: Colors.brown,
      category: 'military',
      cost: {'wood': 200, 'iron': 100},
    ),
    _PoliticsAction(
      id: 'trade',
      title: '商贾互市',
      description: '开辟市场，促进贸易',
      flavorText: '商贾云集，货物琳琅满目。',
      icon: Icons.store,
      color: Colors.orange,
      category: 'economy',
      cost: {'grain': 200},
      reward: {'coin': 400, 'wood': 100},
    ),
    _PoliticsAction(
      id: 'farm',
      title: '劝课农桑',
      description: '鼓励百姓耕种，兴修水利',
      flavorText: '田间地头一片繁忙，秋收在望。',
      icon: Icons.grain,
      color: Colors.green,
      category: 'economy',
      cost: {'coin': 150},
      reward: {'grain': 600},
    ),
    _PoliticsAction(
      id: 'banquet',
      title: '宴请名士',
      description: '设宴款待城中名士',
      flavorText: '觥筹交错间，名士归心。',
      icon: Icons.local_bar,
      color: Colors.pink,
      category: 'civil',
      cost: {'coin': 300, 'grain': 150},
      effects: {'reputation': 8, 'morale': 5},
    ),
    _PoliticsAction(
      id: 'drill',
      title: '操练军伍',
      description: '加强军队训练，提升战力',
      flavorText: '校场号角声声，士卒士气高涨。',
      icon: Icons.fitness_center,
      color: AppTheme.rageColor,
      category: 'military',
      cost: {'grain': 200},
      reward: {'soldiers': 50},
      effects: {'morale': 3},
    ),
  ];

  @override
  void initState() {
    super.initState();
    _save = widget.gameSave;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool _canAfford(_PoliticsAction action) {
    for (final entry in action.cost.entries) {
      if ((_save.player.resources[entry.key] ?? 0) < entry.value) return false;
    }
    return true;
  }

  bool _canExecute(_PoliticsAction action) {
    return _save.player.actionPoints > 0 && _canAfford(action);
  }

  String _resName(String key) {
    const names = {
      'coin': '铜钱',
      'grain': '粮草',
      'wood': '木材',
      'iron': '铁矿',
      'soldiers': '兵力',
    };
    return names[key] ?? key;
  }

  String _resIcon(String key) {
    const icons = {
      'coin': '💰',
      'grain': '🌾',
      'wood': '🪵',
      'iron': '⛏',
      'soldiers': '⚔',
    };
    return icons[key] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final player = _save.player;
    final apRatio = player.maxActionPoints > 0
        ? player.actionPoints / player.maxActionPoints
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${player.cityName}城 · 内政'),
        actions: [
          // 民心指示
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _moraleColor().withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, size: 14, color: _moraleColor()),
                    const SizedBox(width: 4),
                    Text(
                      '民心 ${player.morale}',
                      style: TextStyle(
                        color: _moraleColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 声望
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 14,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${player.reputation}',
                    style: const TextStyle(
                      color: Colors.purple,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: GamePageBackdrop(
        backgroundAsset: GameArt.recruitHallBackground,
        child: Column(
          children: [
            // 行动点头
            _buildActionPointsHeader(apRatio),
            // 资源概览
            _buildResourceStrip(),
            // 行动日志
            if (_actionLog.isNotEmpty) _buildActionLog(),
            // 内政行动列表
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  // 分类标题
                  _categoryTitle('民事政务', Icons.account_balance, Colors.cyan),
                  ..._actions
                      .where((a) => a.category == 'civil')
                      .map(_buildActionCard),
                  const SizedBox(height: 8),
                  _categoryTitle(
                    '经济商贸',
                    Icons.monetization_on,
                    AppTheme.accentColor,
                  ),
                  ..._actions
                      .where((a) => a.category == 'economy')
                      .map(_buildActionCard),
                  const SizedBox(height: 8),
                  _categoryTitle('军务兵政', Icons.shield, AppTheme.hpColor),
                  ..._actions
                      .where((a) => a.category == 'military')
                      .map(_buildActionCard),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPointsHeader(double apRatio) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        border: const Border(bottom: BorderSide(color: Color(0xFF4A3F30))),
      ),
      child: Row(
        children: [
          // 行动点圆形进度
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    value: apRatio,
                    strokeWidth: 4,
                    backgroundColor: const Color(0xFF333333),
                    valueColor: AlwaysStoppedAnimation(
                      apRatio > 0.5
                          ? AppTheme.accentColor
                          : apRatio > 0
                          ? Colors.orange
                          : AppTheme.dangerColor,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_save.player.actionPoints}',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '行动点',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '剩余 ${_save.player.actionPoints} / ${_save.player.maxActionPoints}',
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_save.player.actionPoints == 0)
                  const Text(
                    '今日行动点已用完，请结束一天',
                    style: TextStyle(color: AppTheme.dangerColor, fontSize: 11),
                  ),
              ],
            ),
          ),
          // 日期
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4A3F30)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(height: 2),
                Text(
                  '第${_save.player.day}日',
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceStrip() {
    final res = _save.player.resources;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: AppTheme.surfaceColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _resChip('coin', res['coin'] ?? 0, AppTheme.accentColor),
          _resChip('grain', res['grain'] ?? 0, AppTheme.successColor),
          _resChip('wood', res['wood'] ?? 0, const Color(0xFF8B4513)),
          _resChip('iron', res['iron'] ?? 0, Colors.grey),
          _resChip('soldiers', res['soldiers'] ?? 0, AppTheme.hpColor),
        ],
      ),
    );
  }

  Widget _resChip(String key, int value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_resIcon(key), style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 2),
        Text(
          _formatNum(value),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionLog() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今日政务记录',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ..._actionLog.reversed
              .take(3)
              .map(
                (log) => Text(
                  '· $log',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 11,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _categoryTitle(String title, IconData icon, Color color) {
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

  Widget _buildActionCard(_PoliticsAction action) {
    final canDo = _canExecute(action);
    final hasAP = _save.player.actionPoints > 0;
    final affordable = _canAfford(action);
    final isLastAction = _lastAction == action.id;

    return AnimatedScale(
      scale: isLastAction ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: canDo ? null : AppTheme.cardColor.withValues(alpha: 0.5),
        child: InkWell(
          onTap: canDo ? () => _executeAction(action) : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 图标
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: action.color.withValues(
                          alpha: canDo ? 0.15 : 0.08,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: action.color.withValues(
                            alpha: canDo ? 0.4 : 0.15,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        action.icon,
                        color: canDo
                            ? action.color
                            : action.color.withValues(alpha: 0.4),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 标题和描述
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                action.title,
                                style: TextStyle(
                                  color: canDo
                                      ? AppTheme.textColor
                                      : AppTheme.textSecondaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (!hasAP)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.dangerColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text(
                                    '无行动点',
                                    style: TextStyle(
                                      color: AppTheme.dangerColor,
                                      fontSize: 9,
                                    ),
                                  ),
                                )
                              else if (!affordable)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text(
                                    '资源不足',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            action.description,
                            style: TextStyle(
                              color: canDo
                                  ? AppTheme.textSecondaryColor
                                  : AppTheme.textSecondaryColor.withValues(
                                      alpha: 0.5,
                                    ),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 执行按钮
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: canDo
                            ? action.color.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: canDo
                              ? action.color.withValues(alpha: 0.5)
                              : Colors.grey.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Icon(
                        canDo ? Icons.play_arrow_rounded : Icons.lock_outline,
                        color: canDo
                            ? action.color
                            : Colors.grey.withValues(alpha: 0.3),
                        size: 24,
                      ),
                    ),
                  ],
                ),

                // 费用/收益/效果行
                if (action.cost.isNotEmpty ||
                    action.reward.isNotEmpty ||
                    action.effects.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // 费用
                        ...action.cost.entries.map((e) {
                          final enough =
                              (_save.player.resources[e.key] ?? 0) >= e.value;
                          return _effectChip(
                            '${_resIcon(e.key)}${_resName(e.key)} -${e.value}',
                            enough ? Colors.orange : AppTheme.dangerColor,
                          );
                        }),
                        // 收益
                        ...action.reward.entries.map(
                          (e) => _effectChip(
                            '${_resIcon(e.key)}${_resName(e.key)} +${e.value}',
                            AppTheme.successColor,
                          ),
                        ),
                        // 效果
                        ...action.effects.entries.map((e) {
                          final isNeg = e.value < 0;
                          final label = e.key == 'morale'
                              ? '民心'
                              : e.key == 'reputation'
                              ? '声望'
                              : e.key;
                          return _effectChip(
                            '$label ${e.value > 0 ? "+" : ""}${e.value}',
                            isNeg ? AppTheme.dangerColor : AppTheme.accentColor,
                          );
                        }),
                      ],
                    ),
                  ),
                ],

                // 风味文本
                if (canDo && action.flavorText.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '"${action.flavorText}"',
                    style: TextStyle(
                      color: action.color.withValues(alpha: 0.5),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _effectChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _executeAction(_PoliticsAction action) {
    // 确认对话框（对消耗大的行动）
    final totalCost = action.cost.values.fold<int>(0, (s, v) => s + v);
    if (totalCost >= 300) {
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('确认执行：${action.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                action.description,
                style: const TextStyle(color: AppTheme.textColor, fontSize: 14),
              ),
              const SizedBox(height: 8),
              if (action.cost.isNotEmpty) ...[
                const Text(
                  '消耗:',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
                ...action.cost.entries.map(
                  (e) => Text(
                    '  ${_resName(e.key)} -${e.value}',
                    style: const TextStyle(color: Colors.orange, fontSize: 13),
                  ),
                ),
              ],
              if (action.reward.isNotEmpty) ...[
                const SizedBox(height: 4),
                const Text(
                  '获得:',
                  style: TextStyle(color: AppTheme.successColor, fontSize: 12),
                ),
                ...action.reward.entries.map(
                  (e) => Text(
                    '  ${_resName(e.key)} +${e.value}',
                    style: const TextStyle(
                      color: AppTheme.successColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: action.color),
              child: const Text('执行', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ).then((confirmed) {
        if (confirmed == true) _applyAction(action);
      });
    } else {
      _applyAction(action);
    }
  }

  void _applyAction(_PoliticsAction action) {
    setState(() {
      _save.player.actionPoints--;
      _lastAction = action.id;

      // 扣除费用
      for (final entry in action.cost.entries) {
        _save.player.resources[entry.key] =
            (_save.player.resources[entry.key] ?? 0) - entry.value;
      }

      // 增加收益
      for (final entry in action.reward.entries) {
        _save.player.resources[entry.key] =
            (_save.player.resources[entry.key] ?? 0) + entry.value;
      }

      // 应用效果
      for (final entry in action.effects.entries) {
        switch (entry.key) {
          case 'morale':
            _save.player.morale = (_save.player.morale + entry.value).clamp(
              0,
              100,
            );
            break;
          case 'reputation':
            _save.player.reputation += entry.value;
            break;
        }
      }

      // 记录日志
      final logParts = <String>[action.title];
      for (final e in action.cost.entries) {
        logParts.add('${_resName(e.key)}-${e.value}');
      }
      for (final e in action.reward.entries) {
        logParts.add('${_resName(e.key)}+${e.value}');
      }
      _actionLog.add(logParts.join('，'));
    });

    _pulseCtrl.forward(from: 0);

    // 成功提示
    final snackBarParts = <String>[];
    for (final e in action.reward.entries) {
      snackBarParts.add('${_resName(e.key)}+${e.value}');
    }
    for (final e in action.effects.entries) {
      final label = e.key == 'morale'
          ? '民心'
          : e.key == 'reputation'
          ? '声望'
          : e.key;
      snackBarParts.add('$label${e.value > 0 ? "+" : ""}${e.value}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(action.icon, color: action.color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (snackBarParts.isNotEmpty)
                    Text(
                      snackBarParts.join('  '),
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );

    // 更新每日任务进度
    for (final q in _save.quests) {
      for (final obj in q.objectives) {
        if (obj.type == 'politics') {
          obj.currentCount++;
        }
      }
    }
  }

  Color _moraleColor() {
    final m = _save.player.morale;
    if (m >= 80) return AppTheme.successColor;
    if (m >= 50) return AppTheme.accentColor;
    if (m >= 30) return Colors.orange;
    return AppTheme.dangerColor;
  }

  String _formatNum(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}万';
    return '$n';
  }
}
