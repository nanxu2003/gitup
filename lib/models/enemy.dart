import '../app/constants.dart';

class Enemy {
  String id;
  String name;
  int level;
  TroopType troopType;
  int hp;
  int maxHp;
  int force;
  int intelligence;
  int command;
  int speed;
  List<String> skillIds;
  bool isBoss;

  Enemy({
    required this.id,
    required this.name,
    this.level = 1,
    this.troopType = TroopType.infantry,
    this.hp = 800,
    this.maxHp = 800,
    this.force = 40,
    this.intelligence = 30,
    this.command = 35,
    this.speed = 30,
    List<String>? skillIds,
    this.isBoss = false,
  }) : skillIds = skillIds ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'level': level,
    'troopType': troopType.name,
    'hp': hp,
    'maxHp': maxHp,
    'force': force,
    'intelligence': intelligence,
    'command': command,
    'speed': speed,
    'skillIds': List<String>.from(skillIds),
    'isBoss': isBoss,
  };

  factory Enemy.fromJson(Map<String, dynamic> json) => Enemy(
    id: json['id'] as String,
    name: json['name'] as String,
    level: json['level'] as int? ?? 1,
    troopType: TroopType.values.firstWhere(
      (e) => e.name == json['troopType'],
      orElse: () => TroopType.infantry,
    ),
    hp: json['hp'] as int? ?? 800,
    maxHp: json['maxHp'] as int? ?? 800,
    force: json['force'] as int? ?? 40,
    intelligence: json['intelligence'] as int? ?? 30,
    command: json['command'] as int? ?? 35,
    speed: json['speed'] as int? ?? 30,
    skillIds:
        (json['skillIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    isBoss: json['isBoss'] as bool? ?? false,
  );
}
