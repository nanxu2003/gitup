import '../app/constants.dart';

class StatusEffect {
  String type;
  int remainingRounds;
  double value;

  StatusEffect({required this.type, this.remainingRounds = 1, this.value = 0});

  Map<String, dynamic> toJson() => {
    'type': type,
    'remainingRounds': remainingRounds,
    'value': value,
  };

  factory StatusEffect.fromJson(Map<String, dynamic> json) => StatusEffect(
    type: json['type'] as String? ?? '',
    remainingRounds: json['remainingRounds'] as int? ?? 1,
    value: (json['value'] as num?)?.toDouble() ?? 0,
  );
}

class BattleUnit {
  String unitId;
  String name;
  bool isAlly;
  int hp;
  int maxHp;
  int rage;
  TroopType troopType;
  int force;
  int intelligence;
  int command;
  int speed;
  List<String> skillIds;
  List<StatusEffect> statusEffects;
  int position;
  Map<String, int> skillCooldowns;

  BattleUnit({
    required this.unitId,
    required this.name,
    this.isAlly = true,
    this.hp = 1000,
    this.maxHp = 1000,
    this.rage = 0,
    this.troopType = TroopType.infantry,
    this.force = 50,
    this.intelligence = 50,
    this.command = 50,
    this.speed = 50,
    List<String>? skillIds,
    List<StatusEffect>? statusEffects,
    this.position = 0,
    Map<String, int>? skillCooldowns,
  }) : skillIds = skillIds ?? [],
       statusEffects = statusEffects ?? [],
       skillCooldowns = skillCooldowns ?? {};

  bool get isDead => hp <= 0;
  bool get isStunned =>
      statusEffects.any((e) => e.type == 'stun' && e.remainingRounds > 0);

  Map<String, dynamic> toJson() => {
    'unitId': unitId,
    'name': name,
    'isAlly': isAlly,
    'hp': hp,
    'maxHp': maxHp,
    'rage': rage,
    'troopType': troopType.name,
    'force': force,
    'intelligence': intelligence,
    'command': command,
    'speed': speed,
    'skillIds': List<String>.from(skillIds),
    'statusEffects': statusEffects.map((e) => e.toJson()).toList(),
    'position': position,
    'skillCooldowns': Map<String, int>.from(skillCooldowns),
  };

  factory BattleUnit.fromJson(Map<String, dynamic> json) => BattleUnit(
    unitId: json['unitId'] as String,
    name: json['name'] as String,
    isAlly: json['isAlly'] as bool? ?? true,
    hp: json['hp'] as int? ?? 1000,
    maxHp: json['maxHp'] as int? ?? 1000,
    rage: json['rage'] as int? ?? 0,
    troopType: TroopType.values.firstWhere(
      (e) => e.name == json['troopType'],
      orElse: () => TroopType.infantry,
    ),
    force: json['force'] as int? ?? 50,
    intelligence: json['intelligence'] as int? ?? 50,
    command: json['command'] as int? ?? 50,
    speed: json['speed'] as int? ?? 50,
    skillIds:
        (json['skillIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    statusEffects:
        (json['statusEffects'] as List<dynamic>?)
            ?.map((e) => StatusEffect.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    position: json['position'] as int? ?? 0,
    skillCooldowns:
        (json['skillCooldowns'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as int),
        ) ??
        {},
  );
}

class BattleLogEntry {
  int round;
  String actorName;
  String action;
  List<String> affectedNames;
  Map<String, int>? damages;
  bool isImportant;

  BattleLogEntry({
    this.round = 0,
    this.actorName = '',
    this.action = '',
    List<String>? affectedNames,
    this.damages,
    this.isImportant = false,
  }) : affectedNames = affectedNames ?? [];

  String get displayText {
    final sb = StringBuffer();
    if (actorName.isNotEmpty) sb.write('【$actorName】');
    sb.write(action);
    if (damages != null && damages!.isNotEmpty) {
      sb.write('（');
      sb.write(damages!.entries.map((e) => '${e.key} -${e.value}').join('，'));
      sb.write('）');
    }
    return sb.toString();
  }

  Map<String, dynamic> toJson() => {
    'round': round,
    'actorName': actorName,
    'action': action,
    'affectedNames': List<String>.from(affectedNames),
    'damages': damages != null ? Map<String, int>.from(damages!) : null,
    'isImportant': isImportant,
  };

  factory BattleLogEntry.fromJson(Map<String, dynamic> json) => BattleLogEntry(
    round: json['round'] as int? ?? 0,
    actorName: json['actorName'] as String? ?? '',
    action: json['action'] as String? ?? '',
    affectedNames:
        (json['affectedNames'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    damages: (json['damages'] as Map<String, dynamic>?)?.map(
      (k, v) => MapEntry(k, v as int),
    ),
    isImportant: json['isImportant'] as bool? ?? false,
  );
}

class BattleState {
  String battleId;
  int currentRound;
  int maxRounds;
  List<BattleUnit> allyUnits;
  List<BattleUnit> enemyUnits;
  List<BattleLogEntry> logs;
  BattlePhase phase;
  String? currentActorId;
  bool isAutoBattle;
  double battleSpeed;
  List<String> actedUnitIds;
  List<String> turnOrder;

  BattleState({
    this.battleId = '',
    this.currentRound = 0,
    this.maxRounds = 20,
    List<BattleUnit>? allyUnits,
    List<BattleUnit>? enemyUnits,
    List<BattleLogEntry>? logs,
    this.phase = BattlePhase.preparation,
    this.currentActorId,
    this.isAutoBattle = false,
    this.battleSpeed = 1.0,
    List<String>? actedUnitIds,
    List<String>? turnOrder,
  }) : allyUnits = allyUnits ?? [],
       enemyUnits = enemyUnits ?? [],
       logs = logs ?? [],
       actedUnitIds = actedUnitIds ?? [],
       turnOrder = turnOrder ?? [];

  bool get isOver =>
      allyUnits.every((u) => u.isDead) ||
      enemyUnits.every((u) => u.isDead) ||
      currentRound >= maxRounds;

  bool get isVictory => enemyUnits.every((u) => u.isDead);

  List<BattleUnit> get aliveAllies =>
      allyUnits.where((u) => !u.isDead).toList();
  List<BattleUnit> get aliveEnemies =>
      enemyUnits.where((u) => !u.isDead).toList();

  Map<String, dynamic> toJson() => {
    'battleId': battleId,
    'currentRound': currentRound,
    'maxRounds': maxRounds,
    'allyUnits': allyUnits.map((u) => u.toJson()).toList(),
    'enemyUnits': enemyUnits.map((u) => u.toJson()).toList(),
    'logs': logs.map((l) => l.toJson()).toList(),
    'phase': phase.name,
    'currentActorId': currentActorId,
    'isAutoBattle': isAutoBattle,
    'battleSpeed': battleSpeed,
    'actedUnitIds': List<String>.from(actedUnitIds),
    'turnOrder': List<String>.from(turnOrder),
  };

  factory BattleState.fromJson(Map<String, dynamic> json) => BattleState(
    battleId: json['battleId'] as String? ?? '',
    currentRound: json['currentRound'] as int? ?? 0,
    maxRounds: json['maxRounds'] as int? ?? 20,
    allyUnits:
        (json['allyUnits'] as List<dynamic>?)
            ?.map((e) => BattleUnit.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    enemyUnits:
        (json['enemyUnits'] as List<dynamic>?)
            ?.map((e) => BattleUnit.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    logs:
        (json['logs'] as List<dynamic>?)
            ?.map((e) => BattleLogEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    phase: BattlePhase.values.firstWhere(
      (e) => e.name == json['phase'],
      orElse: () => BattlePhase.preparation,
    ),
    currentActorId: json['currentActorId'] as String?,
    isAutoBattle: json['isAutoBattle'] as bool? ?? false,
    battleSpeed: (json['battleSpeed'] as num?)?.toDouble() ?? 1.0,
    actedUnitIds:
        (json['actedUnitIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    turnOrder:
        (json['turnOrder'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
  );
}

class BattleResult {
  bool isVictory;
  int rounds;
  String mvpName;
  int totalDamage;
  int totalTaken;
  int expGained;
  int coinGained;
  int reputationGained;
  List<String> itemRewards;
  List<String> failureReasons;
  List<String> suggestions;

  BattleResult({
    this.isVictory = false,
    this.rounds = 0,
    this.mvpName = '',
    this.totalDamage = 0,
    this.totalTaken = 0,
    this.expGained = 0,
    this.coinGained = 0,
    this.reputationGained = 0,
    List<String>? itemRewards,
    List<String>? failureReasons,
    List<String>? suggestions,
  }) : itemRewards = itemRewards ?? [],
       failureReasons = failureReasons ?? [],
       suggestions = suggestions ?? [];

  Map<String, dynamic> toJson() => {
    'isVictory': isVictory,
    'rounds': rounds,
    'mvpName': mvpName,
    'totalDamage': totalDamage,
    'totalTaken': totalTaken,
    'expGained': expGained,
    'coinGained': coinGained,
    'reputationGained': reputationGained,
    'itemRewards': List<String>.from(itemRewards),
    'failureReasons': List<String>.from(failureReasons),
    'suggestions': List<String>.from(suggestions),
  };

  factory BattleResult.fromJson(Map<String, dynamic> json) => BattleResult(
    isVictory: json['isVictory'] as bool? ?? false,
    rounds: json['rounds'] as int? ?? 0,
    mvpName: json['mvpName'] as String? ?? '',
    totalDamage: json['totalDamage'] as int? ?? 0,
    totalTaken: json['totalTaken'] as int? ?? 0,
    expGained: json['expGained'] as int? ?? 0,
    coinGained: json['coinGained'] as int? ?? 0,
    reputationGained: json['reputationGained'] as int? ?? 0,
    itemRewards:
        (json['itemRewards'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    failureReasons:
        (json['failureReasons'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    suggestions:
        (json['suggestions'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
  );
}
