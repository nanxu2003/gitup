import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/constants.dart';
import '../app/game_art.dart';
import '../models/game_save.dart';
import '../models/general.dart';
import '../services/game_data_service.dart';
import '../services/recruit_service.dart';
import '../widgets/game_art_layer.dart';
import '../widgets/ornate_game_frame.dart';

class RecruitScreen extends StatefulWidget {
  final GameSave gameSave;

  const RecruitScreen({super.key, required this.gameSave});

  @override
  State<RecruitScreen> createState() => _RecruitScreenState();
}

class _RecruitScreenState extends State<RecruitScreen>
    with SingleTickerProviderStateMixin {
  late GameSave _save;
  final List<_RecruitRecord> _history = [];
  bool _isRecruiting = false;
  late AnimationController _animCtrl;
  late Animation<double> _revealAnim;

  @override
  void initState() {
    super.initState();
    _save = widget.gameSave;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _revealAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  int _getTokenCount() {
    final token = _save.inventory
        .where((i) => i.id == 'recruit_token')
        .firstOrNull;
    return token?.quantity ?? 0;
  }

  bool _canAffordCost(Map<String, int> cost) {
    // 检查铜钱等普通资源
    for (final entry in cost.entries) {
      if (entry.key == 'recruit_token') {
        if (_getTokenCount() < entry.value) return false;
      } else {
        if ((_save.player.resources[entry.key] ?? 0) < entry.value) {
          return false;
        }
      }
    }
    return true;
  }

  void _deductCost(Map<String, int> cost) {
    for (final entry in cost.entries) {
      if (entry.key == 'recruit_token') {
        final token = _save.inventory
            .where((i) => i.id == 'recruit_token')
            .firstOrNull;
        if (token != null) {
          token.quantity -= entry.value;
        }
      } else {
        _save.player.resources[entry.key] =
            (_save.player.resources[entry.key] ?? 0) - entry.value;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final coins = _save.player.resources['coin'] ?? 0;
    final tokens = _getTokenCount();
    final ownedCount = _save.generals.length;
    final featured = _featuredGenerals;

    return Scaffold(
      backgroundColor: const Color(0xFF0E080B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GameArtLayer(
            assetPath: GameArt.recruitHallBackground,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            fallback: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.25),
                  radius: 1.15,
                  colors: [Color(0xFF7E271D), Color(0xFF180B13)],
                ),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99100710),
                  Color(0x10000000),
                  Color(0xB8100708),
                ],
                stops: [0, 0.5, 1],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 82,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const BrushTitle('神将自选'),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: GameHeaderButton(
                          controlKey: const ValueKey('recruit-back-button'),
                          tooltip: '返回',
                          onPressed: () => Navigator.of(context).pop(_save),
                          icon: Icons.arrow_back_ios_new,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRecruitHero(coins, tokens, ownedCount),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 28),
                    child: Column(
                      children: [
                        OrnateGameFrame(
                          accentColor: const Color(0xFFFFA43A),
                          backgroundColor: const Color(0xE348160F),
                          padding: const EdgeInsets.fromLTRB(11, 12, 11, 12),
                          child: Column(
                            children: [
                              const Text(
                                '英雄集结 · 千抽自选',
                                style: TextStyle(
                                  color: Color(0xFFFFE089),
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFFFF4D18),
                                      blurRadius: 15,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '达成条件可领取四选一 · 当期名将概率提升',
                                style: TextStyle(
                                  color: Color(0xFFFFC5A4),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: featured
                                    .map(
                                      (general) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 3,
                                          ),
                                          child: _buildFeaturedCard(general),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xB31A0908),
                                  border: Border.symmetric(
                                    horizontal: BorderSide(
                                      color: Color(0xAAF7BA5B),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.auto_awesome,
                                      color: Color(0xFFFFD767),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '高级招募 ${RecruitService.advancedPityCounter}/${RecruitService.advancedPityThreshold} · 十次内必得紫将',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _summonButton(
                                label: '招募一次',
                                cost: _costText(
                                  RecruitService.getRecruitCost('normal'),
                                ),
                                color: const Color(0xFFC6552D),
                                enabled:
                                    _canAffordCost(
                                      RecruitService.getRecruitCost('normal'),
                                    ) &&
                                    !_isRecruiting,
                                onTap: () => _doRecruit('normal', false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _summonButton(
                                label: '神将十连',
                                cost: _costText(
                                  RecruitService.getRecruitCost('advanced_ten'),
                                ),
                                color: const Color(0xFFE19B36),
                                enabled:
                                    _canAffordCost(
                                      RecruitService.getRecruitCost(
                                        'advanced_ten',
                                      ),
                                    ) &&
                                    !_isRecruiting,
                                onTap: () => _doRecruit('advanced', true),
                              ),
                            ),
                          ],
                        ),
                        if (_history.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          OrnateGameFrame(
                            title: '招募记录',
                            child: Column(
                              children: _history.reversed
                                  .take(5)
                                  .map(_buildHistoryItem)
                                  .toList(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _showRates,
                          child: const Text('查看招募概率与保底规则'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: -48,
            bottom: -30,
            width: 190,
            height: 300,
            child: IgnorePointer(
              child: GameArtLayer(
                assetPath: GameArt.recruitWarrior,
                alignment: Alignment.bottomLeft,
                opacity: 0.92,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecruitHero(int coins, int tokens, int ownedCount) {
    return SizedBox(
      height: 245,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 14,
            right: 14,
            top: 0,
            child: Row(
              children: [
                _resourceChip('💰', '铜钱', '$coins', const Color(0xFFFFC94D)),
                const SizedBox(width: 7),
                _resourceChip('📜', '招募令', '$tokens', const Color(0xFFE89BFF)),
                const Spacer(),
                Text(
                  '麾下 $ownedCount',
                  style: const TextStyle(
                    color: Color(0xFFE9D6BF),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            right: -6,
            top: 18,
            width: 285,
            height: 226,
            child: IgnorePointer(
              child: GameArtLayer(
                assetPath: GameArt.recruitLady,
                alignment: Alignment.topRight,
                opacity: 1,
              ),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 28,
            child: Transform.rotate(
              angle: -0.035,
              child: const Text(
                '英雄集结',
                style: TextStyle(
                  fontFamily: 'STKaiti',
                  color: Color(0xFFFFE18A),
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(color: Color(0xFFFF3E18), blurRadius: 13),
                    Shadow(color: Colors.black, blurRadius: 3),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 18,
            bottom: 8,
            child: Text(
              '名将临世 · 四选其一',
              style: TextStyle(
                color: Color(0xFFFFC6A1),
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<General> get _featuredGenerals {
    final all = GameDataService.getAllGenerals();
    return [
      'zhangfei',
      'liubei',
      'zhouyu',
      'caocao',
    ].map((id) => all.firstWhere((general) => general.id == id)).toList();
  }

  Widget _buildFeaturedCard(General general) {
    final color = qualityColors[general.quality] ?? const Color(0xFFFFB33F);
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.45), const Color(0xE61D0B09)],
        ),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.38), blurRadius: 9),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                general.camp,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                List.filled(general.star.clamp(1, 5), '★').join(),
                style: const TextStyle(color: Color(0xFFFFDA45), fontSize: 7),
              ),
            ],
          ),
          const SizedBox(height: 5),
          KeyedSubtree(
            key: ValueKey('featured-portrait-${general.id}'),
            child: Container(
              height: 92,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xAA090606),
                border: Border.all(color: color.withValues(alpha: 0.85)),
              ),
              child: ClipRect(
                child: GameArtLayer(
                  assetPath: _featuredPortraitFor(general.id),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            general.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            general.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFCBB6A1), fontSize: 8),
          ),
          const SizedBox(height: 5),
          ClipPath(
            clipper: const _BeveledButtonClipper(cut: 7),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: const Color(0xFFD4562C),
              child: const Text(
                '待招募',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFE9B0),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _featuredPortraitFor(String generalId) => switch (generalId) {
    'zhangfei' => GameArt.battleHero,
    'liubei' => GameArt.loginLvbu,
    'zhouyu' => GameArt.mapGuide,
    _ => GameArt.battleRival,
  };

  Widget _summonButton({
    required String label,
    required String cost,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: ValueKey('summon-button-$label'),
      onTap: enabled ? onTap : null,
      child: ClipPath(
        clipper: const _BeveledButtonClipper(cut: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: enabled
                  ? [
                      color.withValues(alpha: 0.98),
                      const Color(0xFF8D2A1C),
                      const Color(0xFF4A130E),
                    ]
                  : const [Color(0xFF514541), Color(0xFF241D1B)],
            ),
            border: Border.all(
              color: enabled ? const Color(0xFFFFD477) : Colors.grey,
              width: 1.4,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Colors.black, blurRadius: 3)],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                cost,
                style: const TextStyle(color: Color(0xFFFFE4A7), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRates() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildRateTable(),
        ),
      ),
    );
  }

  // Retained for the probability/history bottom sheets.
  // ignore: unused_element
  Widget _buildTavernHeader(int coins, int tokens, int ownedCount) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.accentColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: const Border(bottom: BorderSide(color: Color(0xFF4A3F30))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.local_bar,
                  color: AppTheme.accentColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '天下酒馆',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '四方豪杰，汇聚于此。以诚意招揽天下英才，共谋大业。',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor.withValues(
                          alpha: 0.8,
                        ),
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 资源条
          Row(
            children: [
              _resourceChip('💰', '铜钱', '$coins', AppTheme.accentColor),
              const SizedBox(width: 8),
              _resourceChip('📜', '招募令', '$tokens', Colors.purple),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF4A3F30)),
                ),
                child: Text(
                  '已拥有 $ownedCount 名武将',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resourceChip(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
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
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Retained as a compact fallback card for narrow layouts.
  // ignore: unused_element
  Widget _buildRecruitCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Map<Quality, int> rates,
    required Map<String, int> singleCost,
    required Map<String, int> tenCost,
    required int pityCurrent,
    required int pityMax,
    required String pityLabel,
    required VoidCallback onSingle,
    required VoidCallback onTen,
  }) {
    final canSingle = _canAffordCost(singleCost) && !_isRecruiting;
    final canTen = _canAffordCost(tenCost) && !_isRecruiting;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题区
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.15), AppTheme.cardColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 概率条
                _buildRateBar(rates),
                const SizedBox(height: 8),
                // 保底进度
                _buildPityBar(pityCurrent, pityMax, pityLabel, color),
                const SizedBox(height: 12),
                // 按钮区
                Row(
                  children: [
                    // 单抽
                    Expanded(
                      child: _buildRecruitButton(
                        label: '招募1次',
                        sublabel: _costText(singleCost),
                        enabled: canSingle,
                        color: color,
                        onTap: onSingle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 十连
                    Expanded(
                      child: _buildRecruitButton(
                        label: '招募10次',
                        sublabel: '${_costText(tenCost)} (9折)',
                        enabled: canTen,
                        color: color,
                        onTap: onTen,
                        isPrimary: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateBar(Map<Quality, int> rates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Row(
              children: rates.entries.map((e) {
                return Expanded(
                  flex: e.value,
                  child: Container(color: qualityColors[e.key]),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 2,
          children: rates.entries.map((e) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: qualityColors[e.key],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  '${qualityNames[e.key]}${e.value}%',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 9,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPityBar(int current, int max, String label, Color color) {
    final progress = current / max;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 10,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$current/$max',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFF333333),
                  valueColor: AlwaysStoppedAnimation(
                    color.withValues(alpha: 0.7),
                  ),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecruitButton({
    required String label,
    required String sublabel,
    required bool enabled,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: enabled
              ? (isPrimary
                    ? color.withValues(alpha: 0.2)
                    : AppTheme.surfaceColor)
              : AppTheme.surfaceColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled
                ? color.withValues(alpha: 0.6)
                : const Color(0xFF4A3F30),
            width: isPrimary ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: enabled ? color : Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                color: enabled
                    ? AppTheme.textSecondaryColor
                    : Colors.grey.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.accentColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(_RecruitRecord record) {
    final qColor = qualityColors[record.general.quality] ?? AppTheme.textColor;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: qColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                record.general.name[0],
                style: TextStyle(
                  color: qColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Text(
                  record.general.name,
                  style: TextStyle(
                    color: qColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
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
                    qualityNames[record.general.quality] ?? '',
                    style: TextStyle(color: qColor, fontSize: 8),
                  ),
                ),
                if (record.isDuplicate) ...[
                  const SizedBox(width: 4),
                  const Text(
                    '+100经验',
                    style: TextStyle(color: Colors.orange, fontSize: 9),
                  ),
                ],
              ],
            ),
          ),
          Text(
            record.isTenPull ? '十连' : '单抽',
            style: const TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateTable() {
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
            '普通招募概率',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ..._rateRow([
            (Quality.white, '40%'),
            (Quality.green, '30%'),
            (Quality.blue, '20%'),
            (Quality.purple, '8%'),
            (Quality.orange, '2%'),
          ]),
          const SizedBox(height: 8),
          const Text(
            '高级招募概率',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ..._rateRow([
            (Quality.blue, '45%'),
            (Quality.purple, '35%'),
            (Quality.orange, '15%'),
            (Quality.red, '5%'),
          ]),
          const SizedBox(height: 8),
          const Text(
            '保底机制',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '· 普通招募：连续30次未出蓝色以上，第30次必出蓝色以上',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const Text(
            '· 高级招募：连续10次未出紫色以上，第10次必出紫色以上',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const Text(
            '· 重复获得已有武将时，转化为100经验',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _rateRow(List<(Quality, String)> items) {
    return [
      Wrap(
        spacing: 10,
        children: items
            .map(
              (item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: qualityColors[item.$1],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${qualityNames[item.$1]} ${item.$2}',
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    ];
  }

  String _costText(Map<String, int> cost) {
    final parts = <String>[];
    for (final e in cost.entries) {
      if (e.key == 'recruit_token') {
        parts.add('招募令×${e.value}');
      } else if (e.key == 'coin') {
        parts.add('铜钱${e.value}');
      }
    }
    return parts.join(' + ');
  }

  void _doRecruit(String type, bool isTen) {
    final costKey = isTen ? '${type}_ten' : type;
    final cost = RecruitService.getRecruitCost(costKey);

    if (!_canAffordCost(cost)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getInsufficientText(cost)),
          backgroundColor: AppTheme.dangerColor,
        ),
      );
      return;
    }

    setState(() => _isRecruiting = true);
    _deductCost(cost);

    // 执行招募
    final List<General> results;
    if (isTen) {
      results = type == 'advanced'
          ? RecruitService.advancedRecruitTen()
          : RecruitService.normalRecruitTen();
    } else {
      results = [
        type == 'advanced'
            ? RecruitService.advancedRecruit()
            : RecruitService.normalRecruit(),
      ];
    }

    // 处理结果
    final newGenerals = <General>[];
    final duplicates = <General>[];
    for (final g in results) {
      final existing = _save.generals.where((x) => x.id == g.id).firstOrNull;
      if (existing != null) {
        existing.exp += 100;
        duplicates.add(existing);
        _history.add(_RecruitRecord(g, true, isTen));
      } else {
        _save.generals.add(g);
        newGenerals.add(g);
        _history.add(_RecruitRecord(g, false, isTen));
      }
    }

    // 更新招募任务
    for (final q in _save.quests) {
      for (final obj in q.objectives) {
        if (obj.type == 'recruit') {
          obj.currentCount += results.length;
        }
      }
    }

    // 显示招募结果
    _showRecruitResult(results, newGenerals, duplicates, isTen);
  }

  void _showRecruitResult(
    List<General> results,
    List<General> newGenerals,
    List<General> duplicates,
    bool isTen,
  ) {
    // 找最高品质
    General best = results.first;
    for (final g in results) {
      if (g.quality.index > best.quality.index) best = g;
    }
    final bestColor = qualityColors[best.quality] ?? AppTheme.textColor;

    // 动画
    _animCtrl.forward(from: 0);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: bestColor.withValues(alpha: 0.6), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Text(
                isTen ? '十连招募结果' : '招募结果',
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // 最佳武将展示
              ScaleTransition(
                scale: _revealAnim,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bestColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: bestColor.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: bestColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: bestColor, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            best.name[0],
                            style: TextStyle(
                              color: bestColor,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        best.name,
                        style: TextStyle(
                          color: bestColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: bestColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              qualityNames[best.quality] ?? '',
                              style: TextStyle(
                                color: bestColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            troopNames[best.troopType] ?? '',
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (duplicates.contains(best))
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            '已拥有 → +100经验',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // 全部结果列表（十连时）
              if (isTen) ...[
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF4A3F30)),
                const SizedBox(height: 8),
                const Text(
                  '全部结果',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: results.map((g) {
                    final c = qualityColors[g.quality] ?? AppTheme.textColor;
                    final isDup = duplicates.contains(g);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: c.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            g.name,
                            style: TextStyle(
                              color: c,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isDup)
                            const Text(
                              ' +100',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 9,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
              // 统计
              if (newGenerals.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '新获得 ${newGenerals.length} 名武将'
                  '${duplicates.isNotEmpty ? '，${duplicates.length} 名重复转化为经验' : ''}',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() => _isRecruiting = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  '确认',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _isRecruiting = false);
    });
  }

  String _getInsufficientText(Map<String, int> cost) {
    for (final e in cost.entries) {
      if (e.key == 'recruit_token') {
        if (_getTokenCount() < e.value) return '招募令不足，需要${e.value}个招募令';
      } else if (e.key == 'coin') {
        if ((_save.player.resources['coin'] ?? 0) < e.value) {
          return '铜钱不足，需要${e.value}铜钱';
        }
      }
    }
    return '资源不足';
  }
}

class _BeveledButtonClipper extends CustomClipper<Path> {
  final double cut;

  const _BeveledButtonClipper({required this.cut});

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(cut, 0)
      ..lineTo(size.width - cut, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(cut, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
  }

  @override
  bool shouldReclip(covariant _BeveledButtonClipper oldClipper) =>
      oldClipper.cut != cut;
}

class _RecruitRecord {
  final General general;
  final bool isDuplicate;
  final bool isTenPull;

  _RecruitRecord(this.general, this.isDuplicate, this.isTenPull);
}
