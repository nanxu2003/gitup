import '../app/constants.dart';

class SkillEffect {
  String type;
  double chance;
  int duration;
  double value;

  SkillEffect({
    required this.type,
    this.chance = 1.0,
    this.duration = 0,
    this.value = 0,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'chance': chance,
    'duration': duration,
    'value': value,
  };

  factory SkillEffect.fromJson(Map<String, dynamic> json) => SkillEffect(
    type: json['type'] as String? ?? 'damage',
    chance: (json['chance'] as num?)?.toDouble() ?? 1.0,
    duration: json['duration'] as int? ?? 0,
    value: (json['value'] as num?)?.toDouble() ?? 0,
  );
}

class Skill {
  String id;
  String name;
  String description;
  SkillType type;
  TargetType targetType;
  int costRage;
  int cooldown;
  String scaleAttribute;
  double multiplier;
  List<SkillEffect> effects;

  Skill({
    required this.id,
    required this.name,
    this.description = '',
    this.type = SkillType.active,
    this.targetType = TargetType.singleEnemy,
    this.costRage = 30,
    this.cooldown = 1,
    this.scaleAttribute = 'force',
    this.multiplier = 1.5,
    List<SkillEffect>? effects,
  }) : effects = effects ?? [SkillEffect(type: 'damage')];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.name,
    'targetType': targetType.name,
    'costRage': costRage,
    'cooldown': cooldown,
    'scaleAttribute': scaleAttribute,
    'multiplier': multiplier,
    'effects': effects.map((e) => e.toJson()).toList(),
  };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    type: SkillType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => SkillType.active,
    ),
    targetType: TargetType.values.firstWhere(
      (e) => e.name == json['targetType'],
      orElse: () => TargetType.singleEnemy,
    ),
    costRage: json['costRage'] as int? ?? 30,
    cooldown: json['cooldown'] as int? ?? 1,
    scaleAttribute: json['scaleAttribute'] as String? ?? 'force',
    multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.5,
    effects:
        (json['effects'] as List<dynamic>?)
            ?.map((e) => SkillEffect.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}
