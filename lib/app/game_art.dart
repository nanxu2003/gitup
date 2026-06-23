/// Semantic paths for the modular game artwork used by the Flutter UI.
abstract final class GameArt {
  static const worldMapBackground = 'assets/images/backgrounds/world_map.png';
  static const battlefieldBackground =
      'assets/images/backgrounds/battlefield.png';
  static const recruitHallBackground =
      'assets/images/backgrounds/recruit_hall.png';
  static const loginRewardBackground =
      'assets/images/backgrounds/login_reward.png';

  static const mapGuide = 'assets/images/characters/map_guide.png';
  static const battleHero = 'assets/images/characters/battle_hero.png';
  static const battleRival = 'assets/images/characters/battle_rival.png';
  static const recruitLady = 'assets/images/characters/recruit_lady.png';
  static const recruitWarrior = 'assets/images/characters/recruit_warrior.png';
  static const loginLvbu = 'assets/images/characters/login_lvbu.png';

  static const rewardItems = 'assets/images/items/reward_items.png';

  static const all = <String>[
    worldMapBackground,
    battlefieldBackground,
    recruitHallBackground,
    loginRewardBackground,
    mapGuide,
    battleHero,
    battleRival,
    recruitLady,
    recruitWarrior,
    loginLvbu,
    rewardItems,
  ];
}
