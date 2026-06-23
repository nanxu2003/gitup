import 'dart:math';
import '../app/constants.dart';
import '../models/battle.dart';
import '../models/general.dart';
import '../models/enemy.dart';
import '../models/formation.dart';
import '../models/skill.dart';
import 'game_data_service.dart';

class BattleEngine {
  static final Random _random = Random();

  // ========== 初始化战斗 ==========
  static BattleState initBattle(
    List<General> allies,
    List<Enemy> enemies,
    Formation formation,
  ) {
    final allyUnits = <BattleUnit>[];
    final deployedIds = formation.deployedGeneralIds;

    // 所有部署的武将都应参战，阵型槽位只决定位置
    for (int i = 0; i < allies.length; i++) {
      final g = allies[i];
      // 确定武将在阵型中的位置（行号）
      int row = 1; // 默认中间行
      if (deployedIds.contains(g.id)) {
        for (int r = 0; r < formation.slots.length; r++) {
          if (formation.slots[r].contains(g.id)) {
            row = r;
            break;
          }
        }
      } else {
        // 未在阵型槽位的武将，按顺序分配位置
        row = i % 3; // 0=前排, 1=中排, 2=后排
      }

      allyUnits.add(
        BattleUnit(
          unitId: g.id,
          name: g.name,
          isAlly: true,
          hp: g.hp,
          maxHp: g.hp,
          rage: 20,
          troopType: g.troopType,
          force: g.attackPower,
          intelligence: g.attributes.intelligence + g.level * 2,
          command: g.defense,
          speed: g.attributes.speed + g.level,
          skillIds: List<String>.from(g.skillIds),
          position: row,
        ),
      );
    }

    final enemyUnits = <BattleUnit>[];
    for (final e in enemies) {
      enemyUnits.add(
        BattleUnit(
          unitId: e.id,
          name: e.name,
          isAlly: false,
          hp: e.hp,
          maxHp: e.maxHp,
          rage: 10,
          troopType: e.troopType,
          force: e.force,
          intelligence: e.intelligence,
          command: e.command,
          speed: e.speed,
          skillIds: List<String>.from(e.skillIds),
          position: e.isBoss ? 0 : 1,
        ),
      );
    }

    // 生成行动顺序（按速度排序）
    final allUnits = [...allyUnits, ...enemyUnits];
    allUnits.sort((a, b) => b.speed.compareTo(a.speed));
    final turnOrder = allUnits.map((u) => u.unitId).toList();

    final state = BattleState(
      battleId: 'battle_${DateTime.now().millisecondsSinceEpoch}',
      allyUnits: allyUnits,
      enemyUnits: enemyUnits,
      phase: BattlePhase.playerTurn,
      currentRound: 1,
      turnOrder: turnOrder,
    );

    state.logs.add(
      BattleLogEntry(
        round: 0,
        action: '═══════════════════════════',
        isImportant: true,
      ),
    );
    state.logs.add(
      BattleLogEntry(round: 0, action: '  第1回合开始', isImportant: true),
    );
    state.logs.add(
      BattleLogEntry(
        round: 0,
        action: '  我军${allyUnits.length}人 对阵 敌军${enemyUnits.length}人',
        isImportant: true,
      ),
    );
    state.logs.add(
      BattleLogEntry(
        round: 0,
        action: '═══════════════════════════',
        isImportant: true,
      ),
    );

    // 检查合击条件
    _checkAndLogCombo(state);

    // 激活被动技能
    _activatePassives(state);

    // 确定第一个行动者
    _advanceToNextActor(state);
    return state;
  }

  // ========== 回合轮转逻辑 ==========

  // 推进到下一个行动者
  static void _advanceToNextActor(BattleState state) {
    // 标记当前行动者已完成
    if (state.currentActorId != null) {
      state.actedUnitIds.add(state.currentActorId!);
    }

    // 检查战斗是否结束
    if (_checkBattleEnd(state)) return;

    // 从行动顺序中找下一个未行动且存活的单位
    for (final uid in state.turnOrder) {
      if (state.actedUnitIds.contains(uid)) continue;
      final unit = _findUnit(state, uid);
      if (unit == null || unit.isDead) continue;

      // 眩晕检查
      if (unit.isStunned) {
        state.actedUnitIds.add(uid);
        state.logs.add(
          BattleLogEntry(
            round: state.currentRound,
            actorName: unit.name,
            action: '处于眩晕状态，无法行动！',
          ),
        );
        continue;
      }

      state.currentActorId = uid;
      state.phase = unit.isAlly
          ? BattlePhase.playerTurn
          : BattlePhase.enemyTurn;
      return;
    }

    // 所有人都行动过了，开始新回合
    _startNewRound(state);
  }

  // 开始新回合
  static void _startNewRound(BattleState state) {
    if (_checkBattleEnd(state)) return;

    state.currentRound++;
    state.actedUnitIds.clear();

    // 处理状态效果（灼烧/中毒等）
    _processStatusEffects(state);

    if (_checkBattleEnd(state)) return;

    // 减少技能冷却
    for (final unit in [...state.allyUnits, ...state.enemyUnits]) {
      if (unit.isDead) continue;
      for (final key in unit.skillCooldowns.keys.toList()) {
        if (unit.skillCooldowns[key]! > 0) {
          unit.skillCooldowns[key] = unit.skillCooldowns[key]! - 1;
        }
      }
    }

    state.logs.add(
      BattleLogEntry(
        round: state.currentRound,
        action: '──── 第${state.currentRound}回合开始 ────',
        isImportant: true,
      ),
    );

    // 重新按当前存活单位生成行动顺序
    final allAlive = [...state.aliveAllies, ...state.aliveEnemies];
    allAlive.sort((a, b) => b.speed.compareTo(a.speed));
    state.turnOrder = allAlive.map((u) => u.unitId).toList();

    // 找到第一个行动者
    state.currentActorId = null;
    _advanceToNextActor(state);
  }

  // 检查战斗是否结束
  static bool _checkBattleEnd(BattleState state) {
    if (state.aliveAllies.isEmpty ||
        state.aliveEnemies.isEmpty ||
        state.currentRound > state.maxRounds) {
      state.phase = BattlePhase.result;
      state.currentActorId = null;
      return true;
    }
    return false;
  }

  // ========== 玩家行动 ==========

  // 执行攻击
  static BattleState executeAttack(
    BattleState state,
    String attackerId,
    String targetId,
  ) {
    final newState = BattleState.fromJson(state.toJson());
    final attacker = _findUnit(newState, attackerId);
    final defender = _findUnit(newState, targetId);
    if (attacker == null || defender == null) return newState;

    final hit = checkHit(attacker, defender);
    if (!hit) {
      newState.logs.add(
        BattleLogEntry(
          round: newState.currentRound,
          actorName: attacker.name,
          action: '挥刀斩向${defender.name}——未命中！',
        ),
      );
    } else {
      final damage = calculateDamage(attacker, defender, null);
      final isCrit = _wasLastCrit;
      defender.hp = max(0, defender.hp - damage);
      attacker.rage = min(100, attacker.rage + 15);

      newState.logs.add(
        BattleLogEntry(
          round: newState.currentRound,
          actorName: attacker.name,
          action: '${isCrit ? '暴击！' : ''}攻击${defender.name}',
          damages: {defender.name: damage},
          affectedNames: [defender.name],
        ),
      );

      if (defender.isDead) {
        newState.logs.add(
          BattleLogEntry(
            round: newState.currentRound,
            action: '✦ ${defender.name}已被击破！',
            isImportant: true,
          ),
        );
      }
    }

    _advanceToNextActor(newState);
    return newState;
  }

  // 执行技能
  static BattleState executeSkill(
    BattleState state,
    String attackerId,
    String skillId,
    String? targetId,
  ) {
    final newState = BattleState.fromJson(state.toJson());
    final attacker = _findUnit(newState, attackerId);
    if (attacker == null) return newState;

    final skill = GameDataService.findSkill(skillId);
    if (skill == null) return newState;
    if (attacker.rage < skill.costRage) return newState;

    // 冷却检查
    final cd = attacker.skillCooldowns[skillId] ?? 0;
    if (cd > 0) return newState;

    attacker.rage -= skill.costRage;
    attacker.skillCooldowns[skillId] = skill.cooldown;

    newState.logs.add(
      BattleLogEntry(
        round: newState.currentRound,
        actorName: attacker.name,
        action: '发动【${skill.name}】！',
        isImportant: true,
      ),
    );

    // 治疗/增益类技能
    if (skill.effects.any((e) => e.type == 'heal')) {
      final healTargets = _getTargets(
        newState,
        skill.targetType,
        attacker.isAlly,
        targetId,
      );
      for (final target in healTargets) {
        final healAmount =
            (target.maxHp *
                    skill.effects.firstWhere((e) => e.type == 'heal').value)
                .round();
        target.hp = min(target.maxHp, target.hp + healAmount);
        newState.logs.add(
          BattleLogEntry(
            round: newState.currentRound,
            action: '${target.name}恢复了 $healAmount 点生命！',
          ),
        );
      }
      _advanceToNextActor(newState);
      return newState;
    }

    // 增益Buff类技能
    if (skill.effects.every((e) => e.type == 'buff' || e.type == 'shield')) {
      final buffTargets = _getTargets(
        newState,
        skill.targetType,
        attacker.isAlly,
        targetId,
      );
      for (final target in buffTargets) {
        for (final effect in skill.effects) {
          target.statusEffects.add(
            StatusEffect(
              type: effect.type,
              remainingRounds: effect.duration,
              value: effect.value,
            ),
          );
        }
        newState.logs.add(
          BattleLogEntry(
            round: newState.currentRound,
            action: '${target.name}获得了增益效果！',
          ),
        );
      }
      _advanceToNextActor(newState);
      return newState;
    }

    // 伤害类技能
    final targets = _getTargets(
      newState,
      skill.targetType,
      attacker.isAlly,
      targetId,
    );
    final damages = <String, int>{};

    for (final target in targets) {
      int dmg;
      if (skill.scaleAttribute == 'intelligence') {
        dmg = _calcStrategyDamage(attacker, target, skill);
      } else {
        dmg = calculateDamage(attacker, target, skill);
      }
      target.hp = max(0, target.hp - dmg);
      damages[target.name] = dmg;

      // 处理附加效果
      for (final effect in skill.effects) {
        if (effect.type == 'damage' ||
            effect.type == 'heal' ||
            effect.type == 'buff') {
          continue;
        }
        if (_random.nextDouble() <= effect.chance) {
          target.statusEffects.add(
            StatusEffect(
              type: effect.type,
              remainingRounds: effect.duration,
              value: effect.value,
            ),
          );
          newState.logs.add(
            BattleLogEntry(
              round: newState.currentRound,
              action: '  → ${target.name}陷入【${_effectName(effect.type)}】！',
            ),
          );
        }
      }

      if (target.isDead) {
        newState.logs.add(
          BattleLogEntry(
            round: newState.currentRound,
            action: '  ✦ ${target.name}已被击破！',
            isImportant: true,
          ),
        );
      }
    }

    newState.logs.add(
      BattleLogEntry(
        round: newState.currentRound,
        actorName: attacker.name,
        action: '【${skill.name}】造成伤害',
        damages: damages,
        affectedNames: targets.map((t) => t.name).toList(),
      ),
    );

    _advanceToNextActor(newState);
    return newState;
  }

  // 防御
  static BattleState executeDefend(BattleState state, String unitId) {
    final newState = BattleState.fromJson(state.toJson());
    final unit = _findUnit(newState, unitId);
    if (unit == null) return newState;

    unit.rage = min(100, unit.rage + 10);
    unit.statusEffects.add(
      StatusEffect(type: 'defend', remainingRounds: 1, value: 0.5),
    );

    newState.logs.add(
      BattleLogEntry(
        round: newState.currentRound,
        actorName: unit.name,
        action: '进入防御姿态，本回合受到伤害减半。',
      ),
    );

    _advanceToNextActor(newState);
    return newState;
  }

  // 使用道具（药草）
  static BattleState useItem(BattleState state, String unitId, String itemId) {
    final newState = BattleState.fromJson(state.toJson());
    final unit = _findUnit(newState, unitId);
    if (unit == null) return newState;

    if (itemId == 'herb') {
      final healAmount = (unit.maxHp * 0.2).round();
      unit.hp = min(unit.maxHp, unit.hp + healAmount);
      newState.logs.add(
        BattleLogEntry(
          round: newState.currentRound,
          actorName: unit.name,
          action: '使用药草，恢复了 $healAmount 点生命！',
        ),
      );
    }

    _advanceToNextActor(newState);
    return newState;
  }

  // 逃跑
  static BattleState executeEscape(BattleState state) {
    final newState = BattleState.fromJson(state.toJson());
    final escapeChance = 0.3;
    if (_random.nextDouble() < escapeChance) {
      newState.logs.add(
        BattleLogEntry(
          round: newState.currentRound,
          action: '成功脱离战斗！',
          isImportant: true,
        ),
      );
      newState.phase = BattlePhase.result;
      newState.currentActorId = null;
    } else {
      newState.logs.add(
        BattleLogEntry(
          round: newState.currentRound,
          action: '逃跑失败！敌军发起追击！',
          isImportant: true,
        ),
      );
      // 跳过剩余我方行动，直接敌方行动
      newState.actedUnitIds.clear();
      // 标记所有存活我方已行动
      for (final u in newState.aliveAllies) {
        newState.actedUnitIds.add(u.unitId);
      }
      newState.currentActorId = null;
      _advanceToNextActor(newState);
    }
    return newState;
  }

  // 获取当前行动者的信息
  static BattleUnit? getCurrentActor(BattleState state) {
    if (state.currentActorId == null) return null;
    return _findUnit(state, state.currentActorId!);
  }

  // 获取当前可以行动的存活友方列表（还未行动的）
  static List<BattleUnit> getPendingAllies(BattleState state) {
    return state.aliveAllies
        .where((u) => !state.actedUnitIds.contains(u.unitId))
        .toList();
  }

  // ========== 伤害计算 ==========

  static bool _wasLastCrit = false;

  static int calculateDamage(
    BattleUnit attacker,
    BattleUnit defender,
    Skill? skill,
  ) {
    double base;
    if (skill != null) {
      final attr = skill.scaleAttribute == 'force'
          ? attacker.force
          : attacker.intelligence;
      base = attr * skill.multiplier - defender.command * 0.5;
    } else {
      base = attacker.force * 1.0 - defender.command * 0.5;
    }

    base = max(base, 10.0);

    // 兵种克制
    final troopMod = getTroopAdvantage(attacker.troopType, defender.troopType);
    base *= troopMod;

    // 暴击
    _wasLastCrit = false;
    if (_random.nextDouble() < 0.05) {
      base *= 1.5;
      _wasLastCrit = true;
    }

    // 随机浮动
    base *= 0.9 + _random.nextDouble() * 0.2;

    // 防御状态减伤
    final defendEffect = defender.statusEffects
        .where((e) => e.type == 'defend' && e.remainingRounds > 0)
        .firstOrNull;
    if (defendEffect != null) {
      base *= (1 - defendEffect.value);
    }

    // 鼓舞增伤
    final inspire = attacker.statusEffects
        .where((e) => e.type == 'inspire' && e.remainingRounds > 0)
        .firstOrNull;
    if (inspire != null) {
      base *= (1 + inspire.value);
    }

    // 坚守减伤
    final shield = defender.statusEffects
        .where((e) => e.type == 'shield' && e.remainingRounds > 0)
        .firstOrNull;
    if (shield != null) {
      base *= (1 - shield.value);
    }

    return max(1, base.round());
  }

  static int _calcStrategyDamage(
    BattleUnit attacker,
    BattleUnit defender,
    Skill skill,
  ) {
    double base =
        attacker.intelligence * skill.multiplier - defender.intelligence * 0.3;
    base = max(base, 10.0);
    base *= 0.9 + _random.nextDouble() * 0.2;
    return max(1, base.round());
  }

  static double getTroopAdvantage(TroopType attacker, TroopType defender) {
    if (attacker == TroopType.strategist || defender == TroopType.strategist) {
      return 1.0;
    }
    if (troopAdvantage[attacker] == defender) return 1.2;
    if (troopAdvantage[defender] == attacker) return 0.8;
    return 1.0;
  }

  static bool checkHit(BattleUnit attacker, BattleUnit defender) {
    final hitRate = (90 + attacker.speed * 0.1 - defender.speed * 0.1).clamp(
      50.0,
      98.0,
    );
    return _random.nextDouble() * 100 < hitRate;
  }

  // ========== 战斗结算 ==========

  static BattleResult calculateResult(BattleState state) {
    final isVictory = state.aliveEnemies.isEmpty;
    int totalDamage = 0;
    int totalTaken = 0;
    String mvp = '';
    int maxDmg = 0;
    final damagePerUnit = <String, int>{};

    for (final log in state.logs) {
      if (log.damages != null) {
        for (final entry in log.damages!.entries) {
          if (state.allyUnits.any((u) => u.name == log.actorName)) {
            totalDamage += entry.value;
            damagePerUnit[log.actorName] =
                (damagePerUnit[log.actorName] ?? 0) + entry.value;
          } else {
            totalTaken += entry.value;
          }
        }
      }
    }

    // MVP = 造成伤害最多的武将
    for (final entry in damagePerUnit.entries) {
      if (entry.value > maxDmg) {
        maxDmg = entry.value;
        mvp = entry.key;
      }
    }

    final result = BattleResult(
      isVictory: isVictory,
      rounds: state.currentRound,
      mvpName: mvp.isNotEmpty
          ? mvp
          : (state.allyUnits.isNotEmpty ? state.allyUnits.first.name : ''),
      totalDamage: totalDamage,
      totalTaken: totalTaken,
      expGained: isVictory ? 300 + state.currentRound * 50 : 50,
      coinGained: isVictory ? 500 + state.currentRound * 100 : 0,
      reputationGained: isVictory ? 5 : 0,
    );

    if (!isVictory) {
      result.failureReasons = _analyzeFailure(state);
      result.suggestions = _getSuggestions(state);
    }

    return result;
  }

  // ========== 内部辅助方法 ==========

  static BattleUnit? _findUnit(BattleState state, String unitId) {
    for (final u in state.allyUnits) {
      if (u.unitId == unitId) return u;
    }
    for (final u in state.enemyUnits) {
      if (u.unitId == unitId) return u;
    }
    return null;
  }

  static List<BattleUnit> _getTargets(
    BattleState state,
    TargetType targetType,
    bool isAlly,
    String? specificTargetId,
  ) {
    final enemies = isAlly ? state.aliveEnemies : state.aliveAllies;
    final allies = isAlly ? state.aliveAllies : state.aliveEnemies;

    switch (targetType) {
      case TargetType.singleEnemy:
        if (specificTargetId != null) {
          final t = _findUnit(state, specificTargetId);
          if (t != null && !t.isDead) return [t];
        }
        return enemies.isNotEmpty ? [enemies.first] : [];
      case TargetType.allEnemy:
        return enemies;
      case TargetType.frontRow:
        final front = enemies.where((u) => u.position == 0).toList();
        return front.isNotEmpty ? front : enemies;
      case TargetType.backRow:
        final back = enemies.where((u) => u.position == 2).toList();
        return back.isNotEmpty ? back : enemies;
      case TargetType.self:
        final actor = _findUnit(state, state.currentActorId ?? '');
        return actor != null ? [actor] : [];
      case TargetType.allAlly:
        return allies;
      case TargetType.lowestHp:
        if (enemies.isEmpty) return [];
        final sorted = List<BattleUnit>.from(enemies)
          ..sort((a, b) => a.hp.compareTo(b.hp));
        return [sorted.first];
    }
  }

  // 状态效果处理
  static void _processStatusEffects(BattleState state) {
    final allUnits = [...state.allyUnits, ...state.enemyUnits];
    for (final unit in allUnits) {
      if (unit.isDead) continue;
      for (final effect in unit.statusEffects) {
        if (effect.type == 'burn' && effect.remainingRounds > 0) {
          final burnDmg = (unit.maxHp * effect.value).round();
          unit.hp = max(0, unit.hp - burnDmg);
          state.logs.add(
            BattleLogEntry(
              round: state.currentRound,
              action: '  🔥 ${unit.name}受到灼烧伤害 $burnDmg',
            ),
          );
          if (unit.isDead) {
            state.logs.add(
              BattleLogEntry(
                round: state.currentRound,
                action: '  ✦ ${unit.name}已被灼烧击破！',
                isImportant: true,
              ),
            );
          }
        }
        if (effect.type == 'poison' && effect.remainingRounds > 0) {
          final poisonDmg = (unit.maxHp * effect.value).round();
          unit.hp = max(0, unit.hp - poisonDmg);
          state.logs.add(
            BattleLogEntry(
              round: state.currentRound,
              action: '  ☠ ${unit.name}受到中毒伤害 $poisonDmg',
            ),
          );
        }
      }
      // 减少持续回合
      for (final effect in unit.statusEffects) {
        if (effect.remainingRounds > 0) {
          effect.remainingRounds--;
        }
      }
      unit.statusEffects.removeWhere((e) => e.remainingRounds <= 0);
    }
  }

  // 被动技能激活
  static void _activatePassives(BattleState state) {
    for (final unit in state.allyUnits) {
      for (final sid in unit.skillIds) {
        final skill = GameDataService.findSkill(sid);
        if (skill != null && skill.type == SkillType.passive) {
          state.logs.add(
            BattleLogEntry(
              round: 0,
              action: '  【被动】${unit.name}激活了${skill.name}',
            ),
          );
          // 知音被动：战斗开始全体怒气+15
          if (sid == 'zhiyin') {
            for (final ally in state.aliveAllies) {
              ally.rage = min(100, ally.rage + 15);
            }
          }
          // 武圣被动：攻击提升15%
          if (sid == 'wusheng') {
            unit.force = (unit.force * 1.15).round();
          }
          // 奸雄被动：受伤时回怒（在受伤时处理）
        }
      }
    }
  }

  // 合击检查
  static void _checkAndLogCombo(BattleState state) {
    final allyIds = state.aliveAllies.map((u) => u.unitId).toSet();

    // 桃园结义
    if (allyIds.containsAll(['liubei', 'guanyu', 'zhangfei'])) {
      state.logs.add(
        BattleLogEntry(round: 0, action: '★ 合击条件已满足：桃园结义！', isImportant: true),
      );
    }

    // 卧龙凤雏（如果有庞统的话）
    if (allyIds.containsAll(['zhugeliang', 'pangtong'])) {
      state.logs.add(
        BattleLogEntry(round: 0, action: '★ 合击条件已满足：卧龙凤雏！', isImportant: true),
      );
    }
  }

  // 效果名称映射
  static String _effectName(String type) {
    const names = {
      'stun': '眩晕',
      'burn': '灼烧',
      'poison': '中毒',
      'silence': '沉默',
      'confusion': '混乱',
      'armorBreak': '破甲',
      'inspire': '鼓舞',
      'shield': '坚守',
      'heal': '回复',
      'defend': '防御',
      'buff': '增益',
    };
    return names[type] ?? type;
  }

  // 失败分析
  static List<String> _analyzeFailure(BattleState state) {
    final reasons = <String>[];
    final allyPower = state.allyUnits.fold<int>(0, (s, u) => s + u.force);
    final enemyPower = state.enemyUnits.fold<int>(0, (s, u) => s + u.force);
    if (enemyPower > allyPower * 1.5) reasons.add('敌方战力远超我方');
    if (state.allyUnits.length < state.enemyUnits.length) reasons.add('我方人数不足');
    final frontDead = state.allyUnits
        .where((u) => u.position == 0 && u.isDead)
        .length;
    if (frontDead > 0) reasons.add('前排武将过早阵亡，建议提升前排防御');
    final allDead = state.aliveAllies.isEmpty;
    if (allDead) reasons.add('全军覆没，需加强武将培养');
    if (reasons.isEmpty) reasons.add('战术安排需要调整');
    return reasons;
  }

  static List<String> _getSuggestions(BattleState state) {
    return [
      '提升武将等级和装备强化',
      '调整阵型，合理分配前排和后排',
      '注意兵种克制关系（步→弓→枪→骑→盾→步）',
      '及时释放技能，合理使用怒气',
      '在酒馆招募更强武将',
    ];
  }
}
