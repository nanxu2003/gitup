import '../app/constants.dart';

class GeneralAttributes {
  int force;
  int intelligence;
  int command;
  int politics;
  int charm;
  int speed;

  GeneralAttributes({
    required this.force,
    required this.intelligence,
    required this.command,
    required this.politics,
    required this.charm,
    required this.speed,
  });

  Map<String, dynamic> toJson() => {
    'force': force,
    'intelligence': intelligence,
    'command': command,
    'politics': politics,
    'charm': charm,
    'speed': speed,
  };

  factory GeneralAttributes.fromJson(Map<String, dynamic> json) =>
      GeneralAttributes(
        force: json['force'] as int? ?? 50,
        intelligence: json['intelligence'] as int? ?? 50,
        command: json['command'] as int? ?? 50,
        politics: json['politics'] as int? ?? 50,
        charm: json['charm'] as int? ?? 50,
        speed: json['speed'] as int? ?? 50,
      );
}

class General {
  String id;
  String name;
  String title;
  String camp;
  Quality quality;
  int level;
  int star;
  int exp;
  TroopType troopType;
  GeneralAttributes attributes;
  List<String> skillIds;
  List<String> equippedItemIds;
  String bio;
  bool isDeployed;

  General({
    required this.id,
    required this.name,
    this.title = '',
    this.camp = '蜀',
    this.quality = Quality.blue,
    this.level = 1,
    this.star = 1,
    this.exp = 0,
    this.troopType = TroopType.infantry,
    GeneralAttributes? attributes,
    List<String>? skillIds,
    List<String>? equippedItemIds,
    this.bio = '',
    this.isDeployed = false,
  }) : attributes =
           attributes ??
           GeneralAttributes(
             force: 50,
             intelligence: 50,
             command: 50,
             politics: 50,
             charm: 50,
             speed: 50,
           ),
       skillIds = skillIds ?? [],
       equippedItemIds = equippedItemIds ?? [];

  int get hp => 800 + attributes.command * 10 + level * 50;
  int get attackPower => attributes.force + level * 3;
  int get defense => attributes.command ~/ 2 + level * 2;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'title': title,
    'camp': camp,
    'quality': quality.name,
    'level': level,
    'star': star,
    'exp': exp,
    'troopType': troopType.name,
    'attributes': attributes.toJson(),
    'skillIds': List<String>.from(skillIds),
    'equippedItemIds': List<String>.from(equippedItemIds),
    'bio': bio,
    'isDeployed': isDeployed,
  };

  factory General.fromJson(Map<String, dynamic> json) => General(
    id: json['id'] as String,
    name: json['name'] as String,
    title: json['title'] as String? ?? '',
    camp: json['camp'] as String? ?? '蜀',
    quality: Quality.values.firstWhere(
      (e) => e.name == json['quality'],
      orElse: () => Quality.white,
    ),
    level: json['level'] as int? ?? 1,
    star: json['star'] as int? ?? 1,
    exp: json['exp'] as int? ?? 0,
    troopType: TroopType.values.firstWhere(
      (e) => e.name == json['troopType'],
      orElse: () => TroopType.infantry,
    ),
    attributes: json['attributes'] != null
        ? GeneralAttributes.fromJson(json['attributes'] as Map<String, dynamic>)
        : null,
    skillIds:
        (json['skillIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    equippedItemIds:
        (json['equippedItemIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    bio: json['bio'] as String? ?? '',
    isDeployed: json['isDeployed'] as bool? ?? false,
  );

  General copy() => General.fromJson(toJson());
}
