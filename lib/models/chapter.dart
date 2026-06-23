import '../app/constants.dart';
import 'quest.dart';

class Stage {
  String id;
  String name;
  StageType type;
  List<String> enemyIds;
  int recommendedLevel;
  QuestReward rewards;
  bool isCompleted;
  int starsEarned;

  /// 剧情关卡的叙事文本（多段以\n\n分隔，支持打字效果逐段展示）
  String storyContent;

  /// 剧情关卡结束后的总结文本
  String? storyEnding;

  Stage({
    required this.id,
    required this.name,
    this.type = StageType.normal,
    List<String>? enemyIds,
    this.recommendedLevel = 1,
    QuestReward? rewards,
    this.isCompleted = false,
    this.starsEarned = 0,
    this.storyContent = '',
    this.storyEnding,
  }) : enemyIds = enemyIds ?? [],
       rewards = rewards ?? QuestReward();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'enemyIds': List<String>.from(enemyIds),
    'recommendedLevel': recommendedLevel,
    'rewards': rewards.toJson(),
    'isCompleted': isCompleted,
    'starsEarned': starsEarned,
  };

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
    id: json['id'] as String,
    name: json['name'] as String,
    type: StageType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => StageType.normal,
    ),
    enemyIds:
        (json['enemyIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    recommendedLevel: json['recommendedLevel'] as int? ?? 1,
    rewards: json['rewards'] != null
        ? QuestReward.fromJson(json['rewards'] as Map<String, dynamic>)
        : null,
    isCompleted: json['isCompleted'] as bool? ?? false,
    starsEarned: json['starsEarned'] as int? ?? 0,
  );
}

class Chapter {
  int id;
  String name;
  String description;
  List<Stage> stages;
  bool isUnlocked;
  bool isCompleted;

  Chapter({
    required this.id,
    required this.name,
    this.description = '',
    List<Stage>? stages,
    this.isUnlocked = false,
    this.isCompleted = false,
  }) : stages = stages ?? [];

  int get completedStages => stages.where((s) => s.isCompleted).length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'stages': stages.map((s) => s.toJson()).toList(),
    'isUnlocked': isUnlocked,
    'isCompleted': isCompleted,
  };

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    stages:
        (json['stages'] as List<dynamic>?)
            ?.map((e) => Stage.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}
