import '../app/constants.dart';

class Building {
  BuildingType type;
  String name;
  int level;
  int maxLevel;
  Map<String, int> upgradeCost;
  int upgradeTimeSeconds;
  bool isUpgrading;
  String? upgradeEndTimeStr;

  Building({
    required this.type,
    required this.name,
    this.level = 1,
    this.maxLevel = 10,
    Map<String, int>? upgradeCost,
    this.upgradeTimeSeconds = 60,
    this.isUpgrading = false,
    this.upgradeEndTimeStr,
  }) : upgradeCost = upgradeCost ?? {'coin': 500, 'wood': 200};

  DateTime? get upgradeEndTime =>
      upgradeEndTimeStr != null ? DateTime.tryParse(upgradeEndTimeStr!) : null;

  set upgradeEndTime(DateTime? dt) => upgradeEndTimeStr = dt?.toIso8601String();

  bool get isMaxLevel => level >= maxLevel;

  String get effectDescription {
    switch (type) {
      case BuildingType.government:
        return '主城等级上限 $level';
      case BuildingType.farm:
        return '粮草产出 +${level * 200}/日';
      case BuildingType.market:
        return '铜钱收入 +${level * 150}/日';
      case BuildingType.lumberMill:
        return '木材产出 +${level * 150}/日';
      case BuildingType.ironWorks:
        return '铁矿产出 +${level * 100}/日';
      case BuildingType.barracks:
        return '兵力恢复 +${level * 50}/日，兵力上限 ${1000 + level * 500}';
      case BuildingType.trainingGround:
        return '武将经验加成 +${level * 5}%';
      case BuildingType.tavern:
        return '可招募武将品质提升';
      case BuildingType.blacksmith:
        return '可锻造装备等级 +$level';
      case BuildingType.academy:
        return '可研究科技等级 +$level';
      case BuildingType.postStation:
        return '情报获取范围 +$level';
      case BuildingType.wall:
        return '城墙耐久 ${level * 10000}';
    }
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'name': name,
    'level': level,
    'maxLevel': maxLevel,
    'upgradeCost': Map<String, int>.from(upgradeCost),
    'upgradeTimeSeconds': upgradeTimeSeconds,
    'isUpgrading': isUpgrading,
    'upgradeEndTimeStr': upgradeEndTimeStr,
  };

  factory Building.fromJson(Map<String, dynamic> json) => Building(
    type: BuildingType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => BuildingType.farm,
    ),
    name: json['name'] as String? ?? '',
    level: json['level'] as int? ?? 1,
    maxLevel: json['maxLevel'] as int? ?? 10,
    upgradeCost:
        (json['upgradeCost'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as int),
        ) ??
        {},
    upgradeTimeSeconds: json['upgradeTimeSeconds'] as int? ?? 60,
    isUpgrading: json['isUpgrading'] as bool? ?? false,
    upgradeEndTimeStr: json['upgradeEndTimeStr'] as String?,
  );
}
