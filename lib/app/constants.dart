import 'dart:ui';

// 品质枚举
enum Quality { white, green, blue, purple, orange, red }

// 兵种枚举
enum TroopType { infantry, cavalry, archer, spear, shield, strategist }

// 玩家身份枚举
enum Identity { royal, warrior, scholar, merchant }

// 建筑类型枚举
enum BuildingType {
  government,
  farm,
  market,
  lumberMill,
  ironWorks,
  barracks,
  trainingGround,
  tavern,
  blacksmith,
  academy,
  postStation,
  wall,
}

// 道具类型枚举
enum ItemType {
  weapon,
  helmet,
  armor,
  boots,
  mount,
  book,
  treasure,
  consumable,
  material,
}

// 技能类型枚举
enum SkillType { active, passive, combo, troopSkill, bossSkill }

// 技能目标类型枚举
enum TargetType {
  singleEnemy,
  allEnemy,
  frontRow,
  backRow,
  self,
  allAlly,
  lowestHp,
}

// 任务类型枚举
enum QuestType { main, side, daily, achievement }

// 任务状态枚举
enum QuestStatus { locked, active, completed, claimed }

// 关卡类型枚举
enum StageType { normal, elite, boss, story }

// 战斗阶段枚举
enum BattlePhase { preparation, playerTurn, enemyTurn, result }

// 品质对应颜色
const Map<Quality, Color> qualityColors = {
  Quality.white: Color(0xFFCCCCCC),
  Quality.green: Color(0xFF4CAF50),
  Quality.blue: Color(0xFF2196F3),
  Quality.purple: Color(0xFF9C27B0),
  Quality.orange: Color(0xFFFF9800),
  Quality.red: Color(0xFFF44336),
};

// 品质中文名
const Map<Quality, String> qualityNames = {
  Quality.white: '普通',
  Quality.green: '良将',
  Quality.blue: '名将',
  Quality.purple: '豪杰',
  Quality.orange: '传奇',
  Quality.red: '无双',
};

// 兵种中文名
const Map<TroopType, String> troopNames = {
  TroopType.infantry: '步兵',
  TroopType.cavalry: '骑兵',
  TroopType.archer: '弓兵',
  TroopType.spear: '枪兵',
  TroopType.shield: '盾兵',
  TroopType.strategist: '谋士',
};

// 兵种克制关系（key 克制 value）
const Map<TroopType, TroopType> troopAdvantage = {
  TroopType.infantry: TroopType.archer,
  TroopType.archer: TroopType.spear,
  TroopType.spear: TroopType.cavalry,
  TroopType.cavalry: TroopType.shield,
  TroopType.shield: TroopType.infantry,
};

// 身份中文名与描述
const Map<Identity, String> identityNames = {
  Identity.royal: '汉室宗亲',
  Identity.warrior: '边郡武人',
  Identity.scholar: '寒门谋士',
  Identity.merchant: '商贾世家',
};

const Map<Identity, String> identityDescriptions = {
  Identity.royal: '声望较高，容易招募忠义型武将\n初始加成：民心+10，声望+20',
  Identity.warrior: '战斗力强，适合前期扩张\n初始加成：兵力+500，武力型好感+10',
  Identity.scholar: '计策强，剧情分支多\n初始加成：智谋+15，计策成功率+10%',
  Identity.merchant: '资源多，发展快\n初始加成：铜钱+3000，粮草+2000',
};

// 建筑中文名
const Map<BuildingType, String> buildingNames = {
  BuildingType.government: '官府',
  BuildingType.farm: '农田',
  BuildingType.market: '市场',
  BuildingType.lumberMill: '伐木场',
  BuildingType.ironWorks: '冶铁场',
  BuildingType.barracks: '兵营',
  BuildingType.trainingGround: '校场',
  BuildingType.tavern: '酒馆',
  BuildingType.blacksmith: '铁匠铺',
  BuildingType.academy: '书院',
  BuildingType.postStation: '驿站',
  BuildingType.wall: '城墙',
};

// 游戏常量
const int maxDeployedGenerals = 5;
const int maxBuildingUpgrades = 2;
const int maxBattleRounds = 20;
const int maxSaveSlots = 3;

// 每日内政行动点公式
int calculateActionPoints(int playerLevel) => 10;

// 资源产出公式
int coinIncome(int governmentLevel, int marketLevel, int morale) =>
    governmentLevel * 100 + marketLevel * 150 + morale * 10;

int grainIncome(int farmLevel) => farmLevel * 200;
int woodIncome(int lumberMillLevel) => lumberMillLevel * 150;
int ironIncome(int ironWorksLevel) => ironWorksLevel * 100;
int soldierRecovery(int barracksLevel, int morale) =>
    barracksLevel * 50 + morale * 2;
