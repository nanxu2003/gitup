import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/constants.dart';
import '../app/game_art.dart';
import '../models/game_save.dart';
import '../models/battle.dart';
import '../models/enemy.dart';
import '../models/formation.dart';
import '../models/skill.dart';
import '../services/battle_engine.dart';
import '../services/game_data_service.dart';
import '../widgets/game_art_layer.dart';
import '../widgets/ornate_game_frame.dart';
import '../widgets/styled_button.dart';

class BattleScreen extends StatefulWidget {
  final GameSave gameSave;
  final List<String> enemyIds;
  final String stageId;

  const BattleScreen({
    super.key,
    required this.gameSave,
    required this.enemyIds,
    required this.stageId,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late BattleState _bs;
  final _logCtrl = ScrollController();
  String? _targetId;
  bool _isAuto = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initBattle();
  }

  void _initBattle() {
    var allies = widget.gameSave.generals.where((g) => g.isDeployed).toList();
    if (allies.isEmpty && widget.gameSave.generals.isNotEmpty) {
      final count = widget.gameSave.generals.length.clamp(0, 5);
      for (int i = 0; i < count; i++) {
        widget.gameSave.generals[i].isDeployed = true;
      }
      allies = widget.gameSave.generals.where((g) => g.isDeployed).toList();
    }

    final enemies = <Enemy>[];
    for (final eid in widget.enemyIds) {
      final enemy = GameDataService.findEnemy(eid);
      if (enemy != null) enemies.add(enemy);
    }
    if (enemies.isEmpty) {
      enemies.add(
        Enemy(
          id: 'default',
          name: '黄巾兵',
          hp: 600,
          maxHp: 600,
          force: 30,
          command: 20,
          speed: 25,
        ),
      );
    }

    final formations = widget.gameSave.formations;
    final formation = formations.isNotEmpty
        ? formations.first
        : Formation(id: 'default', name: '默认阵型');

    _bs = BattleEngine.initBattle(allies, enemies, formation);
    _autoSelectTarget();
    _scrollLog();

    // 如果是自动战斗或当前是敌方回合
    if (_bs.phase == BattlePhase.enemyTurn) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _runEnemyTurns());
    }
  }

  @override
  void dispose() {
    _logCtrl.dispose();
    super.dispose();
  }

  void _autoSelectTarget() {
    final alive = _bs.aliveEnemies;
    if (alive.isNotEmpty &&
        (_targetId == null || alive.every((u) => u.unitId != _targetId))) {
      _targetId = alive.first.unitId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final actor = BattleEngine.getCurrentActor(_bs);
    final pendingAllies = BattleEngine.getPendingAllies(_bs);

    return Scaffold(
      backgroundColor: const Color(0xFF160B08),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GameArtLayer(
            assetPath: GameArt.battlefieldBackground,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            fallback: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF842013),
                    Color(0xFFB75A20),
                    Color(0xFF2A0908),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: -88,
            bottom: 102,
            width: 245,
            height: 365,
            child: IgnorePointer(
              child: GameArtLayer(
                assetPath: GameArt.battleHero,
                alignment: Alignment.bottomLeft,
                opacity: 0.4,
              ),
            ),
          ),
          const Positioned(
            right: -92,
            bottom: 105,
            width: 250,
            height: 372,
            child: IgnorePointer(
              child: GameArtLayer(
                assetPath: GameArt.battleRival,
                alignment: Alignment.bottomRight,
                opacity: 0.4,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC120707),
                  Color(0x12000000),
                  Color(0xE6170808),
                ],
                stops: [0, 0.48, 1],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 92,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const BrushTitle('战火争锋'),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: GameHeaderButton(
                          controlKey: const ValueKey('battle-close-button'),
                          tooltip: '退出战斗',
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: Icons.close,
                          accentColor: const Color(0xFFFFBE5C),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xD9180908),
                            border: Border.all(color: const Color(0xFFFFC05A)),
                          ),
                          child: Text(
                            '${_bs.currentRound}/${_bs.maxRounds} 回合',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xC7190B08),
                    border: Border.symmetric(
                      horizontal: BorderSide(color: Color(0x998A6840)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        actor?.isAlly == true
                            ? Icons.flash_on
                            : Icons.warning_amber,
                        color: actor?.isAlly == true
                            ? const Color(0xFF69F2FF)
                            : const Color(0xFFFF6348),
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          actor != null ? '${actor.name} 行动中' : '战局结算中',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '待行动 ${pendingAllies.length}',
                        style: const TextStyle(
                          color: Color(0xFFD9BE9C),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        left: 10,
                        right: 10,
                        top: 12,
                        child: _buildUnitList('敌军阵列', _bs.enemyUnits, false),
                      ),
                      Align(
                        alignment: const Alignment(0, 0.12),
                        child: _buildBattlePulse(),
                      ),
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 12,
                        child: _buildUnitList('我军阵列', _bs.allyUnits, true),
                      ),
                    ],
                  ),
                ),
                _buildCommandBar(actor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitList(String title, List<BattleUnit> units, bool isAlly) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xB31B0C09),
        border: Border.all(
          color: isAlly ? const Color(0xAA53E4F2) : const Color(0xAAFF6A47),
        ),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 17,
                color: isAlly
                    ? const Color(0xFF5FE6F1)
                    : const Color(0xFFFF5E3E),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isAlly
                      ? const Color(0xFFBDFBFF)
                      : const Color(0xFFFFC2A8),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: units.map((unit) => _buildUnitRow(unit, isAlly)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitRow(BattleUnit unit, bool isAlly) {
    final isActor = _bs.currentActorId == unit.unitId;
    final isSelectable =
        !isAlly && _bs.phase == BattlePhase.playerTurn && !unit.isDead;
    final isSelected = _targetId == unit.unitId;
    final hasActed = _bs.actedUnitIds.contains(unit.unitId);
    final hpPercent = unit.maxHp > 0 ? unit.hp / unit.maxHp : 0.0;

    return GestureDetector(
      onTap: isSelectable
          ? () => setState(() => _targetId = unit.unitId)
          : null,
      child: Container(
        width: 72,
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 6),
        decoration: BoxDecoration(
          color: unit.isDead
              ? const Color(0xB3292929)
              : const Color(0xD9251711),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD12E)
                : isActor
                ? const Color(0xFFFFFFFF)
                : isAlly
                ? const Color(0x9962D9E8)
                : const Color(0x99E25239),
            width: isSelected || isActor ? 2 : 1,
          ),
          boxShadow: isActor
              ? [
                  BoxShadow(
                    color:
                        (isAlly ? Colors.cyanAccent : Colors.deepOrangeAccent)
                            .withValues(alpha: 0.65),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                if (isActor)
                  Icon(
                    Icons.play_arrow,
                    size: 12,
                    color: isAlly ? Colors.cyanAccent : Colors.orangeAccent,
                  )
                else if (hasActed && !unit.isDead)
                  const Icon(Icons.check, size: 11, color: Color(0xFFB9AB98)),
                Expanded(
                  child: Text(
                    unit.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: unit.isDead
                          ? const Color(0xFF888078)
                          : Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      decoration: unit.isDead
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: hpPercent,
                backgroundColor: const Color(0xFF2B211E),
                valueColor: AlwaysStoppedAnimation(
                  hpPercent > 0.5
                      ? const Color(0xFF39D876)
                      : hpPercent > 0.2
                      ? Colors.orange
                      : const Color(0xFFE82B2B),
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${unit.hp}/${unit.maxHp}',
              style: const TextStyle(color: Color(0xFFE7D9C5), fontSize: 8),
            ),
            if (isAlly && !unit.isDead)
              Text(
                '怒 ${unit.rage}',
                style: const TextStyle(color: Color(0xFFFFC52F), fontSize: 8),
              ),
            if (unit.statusEffects.isNotEmpty && !unit.isDead)
              Wrap(
                spacing: 2,
                children: unit.statusEffects
                    .map(
                      (effect) => Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _statusColor(effect.type),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattlePulse() {
    final latest = _bs.logs.reversed
        .where(
          (entry) =>
              entry.action.trim().isNotEmpty && !entry.action.contains('══'),
        )
        .take(2)
        .toList();
    return IgnorePointer(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xCC120406), Color(0xB36E160D), Color(0xCC120406)],
          ),
          border: Border.all(color: const Color(0x99FFC056)),
          boxShadow: const [
            BoxShadow(color: Color(0x99FF3C00), blurRadius: 22),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '决 战',
              style: TextStyle(
                color: Color(0xFFFFE5A4),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 8,
              ),
            ),
            if (latest.isNotEmpty) ...[
              const SizedBox(height: 4),
              ...latest.map(
                (entry) => Text(
                  '${entry.actorName.isNotEmpty ? '${entry.actorName} · ' : ''}${entry.action}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String type) {
    switch (type) {
      case 'stun':
        return Colors.yellow;
      case 'burn':
        return Colors.orange;
      case 'poison':
        return Colors.green;
      case 'defend':
        return Colors.blue;
      case 'inspire':
        return AppTheme.accentColor;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCommandBar(BattleUnit? actor) {
    if (_bs.phase == BattlePhase.result) {
      return _buildResultBar();
    }
    if (_bs.phase == BattlePhase.enemyTurn) {
      if (!_isProcessing) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _runEnemyTurns());
      }
      return Container(
        padding: const EdgeInsets.all(12),
        color: AppTheme.primaryColor,
        child: const Center(
          child: Text(
            '⚔ 敌方行动中...',
            style: TextStyle(color: AppTheme.dangerColor, fontSize: 14),
          ),
        ),
      );
    }
    if (actor == null || !actor.isAlly) {
      return Container(
        padding: const EdgeInsets.all(12),
        color: AppTheme.primaryColor,
        child: const Center(
          child: Text(
            '等待...',
            style: TextStyle(color: AppTheme.textSecondaryColor),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        border: Border(top: BorderSide(color: Color(0xFF4A3F30))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 当前行动者
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person,
                  size: 14,
                  color: AppTheme.successColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${actor.name} 的回合',
                  style: const TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'HP:${actor.hp}/${actor.maxHp}',
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '怒:${actor.rage}',
                  style: const TextStyle(
                    color: AppTheme.rageColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // 指令按钮
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StyledButton(
                text: '⚔ 攻击',
                onPressed: _targetId != null
                    ? () => _doAttack(actor.unitId)
                    : null,
              ),
              StyledButton(
                text: '✦ 技能',
                onPressed: () => _showSkillMenu(actor),
              ),
              StyledButton(
                text: '🛡 防御',
                onPressed: () => _doDefend(actor.unitId),
              ),
              StyledButton(
                text: '💊 道具',
                onPressed: () => _showItemMenu(actor),
              ),
              StyledButton(
                text: _isAuto ? '⏸ 停止' : '▶ 自动',
                onPressed: _toggleAuto,
              ),
              StyledButton(text: '🏃 逃跑', isDanger: true, onPressed: _doEscape),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppTheme.primaryColor,
      child: StyledButton(
        text: '查看战报',
        icon: Icons.assessment,
        width: 200,
        onPressed: () {
          final result = BattleEngine.calculateResult(_bs);
          Navigator.of(context).pushReplacementNamed(
            '/battle_result',
            arguments: {
              'result': result,
              'gameSave': widget.gameSave,
              'stageId': widget.stageId,
            },
          );
        },
      ),
    );
  }

  // ========== 行动执行 ==========

  void _doAttack(String actorId) {
    if (_targetId == null || _isProcessing) return;
    setState(() {
      _bs = BattleEngine.executeAttack(_bs, actorId, _targetId!);
      _autoSelectTarget();
    });
    _scrollLog();
    _handlePostAction();
  }

  void _doDefend(String actorId) {
    if (_isProcessing) return;
    setState(() {
      _bs = BattleEngine.executeDefend(_bs, actorId);
    });
    _scrollLog();
    _handlePostAction();
  }

  void _doEscape() {
    if (_isProcessing) return;
    setState(() {
      _bs = BattleEngine.executeEscape(_bs);
    });
    _scrollLog();
    if (_bs.phase == BattlePhase.result) {
      // 直接结算
    } else {
      _handlePostAction();
    }
  }

  void _handlePostAction() {
    if (_bs.phase == BattlePhase.enemyTurn) {
      _runEnemyTurns();
    } else if (_isAuto && _bs.phase == BattlePhase.playerTurn && !_bs.isOver) {
      Future.delayed(const Duration(milliseconds: 400), _autoAction);
    }
  }

  void _runEnemyTurns() {
    if (!mounted || _isProcessing) return;
    if (_bs.phase != BattlePhase.enemyTurn) return;

    _isProcessing = true;
    _executeOneEnemy();
  }

  void _executeOneEnemy() {
    if (!mounted) return;
    if (_bs.phase != BattlePhase.enemyTurn || _bs.isOver) {
      _isProcessing = false;
      setState(() {});
      if (_isAuto && _bs.phase == BattlePhase.playerTurn && !_bs.isOver) {
        Future.delayed(const Duration(milliseconds: 400), _autoAction);
      }
      return;
    }

    setState(() {
      // 敌方AI：优先攻击血量最低的友方
      final actor = BattleEngine.getCurrentActor(_bs);
      if (actor != null && !actor.isAlly) {
        final aliveAllies = _bs.aliveAllies;
        if (aliveAllies.isNotEmpty) {
          // 优先使用技能
          bool usedSkill = false;
          for (final sid in actor.skillIds) {
            final skill = GameDataService.findSkill(sid);
            if (skill != null &&
                actor.rage >= skill.costRage &&
                (actor.skillCooldowns[sid] ?? 0) <= 0) {
              final lowestTarget = aliveAllies.toList()
                ..sort((a, b) => a.hp.compareTo(b.hp));
              _bs = BattleEngine.executeSkill(
                _bs,
                actor.unitId,
                sid,
                lowestTarget.first.unitId,
              );
              usedSkill = true;
              break;
            }
          }
          if (!usedSkill) {
            // 普通攻击血量最低的
            final sorted = aliveAllies.toList()
              ..sort((a, b) => a.hp.compareTo(b.hp));
            _bs = BattleEngine.executeAttack(
              _bs,
              actor.unitId,
              sorted.first.unitId,
            );
          }
        }
      }
      _autoSelectTarget();
    });
    _scrollLog();

    if (_bs.phase == BattlePhase.enemyTurn && !_bs.isOver) {
      final delay = Duration(milliseconds: (600 / _bs.battleSpeed).round());
      Future.delayed(delay, _executeOneEnemy);
    } else {
      _isProcessing = false;
      setState(() {});
      if (_isAuto && _bs.phase == BattlePhase.playerTurn && !_bs.isOver) {
        Future.delayed(const Duration(milliseconds: 400), _autoAction);
      }
    }
  }

  void _toggleAuto() {
    setState(() {
      _isAuto = !_isAuto;
      _bs.isAutoBattle = _isAuto;
    });
    if (_isAuto && _bs.phase == BattlePhase.playerTurn && !_bs.isOver) {
      _autoAction();
    }
  }

  void _autoAction() {
    if (!_isAuto || _bs.isOver || _bs.phase != BattlePhase.playerTurn) return;
    final actor = BattleEngine.getCurrentActor(_bs);
    if (actor == null || !actor.isAlly) return;

    // AI：优先使用技能，否则普攻
    final enemies = _bs.aliveEnemies;
    if (enemies.isEmpty) return;
    _targetId = enemies.first.unitId;

    bool usedSkill = false;
    for (final sid in actor.skillIds) {
      final skill = GameDataService.findSkill(sid);
      if (skill != null &&
          skill.type == SkillType.active &&
          actor.rage >= skill.costRage &&
          (actor.skillCooldowns[sid] ?? 0) <= 0) {
        setState(() {
          _bs = BattleEngine.executeSkill(_bs, actor.unitId, sid, _targetId);
          _autoSelectTarget();
        });
        _scrollLog();
        usedSkill = true;
        break;
      }
    }

    if (!usedSkill) {
      _doAttack(actor.unitId);
      return; // _doAttack handles post-action
    }

    _handlePostAction();
  }

  // ========== 技能/道具菜单 ==========

  void _showSkillMenu(BattleUnit actor) {
    final skills = actor.skillIds
        .map((sid) => GameDataService.findSkill(sid))
        .where((s) => s != null)
        .cast()
        .toList();

    if (skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('该武将没有技能', style: TextStyle(color: AppTheme.textColor)),
          backgroundColor: AppTheme.cardColor,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // 分离主动技能和被动技能
    final activeSkills = skills
        .where((s) => s.type != SkillType.passive)
        .toList();
    final passiveSkills = skills
        .where((s) => s.type == SkillType.passive)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '【${actor.name}】技能',
                  style: const TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '怒气: ${actor.rage}/100',
                  style: const TextStyle(
                    color: AppTheme.rageColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 1,
              color: AppTheme.accentColor.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 8),
            // 主动技能
            if (activeSkills.isNotEmpty) ...[
              const Text(
                '可用技能',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...activeSkills.map((skill) {
                final cd = actor.skillCooldowns[skill.id] ?? 0;
                final hasRage = actor.rage >= skill.costRage;
                final noCooldown = cd <= 0;
                final canUse = hasRage && noCooldown;
                String? reason;
                if (!hasRage) reason = '怒气不足(${actor.rage}/${skill.costRage})';
                if (!noCooldown) reason = '冷却中($cd回合)';
                return _buildSkillTile(skill, canUse, reason, actor, ctx);
              }),
            ],
            // 被动技能
            if (passiveSkills.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                '被动技能',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...passiveSkills.map(
                (skill) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.visibility_off,
                        size: 16,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              skill.name,
                              style: const TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              skill.description,
                              style: const TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '已激活',
                          style: TextStyle(
                            color: AppTheme.successColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillTile(
    Skill skill,
    bool canUse,
    String? reason,
    BattleUnit actor,
    BuildContext sheetCtx,
  ) {
    return GestureDetector(
      onTap: () {
        if (!canUse) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${skill.name}: ${reason ?? "无法使用"}',
                style: const TextStyle(color: AppTheme.textColor, fontSize: 13),
              ),
              backgroundColor: AppTheme.cardColor,
              duration: const Duration(seconds: 1),
            ),
          );
          return;
        }
        Navigator.of(sheetCtx).pop();
        setState(() {
          _bs = BattleEngine.executeSkill(
            _bs,
            actor.unitId,
            skill.id,
            _targetId,
          );
          _autoSelectTarget();
        });
        _scrollLog();
        _handlePostAction();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: canUse
              ? AppTheme.cardColor
              : AppTheme.cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canUse
                ? AppTheme.accentColor.withValues(alpha: 0.5)
                : const Color(0xFF4A3F30),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (canUse ? AppTheme.accentColor : Colors.grey).withValues(
                  alpha: 0.15,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 20,
                color: canUse ? AppTheme.accentColor : Colors.grey,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        skill.name,
                        style: TextStyle(
                          color: canUse
                              ? AppTheme.textColor
                              : AppTheme.textSecondaryColor,
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
                          color: AppTheme.rageColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '怒气${skill.costRage}',
                          style: TextStyle(
                            color: canUse ? AppTheme.rageColor : Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    skill.description,
                    style: TextStyle(
                      color: canUse ? AppTheme.textSecondaryColor : Colors.grey,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                  if (reason != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        reason,
                        style: const TextStyle(
                          color: AppTheme.dangerColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (canUse)
              const Icon(
                Icons.chevron_right,
                color: AppTheme.accentColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showItemMenu(BattleUnit actor) {
    final consumables = widget.gameSave.inventory
        .where((i) => i.type == ItemType.consumable && i.quantity > 0)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text(
            '使用道具',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (consumables.isEmpty)
            const Text(
              '没有可用道具',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ...consumables.map(
            (item) => ListTile(
              title: Text(
                '${item.name} ×${item.quantity}',
                style: const TextStyle(color: AppTheme.textColor),
              ),
              subtitle: Text(
                item.description,
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _bs = BattleEngine.useItem(_bs, actor.unitId, item.id);
                  item.quantity--;
                });
                _scrollLog();
                _handlePostAction();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _scrollLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logCtrl.hasClients) {
        _logCtrl.animateTo(
          _logCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
