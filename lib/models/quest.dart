import '../app/constants.dart';

class QuestReward {
  int coin;
  int grain;
  int exp;
  int reputation;
  List<String> itemIds;

  QuestReward({
    this.coin = 0,
    this.grain = 0,
    this.exp = 0,
    this.reputation = 0,
    List<String>? itemIds,
  }) : itemIds = itemIds ?? [];

  Map<String, dynamic> toJson() => {
    'coin': coin,
    'grain': grain,
    'exp': exp,
    'reputation': reputation,
    'itemIds': List<String>.from(itemIds),
  };

  factory QuestReward.fromJson(Map<String, dynamic> json) => QuestReward(
    coin: json['coin'] as int? ?? 0,
    grain: json['grain'] as int? ?? 0,
    exp: json['exp'] as int? ?? 0,
    reputation: json['reputation'] as int? ?? 0,
    itemIds:
        (json['itemIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        [],
  );
}

class QuestObjective {
  String type;
  String targetId;
  int requiredCount;
  int currentCount;

  QuestObjective({
    required this.type,
    this.targetId = '',
    this.requiredCount = 1,
    this.currentCount = 0,
  });

  bool get isComplete => currentCount >= requiredCount;
  double get progress => requiredCount > 0 ? currentCount / requiredCount : 0;

  Map<String, dynamic> toJson() => {
    'type': type,
    'targetId': targetId,
    'requiredCount': requiredCount,
    'currentCount': currentCount,
  };

  factory QuestObjective.fromJson(Map<String, dynamic> json) => QuestObjective(
    type: json['type'] as String? ?? 'battle',
    targetId: json['targetId'] as String? ?? '',
    requiredCount: json['requiredCount'] as int? ?? 1,
    currentCount: json['currentCount'] as int? ?? 0,
  );
}

class Quest {
  String id;
  String name;
  String description;
  QuestType type;
  int requiredLevel;
  List<QuestObjective> objectives;
  QuestReward rewards;
  QuestStatus status;

  Quest({
    required this.id,
    required this.name,
    this.description = '',
    this.type = QuestType.main,
    this.requiredLevel = 1,
    List<QuestObjective>? objectives,
    QuestReward? rewards,
    this.status = QuestStatus.locked,
  }) : objectives = objectives ?? [],
       rewards = rewards ?? QuestReward();

  bool get isComplete => objectives.every((o) => o.isComplete);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.name,
    'requiredLevel': requiredLevel,
    'objectives': objectives.map((o) => o.toJson()).toList(),
    'rewards': rewards.toJson(),
    'status': status.name,
  };

  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    type: QuestType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => QuestType.main,
    ),
    requiredLevel: json['requiredLevel'] as int? ?? 1,
    objectives:
        (json['objectives'] as List<dynamic>?)
            ?.map((e) => QuestObjective.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    rewards: json['rewards'] != null
        ? QuestReward.fromJson(json['rewards'] as Map<String, dynamic>)
        : null,
    status: QuestStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => QuestStatus.locked,
    ),
  );
}
