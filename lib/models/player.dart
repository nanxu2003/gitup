import '../app/constants.dart';

class Player {
  String name;
  Identity identity;
  int level;
  int exp;
  int day;
  int chapter;
  String cityName;
  int reputation;
  int morale;
  int actionPoints;
  Map<String, int> resources;

  Player({
    required this.name,
    required this.identity,
    this.level = 1,
    this.exp = 0,
    this.day = 1,
    this.chapter = 1,
    this.cityName = '平原',
    this.reputation = 0,
    this.morale = 80,
    this.actionPoints = 20,
    Map<String, int>? resources,
  }) : resources =
           resources ??
           {
             'coin': 3000,
             'grain': 5000,
             'wood': 1200,
             'iron': 800,
             'soldiers': 1500,
           };

  int get maxActionPoints => calculateActionPoints(level);

  factory Player.createWithIdentity(Identity id, String name) {
    final player = Player(name: name, identity: id);
    switch (id) {
      case Identity.royal:
        player.morale = 90;
        player.reputation = 20;
        break;
      case Identity.warrior:
        player.resources['soldiers'] = 2000;
        break;
      case Identity.scholar:
        player.resources['soldiers'] = 1000;
        break;
      case Identity.merchant:
        player.resources['coin'] = 6000;
        player.resources['grain'] = 7000;
        player.reputation = -5;
        break;
    }
    return player;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'identity': identity.name,
    'level': level,
    'exp': exp,
    'day': day,
    'chapter': chapter,
    'cityName': cityName,
    'reputation': reputation,
    'morale': morale,
    'actionPoints': actionPoints,
    'resources': Map<String, int>.from(resources),
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    name: json['name'] as String,
    identity: Identity.values.firstWhere(
      (e) => e.name == json['identity'],
      orElse: () => Identity.royal,
    ),
    level: json['level'] as int? ?? 1,
    exp: json['exp'] as int? ?? 0,
    day: json['day'] as int? ?? 1,
    chapter: json['chapter'] as int? ?? 1,
    cityName: json['cityName'] as String? ?? '平原',
    reputation: json['reputation'] as int? ?? 0,
    morale: json['morale'] as int? ?? 80,
    actionPoints: json['actionPoints'] as int? ?? 20,
    resources:
        (json['resources'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as int),
        ) ??
        {},
  );

  Player copy() => Player.fromJson(toJson());
}
