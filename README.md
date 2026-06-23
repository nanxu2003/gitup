# 三国志：问鼎天下 — Flutter 架构与实现计划

## 一、项目概述

单机纯文字回合制策略游戏，三国题材。玩家从一座小城起步，经营城池、招募武将、探索地图、回合战斗，最终决定天下归属。

**技术约束：**
- 状态管理：`setState`
- 数据存储：`shared_preferences`（JSON 序列化）
- 无本地图片资源、无外部字体、无网络请求
- 不使用 freezed / part 语法
- 无账户系统

**唯一第三方依赖：** `shared_preferences` + `cupertino_icons`

---

## 二、目录结构（全部 Dart 文件清单）

```
lib/
├── main.dart                              # 应用入口、路由注册、主题初始化
├── app/
│   ├── app_theme.dart                     # 全局主题（古风配色：深棕/金/暗红）
│   ├── app_router.dart                    # 命名路由表，所有页面路由集中管理
│   └── constants.dart                     # 游戏常量（资源上限、品质枚举、兵种枚举等）
│
├── models/
│   ├── player.dart                        # 玩家数据模型
│   ├── general.dart                       # 武将数据模型
│   ├── skill.dart                         # 技能数据模型
│   ├── building.dart                      # 建筑数据模型
│   ├── item.dart                          # 道具/装备数据模型
│   ├── quest.dart                         # 任务数据模型
│   ├── event.dart                         # 剧情事件数据模型
│   ├── battle.dart                        # 战斗状态与结算模型
│   ├── formation.dart                     # 阵型与布阵模型
│   ├── chapter.dart                       # 章节与关卡模型
│   ├── enemy.dart                         # 敌人数据模型
│   └── game_save.dart                     # 存档聚合根模型
│
├── services/
│   ├── storage_service.dart               # shared_preferences 读写封装
│   ├── save_service.dart                  # 存档/读档逻辑（序列化 game_save）
│   ├── game_data_service.dart             # 静态数据加载（内置武将/技能/敌人表）
│   ├── battle_engine.dart                 # 回合战斗核心逻辑（纯计算，无UI）
│   ├── recruit_service.dart               # 招募概率与结果计算
│   └── resource_service.dart              # 资源产出/消耗计算
│
├── screens/
│   ├── splash_screen.dart                 # 主菜单（新游戏/继续/读档/设置/退出）
│   ├── create_player_screen.dart          # 创建角色（选身份、输入名字）
│   ├── home_screen.dart                   # 主城主界面（资源总览+建筑入口+底部导航）
│   ├── city_screen.dart                   # 城池建设（建筑列表、升级）
│   ├── politics_screen.dart               # 内政治理（巡查/赈济/征税/征兵）
│   ├── general_list_screen.dart           # 武将列表（筛选、查看详情）
│   ├── general_detail_screen.dart         # 武将详情（属性/技能/装备）
│   ├── formation_screen.dart              # 布阵界面（阵型选择、拖拽布阵）
│   ├── battle_screen.dart                 # 战斗主界面（回合指令、战斗日志）
│   ├── battle_result_screen.dart          # 战斗结算（胜利/失败、奖励、复盘）
│   ├── world_map_screen.dart              # 世界地图（章节关卡、探索）
│   ├── recruit_screen.dart                # 招募界面（普通/高级/名将招募）
│   ├── quest_screen.dart                  # 任务列表（主线/支线/每日）
│   ├── quest_dialog_screen.dart           # 剧情对话（选项分支）
│   ├── inventory_screen.dart              # 背包（道具/装备/材料分类）
│   ├── story_event_screen.dart            # 随机事件（文字描述+选项）
│   └── settings_screen.dart               # 设置（音效/震动/速度/存档管理）
│
└── widgets/
    ├── resource_bar.dart                  # 顶部资源横条（铜钱/粮草/木材/铁矿/兵力）
    ├── general_card.dart                  # 武将卡片（名字/品质色/星级/等级）
    ├── battle_log_widget.dart             # 战斗日志滚动列表
    ├── stat_row.dart                      # 属性行（武力/智力/统率等横条）
    ├── confirm_dialog.dart                # 通用确认弹窗
    ├── styled_button.dart                 # 古风按钮（圆角+金色边框）
    └── section_header.dart               # 区块标题（带装饰线的标题栏）
```

**共 46 个 Dart 文件。**

---

## 三、各文件功能与实现计划

### 3.1 入口与配置层

#### `main.dart`
- **功能**：应用入口，初始化 `SharedPreferences`，注入 `StorageService`，设置 `AppTheme` 和路由
- **关键步骤**：
  1. `main()` 中 `await` 初始化 `SharedPreferences` 实例
  2. 创建 `StorageService` 并传给需要的 Service
  3. `MaterialApp` 使用 `AppTheme.dark()` + `AppRouter.routes`
  4. 首页指向 `SplashScreen`

#### `app/app_theme.dart`
- **功能**：定义全局古风主题
- **关键内容**：
  - 主色 `#3E2723`（深棕）、强调色 `#D4A017`（金）、危险色 `#8B0000`（暗红）
  - 背景色 `#1A1A1A`、文字色 `#E0D5C1`（米黄）
  - `TextTheme` 使用系统默认字体，通过 `fontSize` / `fontWeight` 区分层级
  - 提供 `static ThemeData gameTheme()` 工厂方法

#### `app/app_router.dart`
- **功能**：集中管理所有命名路由
- **关键内容**：
  - `static Map<String, WidgetBuilder> routes` 映射所有 Screen
  - 路由常量：`static const String home = '/home'` 等
  - `generateRoute` 处理带参数的路由（如武将详情需要传 generalId）

#### `app/constants.dart`
- **功能**：所有游戏枚举和常量集中定义
- **关键内容**：
  - `enum Quality { white, green, blue, purple, orange, red }` — 武将/装备品质
  - `enum TroopType { infantry, cavalry, archer, spear, shield, strategist }` — 兵种
  - `enum Identity { royal, warrior, scholar, merchant }` — 玩家身份
  - `enum BuildingType { government, farm, market, lumberMill, ironWorks, barracks, trainingGround, tavern, blacksmith, academy, postStation, wall }` — 建筑类型
  - `enum ItemType { weapon, helmet, armor, boots, mount, book, treasure, consumable, material }` — 道具类型
  - 兵种克制矩阵 `Map<TroopType, TroopType>`
  - 品质对应颜色 `Map<Quality, Color>`
  - 最大上阵武将数 = 5，每日内政行动点公式等

---

### 3.2 数据模型层（models/）

> 所有 Model 均为普通 Dart 类，手写 `fromJson` / `toJson`，不使用 freezed / part。

#### `models/player.dart` — Player
```
class Player {
  String name;
  Identity identity;
  int level;
  int exp;
  int day;
  int chapter;
  String cityName;
  int reputation;       // 声望
  int morale;           // 民心
  int actionPoints;     // 当日内政行动点
  Map<String, int> resources;  // {'coin':3000, 'grain':5000, 'wood':1200, 'iron':800, 'soldiers':1500}
  
  // 方法
  int get maxActionPoints => 3 + level ~/ 5;
  Map<String, dynamic> toJson();
  factory Player.fromJson(Map<String, dynamic> json);
  factory Player.createWithIdentity(Identity id, String name); // 根据身份给不同初始值
}
```

#### `models/general.dart` — General
```
class General {
  String id;
  String name;
  String title;
  String camp;          // 阵营：蜀/魏/吴/群
  Quality quality;
  int level;
  int star;
  int exp;
  TroopType troopType;
  GeneralAttributes attributes;   // 六维属性（见下）
  List<String> skillIds;
  List<String> equippedItemIds;
  String bio;
  bool isDeployed;      // 是否已上阵
  
  Map<String, dynamic> toJson();
  factory General.fromJson(Map<String, dynamic> json);
}

class GeneralAttributes {
  int force;            // 武力
  int intelligence;     // 智力
  int command;          // 统率
  int politics;         // 政治
  int charm;            // 魅力
  int speed;            // 速度
  
  Map<String, dynamic> toJson();
  factory GeneralAttributes.fromJson(Map<String, dynamic> json);
}
```

#### `models/skill.dart` — Skill
```
class Skill {
  String id;
  String name;
  String description;
  SkillType type;        // active / passive / combo / troopType / boss
  TargetType targetType; // singleEnemy / allEnemy / frontRow / self / allAlly
  int costRage;
  int cooldown;
  String scaleAttribute; // 'force' 或 'intelligence'
  double multiplier;
  List<SkillEffect> effects;
  
  Map<String, dynamic> toJson();
  factory Skill.fromJson(Map<String, dynamic> json);
}

class SkillEffect {
  String type;           // damage / stun / burn / poison / silence / heal / buff
  double chance;
  int duration;
  double value;
  
  Map<String, dynamic> toJson();
  factory SkillEffect.fromJson(Map<String, dynamic> json);
}

enum SkillType { active, passive, combo, troopSkill, bossSkill }
enum TargetType { singleEnemy, allEnemy, frontRow, backRow, self, allAlly, lowestHp }
```

#### `models/building.dart` — Building
```
class Building {
  BuildingType type;
  String name;
  int level;
  int maxLevel;         // 受官府等级限制
  Map<String, int> upgradeCost;   // {'coin': 800, 'wood': 300}
  int upgradeTimeSeconds;
  bool isUpgrading;
  DateTime? upgradeEndTime;
  
  Map<String, dynamic> toJson();
  factory Building.fromJson(Map<String, dynamic> json);
  
  // 根据类型返回效果描述
  Map<String, int> getEffect();
}
```

#### `models/item.dart` — GameItem
```
class GameItem {
  String id;
  String name;
  String description;
  Quality quality;
  ItemType type;
  int quantity;
  Map<String, int> attributes;    // {'force': 30, 'attackPercent': 15}
  String? specialEffect;
  String? boundGeneralId;         // 专属武将ID
  
  Map<String, dynamic> toJson();
  factory GameItem.fromJson(Map<String, dynamic> json);
}
```

#### `models/quest.dart` — Quest
```
class Quest {
  String id;
  String name;
  String description;
  QuestType type;        // main / side / daily / achievement
  int requiredLevel;
  List<QuestObjective> objectives;
  QuestReward rewards;
  QuestStatus status;    // locked / active / completed / claimed
  
  Map<String, dynamic> toJson();
  factory Quest.fromJson(Map<String, dynamic> json);
}

class QuestObjective {
  String type;           // battle / recruit / build / explore / collect
  String targetId;
  int requiredCount;
  int currentCount;
  
  Map<String, dynamic> toJson();
  factory QuestObjective.fromJson(Map<String, dynamic> json);
}

class QuestReward {
  int coin;
  int grain;
  int exp;
  int reputation;
  List<String> itemIds;
  
  Map<String, dynamic> toJson();
  factory QuestReward.fromJson(Map<String, dynamic> json);
}

enum QuestType { main, side, daily, achievement }
enum QuestStatus { locked, active, completed, claimed }
```

#### `models/event.dart` — GameEvent
```
class GameEvent {
  String id;
  String title;
  String description;
  String? triggerCondition;  // 描述触发条件
  List<EventChoice> choices;
  
  Map<String, dynamic> toJson();
  factory GameEvent.fromJson(Map<String, dynamic> json);
}

class EventChoice {
  String text;
  Map<String, int> effects;     // {'morale': 10, 'grain': -500}
  String? resultText;
  String? triggerEventId;       // 可能链式触发
  
  Map<String, dynamic> toJson();
  factory EventChoice.fromJson(Map<String, dynamic> json);
}
```

#### `models/enemy.dart` — Enemy
```
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
  
  Map<String, dynamic> toJson();
  factory Enemy.fromJson(Map<String, dynamic> json);
}
```

#### `models/battle.dart` — BattleState / BattleResult
```
class BattleState {
  String battleId;
  int currentRound;
  int maxRounds;                 // 默认20
  List<BattleUnit> allyUnits;
  List<BattleUnit> enemyUnits;
  List<BattleLogEntry> logs;
  BattlePhase phase;             // preparation / playerTurn / enemyTurn / result
  String? currentActorId;
  bool isAutoBattle;
  double battleSpeed;            // 1.0 / 2.0 / 3.0
  
  Map<String, dynamic> toJson();
  factory BattleState.fromJson(Map<String, dynamic> json);
}

class BattleUnit {
  String unitId;                 // generalId 或 enemyId
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
  int position;                  // 0=前排, 1=中排, 2=后排
  
  Map<String, dynamic> toJson();
  factory BattleUnit.fromJson(Map<String, dynamic> json);
}

class StatusEffect {
  String type;                   // stun / burn / poison / silence / confusion / armorBreak / inspire
  int remainingRounds;
  double value;
  
  Map<String, dynamic> toJson();
  factory StatusEffect.fromJson(Map<String, dynamic> json);
}

class BattleLogEntry {
  int round;
  String actorName;
  String action;                 // 描述文本
  List<String> affectedNames;
  Map<String, int>? damages;
  
  Map<String, dynamic> toJson();
  factory BattleLogEntry.fromJson(Map<String, dynamic> json);
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
  List<String> failureReasons;   // 失败时填充
  List<String> suggestions;      // 失败建议
  
  Map<String, dynamic> toJson();
  factory BattleResult.fromJson(Map<String, dynamic> json);
}

enum BattlePhase { preparation, playerTurn, enemyTurn, result }
```

#### `models/formation.dart` — Formation
```
class Formation {
  String id;
  String name;                   // 锋兵阵 / 雁阵 / 鹤翼阵 等
  Map<String, double> bonuses;   // {'attackPercent': 0.15, 'defensePercent': 0.10}
  List<List<String?>> slots;     // 3排×若干列，存generalId或null
  
  Map<String, dynamic> toJson();
  factory Formation.fromJson(Map<String, dynamic> json);
}
```

#### `models/chapter.dart` — Chapter / Stage
```
class Chapter {
  int id;
  String name;                   // "第一章：黄巾乱起"
  String description;
  List<Stage> stages;
  bool isUnlocked;
  bool isCompleted;
  
  Map<String, dynamic> toJson();
  factory Chapter.fromJson(Map<String, dynamic> json);
}

class Stage {
  String id;
  String name;
  StageType type;                // normal / elite / boss / story
  List<String> enemyIds;
  int recommendedLevel;
  QuestReward rewards;
  bool isCompleted;
  int starsEarned;               // 0~3
  
  Map<String, dynamic> toJson();
  factory Stage.fromJson(Map<String, dynamic> json);
}

enum StageType { normal, elite, boss, story }
```

#### `models/game_save.dart` — GameSave（存档聚合根）
```
class GameSave {
  Player player;
  List<Building> buildings;
  List<General> generals;
  List<GameItem> inventory;
  List<Quest> quests;
  List<Formation> formations;
  List<Chapter> chapters;
  Map<String, bool> storyFlags;      // 剧情标记
  Map<String, int> mapProgress;      // 区域探索进度
  List<String> completedEventIds;
  DateTime savedAt;
  int slotIndex;                     // 存档槽 0~2
  
  Map<String, dynamic> toJson();
  factory GameSave.fromJson(Map<String, dynamic> json);
}
```

---

### 3.3 服务层（services/）

> 纯逻辑层，不依赖任何 Widget / UI 代码。Screen 通过调用 Service 方法获取结果，再 `setState` 刷新 UI。

#### `services/storage_service.dart`
- **功能**：封装 `SharedPreferences` 的读写操作
- **关键方法**：
  - `Future<void> saveString(String key, String value)`
  - `String? getString(String key)`
  - `Future<void> remove(String key)`
  - `Future<bool> hasKey(String key)`
- **设计**：持有 `SharedPreferences` 实例引用（从 `main.dart` 注入）

#### `services/save_service.dart`
- **功能**：存档/读档/删档
- **关键方法**：
  - `Future<void> saveGame(GameSave save, int slot)` — 将 `GameSave.toJson()` 序列化后存入 SP
  - `Future<GameSave?> loadGame(int slot)` — 从 SP 读取并反序列化
  - `Future<List<int>> getSaveSlots()` — 返回有存档的槽位列表
  - `Future<void> deleteSave(int slot)`
  - `Future<void> autoSave(GameSave save)` — 自动存档到槽位 0
- **依赖**：`StorageService`

#### `services/game_data_service.dart`
- **功能**：提供游戏内置静态数据（不依赖 JSON 文件，直接硬编码在 Dart 中）
- **关键方法**：
  - `List<General> getAllGenerals()` — 返回全部预设武将数据
  - `List<Skill> getAllSkills()` — 返回全部技能数据
  - `List<Enemy> getAllEnemies()` — 返回全部敌人数据
  - `List<Chapter> getAllChapters()` — 返回章节关卡数据
  - `List<GameEvent> getAllEvents()` — 返回事件数据
  - `List<Quest> getInitialQuests()` — 返回初始任务列表
  - `List<Building> getDefaultBuildings()` — 返回初始建筑列表
- **设计**：纯静态方法或单例，数据以 `List<Map>` 硬编码

#### `services/battle_engine.dart`
- **功能**：回合战斗核心引擎，纯计算无 UI
- **关键方法**：
  - `BattleState initBattle(List<General> allies, List<Enemy> enemies, Formation formation)` — 初始化战斗状态
  - `BattleState executePlayerAction(BattleState state, String action, String targetId, String? skillId)` — 执行玩家指令
  - `BattleState executeEnemyTurn(BattleState state)` — 执行敌方回合
  - `BattleResult calculateResult(BattleState state)` — 结算战斗结果
  - `int calculateDamage(BattleUnit attacker, BattleUnit defender, Skill? skill)` — 伤害公式
  - `double getTroopAdvantage(TroopType attacker, TroopType defender)` — 兵种克制系数
  - `bool checkHit(BattleUnit attacker, BattleUnit defender)` — 命中判定
  - `void processStatusEffects(BattleState state)` — 处理状态效果（灼烧/中毒等）
  - `String? checkCombo(List<BattleUnit> allies)` — 检查合击条件
- **伤害公式**：
  - 普攻：`force × multiplier - defender.command × 0.5`，× 兵种修正 × 暴击 × 随机(0.9~1.1)
  - 计策：`intelligence × multiplier - defender.intelligence × 0.3`
  - 暴击率 = 5%，暴击伤害 = ×1.5
  - 命中率 = clamp(90% + attacker.speed×0.1 - defender.speed×0.1, 50%, 98%)

#### `services/recruit_service.dart`
- **功能**：招募概率计算
- **关键方法**：
  - `General normalRecruit()` — 普通招募（白40%/绿30%/蓝20%/紫8%/橙2%）
  - `General advancedRecruit()` — 高级招募（蓝45%/紫35%/橙15%/红5%）
  - `List<General> getRecruitPool(Quality minQuality)` — 根据品质筛选候选池
- **依赖**：`GameDataService`

#### `services/resource_service.dart`
- **功能**：每回合资源产出与消耗计算
- **关键方法**：
  - `Map<String, int> calculateDailyIncome(List<Building> buildings, int morale)` — 每日产出
  - `bool canAfford(Player player, Map<String, int> cost)` — 检查资源是否足够
  - `Player deductResources(Player player, Map<String, int> cost)` — 扣除资源（返回新对象）
  - `Player addResources(Player player, Map<String, int> income)` — 增加资源

---

### 3.4 界面层（screens/）

> 每个 Screen 是一个 `StatefulWidget`，内部使用 `setState` 管理状态。通过构造函数或路由参数接收所需数据。

#### `screens/splash_screen.dart` — 主菜单
- **功能**：游戏启动首屏，展示标题和菜单选项
- **选项**：新的乱世 / 继续游戏 / 读取存档 / 游戏设置 / 退出游戏
- **关键步骤**：调用 `SaveService.getSaveSlots()` 判断是否有存档，有则显示"继续游戏"
- **导航**：→ `CreatePlayerScreen` / `HomeScreen`（读档）/ `SettingsScreen`

#### `screens/create_player_screen.dart` — 创建角色
- **功能**：输入名字，选择身份（汉室宗亲/边郡武人/寒门谋士/商贾世家），展示各身份加成说明
- **关键步骤**：
  1. 输入框获取名字
  2. 四个身份卡片选择
  3. 确认后调用 `Player.createWithIdentity()` 创建玩家
  4. 初始化默认建筑、初始武将、初始任务
  5. 组装 `GameSave` 并调用 `SaveService.autoSave()`
- **导航**：→ `HomeScreen`

#### `screens/home_screen.dart` — 主城主界面
- **功能**：游戏核心枢纽，显示资源总览 + 快捷入口
- **布局**：
  - 顶部：`ResourceBar` 组件显示所有资源
  - 中部：文字描述城池概况 + 建筑快捷入口按钮网格
  - 底部导航栏：武将 / 布阵 / 背包 / 任务
- **关键步骤**：
  1. `initState` 中从 Service 加载当前存档数据
  2. 提供按钮跳转到各子系统 Screen
  3. "结束一天"按钮触发 `ResourceService.calculateDailyIncome()` 并推进日期
- **导航**：→ 所有子系统 Screen

#### `screens/city_screen.dart` — 城池建设
- **功能**：展示建筑列表，支持查看/升级
- **关键步骤**：
  1. 展示所有建筑卡片（名称、等级、效果、升级费用）
  2. 升级前检查资源 + 官府等级上限 + 同时升级数 ≤ 2
  3. 确认后扣除资源，标记 `isUpgrading`，记录 `upgradeEndTime`
  4. 每次进入界面检查升级是否完成

#### `screens/politics_screen.dart` — 内政治理
- **功能**：每日有限行动点的内政操作
- **选项**：巡查城池 / 开仓赈济 / 征收赋税 / 招募乡勇 / 整顿吏治 / 修缮城防
- **关键步骤**：检查行动点 → 执行效果 → `setState` 刷新 → 行动点归零后提示

#### `screens/general_list_screen.dart` — 武将列表
- **功能**：展示已拥有武将，支持按阵营/品质筛选
- **布局**：顶部 TabBar（全部/魏/蜀/吴/群雄）+ `GridView` 武将卡片
- **底部按钮**：编队 / 推荐阵容
- **导航**：点击卡片 → `GeneralDetailScreen`

#### `screens/general_detail_screen.dart` — 武将详情
- **功能**：展示武将完整信息
- **内容**：六维属性条形图、技能列表与说明、装备栏、兵种信息、缘分提示
- **操作**：升级 / 装备 / 卸下

#### `screens/formation_screen.dart` — 布阵界面
- **功能**：选择阵型 + 安排武将站位
- **布局**：
  - 顶部：阵型选择横滑列表
  - 中部：3×3 网格（前排/中排/后排），可点击格子选择武将填入
  - 底部：保存布阵按钮
- **关键步骤**：
  1. 加载已有阵型列表和当前布阵
  2. 点击空格子弹出可选武将列表（排除已部署）
  3. 保存时校验上阵人数 ≤ 5

#### `screens/battle_screen.dart` — 战斗主界面
- **功能**：回合制战斗交互核心
- **布局**：
  - 上方：回合数显示
  - 左列：我方武将列表（HP/怒气条）
  - 右列：敌方列表（HP 条）
  - 中部：`BattleLogWidget` 滚动日志
  - 底部指令栏：攻击 / 技能 / 计策 / 防御 / 道具 / 自动战斗 / 逃跑
- **关键步骤**：
  1. `initState` 调用 `BattleEngine.initBattle()` 初始化
  2. 按速度排序确定行动顺序
  3. 玩家选择指令 → `BattleEngine.executePlayerAction()` → 更新 `BattleState` → `setState`
  4. 敌方回合 → `BattleEngine.executeEnemyTurn()` → 延迟展示日志
  5. 每回合结束检查胜负 → 结束则跳转 `BattleResultScreen`
  6. 支持切换自动战斗模式

#### `screens/battle_result_screen.dart` — 战斗结算
- **功能**：展示战斗结果
- **内容**：胜利/失败标题 + 星级评价 + MVP + 战损统计 + 奖励列表
- **失败时**：展示失败原因分析 + 提升建议
- **按钮**：确定（返回地图）/ 再战一场 / 下一关

#### `screens/world_map_screen.dart` — 世界地图
- **功能**：章节关卡选择，纯文字列表展示
- **布局**：
  - 章节 Tab 切换
  - 关卡列表（名称/类型/推荐等级/星级/完成状态）
  - 底部：出征按钮
- **关键步骤**：选择关卡 → 确认出征消耗粮草 → 跳转 `BattleScreen`

#### `screens/recruit_screen.dart` — 招募界面
- **功能**：三种招募方式
- **布局**：三个招募卡片（普通/高级/名将），展示概率和费用
- **关键步骤**：选择招募方式 → 检查资源/招募令 → 调用 `RecruitService` → 展示结果弹窗

#### `screens/quest_screen.dart` — 任务列表
- **功能**：展示任务，分类查看
- **Tab**：主线 / 支线 / 每日 / 成就
- **每条任务**：名称 + 进度条 + 奖励预览 + 领取按钮
- **关键步骤**：检查任务完成状态 → 领取奖励 → `setState` 刷新

#### `screens/quest_dialog_screen.dart` — 剧情对话
- **功能**：展示剧情文字 + 选项分支
- **布局**：角色名 + 对话文字（逐字显示效果）+ 选项按钮列表
- **关键步骤**：
  1. 加载当前剧情节点
  2. 逐字展示文本（`Timer.periodic` 控制）
  3. 显示选项 → 玩家选择 → 执行效果 → 推进到下一节点或返回

#### `screens/inventory_screen.dart` — 背包
- **功能**：查看和使用道具
- **Tab**：全部 / 装备 / 消耗品 / 材料 / 宝物
- **布局**：`GridView` 道具网格，每格显示名称+数量+品质色
- **操作**：使用道具 / 装备到武将 / 批量出售

#### `screens/story_event_screen.dart` — 随机事件
- **功能**：展示探索/日常随机事件
- **布局**：事件标题 + 描述文字 + 选项列表
- **关键步骤**：展示事件 → 选择选项 → 执行效果 → 可能链式触发新事件 → 返回

#### `screens/settings_screen.dart` — 设置
- **功能**：游戏设置和存档管理
- **选项**：音效开关 / 战斗速度 / 屏幕震动 / 手动存档 / 读档 / 删除存档 / 返回主菜单
- **关键步骤**：开关状态存入 `SharedPreferences`

---

### 3.5 组件层（widgets/）

#### `widgets/resource_bar.dart`
- **功能**：横向资源显示条
- **参数**：`Map<String, int> resources`
- **展示**：铜钱/粮草/木材/铁矿/兵力 图标(Icons) + 数值

#### `widgets/general_card.dart`
- **功能**：武将卡片
- **参数**：`General general`
- **展示**：品质色边框 + 名字 + 星级 + 等级 + 兵种标签

#### `widgets/battle_log_widget.dart`
- **功能**：战斗日志滚动列表
- **参数**：`List<BattleLogEntry> logs`
- **特点**：`ListView` + `ScrollController`，新日志自动滚到底部，不同类型日志不同颜色

#### `widgets/stat_row.dart`
- **功能**：属性条行
- **参数**：`String label, int value, int maxValue`
- **展示**：标签 + 进度条 + 数值

#### `widgets/confirm_dialog.dart`
- **功能**：通用确认对话框
- **参数**：`String title, String content, VoidCallback onConfirm`
- **风格**：古风边框装饰

#### `widgets/styled_button.dart`
- **功能**：古风按钮
- **参数**：`String text, VoidCallback onPressed, {ButtonStyle style}`
- **风格**：圆角 + 金色描边 + 深色背景

#### `widgets/section_header.dart`
- **功能**：区块标题栏
- **参数**：`String title`
- **展示**：左右装饰线 + 居中文字

---

## 四、数据流与耦合控制

### 4.1 数据流方向

```
StorageService (SP读写)
       ↑
SaveService (存档序列化)
       ↑
GameSave (聚合数据对象)
       ↑
Screen (持有 GameSave 副本, setState 刷新)
       ↓
各 Service (纯计算, 返回新对象, 不修改入参)
```

### 4.2 解耦原则

| 原则 | 实现方式 |
|------|----------|
| Model 不依赖 Service | Model 只有数据字段 + fromJson/toJson，无业务逻辑 |
| Service 不依赖 Widget | Service 只接收/返回 Model 对象，不 import `material.dart` |
| Screen 不直接操作 SP | Screen 通过 Service 间接读写，`StorageService` 只在 `SaveService` 中使用 |
| Screen 间传参 | 通过路由参数传递 ID，目标 Screen 自行从 Service 加载数据 |
| 战斗引擎纯函数 | `BattleEngine` 方法全部接收 `BattleState` 返回新 `BattleState`，不持有状态 |
| 静态数据集中管理 | `GameDataService` 统一提供内置数据，其他模块不硬编码数据 |

### 4.3 存档时机

- 自动存档：每天开始 / 战斗结束 / 主线任务完成
- 手动存档：设置界面 / 主城界面按钮

---

## 五、实现优先级与开发计划

### 第一阶段：核心框架（6个文件）
1. `main.dart` — 入口 + 路由
2. `app/app_theme.dart` — 主题
3. `app/constants.dart` — 常量枚举
4. `app/app_router.dart` — 路由表
5. `services/storage_service.dart` — SP 封装
6. `services/save_service.dart` — 存档

### 第二阶段：数据模型（12个文件）
7. `models/player.dart`
8. `models/general.dart`
9. `models/skill.dart`
10. `models/building.dart`
11. `models/item.dart`
12. `models/enemy.dart`
13. `models/quest.dart`
14. `models/event.dart`
15. `models/battle.dart`
16. `models/formation.dart`
17. `models/chapter.dart`
18. `models/game_save.dart`

### 第三阶段：业务服务（4个文件）
19. `services/game_data_service.dart` — 内置数据
20. `services/resource_service.dart` — 资源计算
21. `services/recruit_service.dart` — 招募逻辑
22. `services/battle_engine.dart` — 战斗引擎（最复杂）

### 第四阶段：通用组件（7个文件）
23. `widgets/styled_button.dart`
24. `widgets/section_header.dart`
25. `widgets/resource_bar.dart`
26. `widgets/stat_row.dart`
27. `widgets/general_card.dart`
28. `widgets/confirm_dialog.dart`
29. `widgets/battle_log_widget.dart`

### 第五阶段：核心界面（优先可玩流程，8个文件）
30. `screens/splash_screen.dart` — 主菜单
31. `screens/create_player_screen.dart` — 创建角色
32. `screens/home_screen.dart` — 主城
33. `screens/city_screen.dart` — 建设
34. `screens/politics_screen.dart` — 内政
35. `screens/formation_screen.dart` — 布阵
36. `screens/battle_screen.dart` — 战斗（核心）
37. `screens/battle_result_screen.dart` — 结算

### 第六阶段：扩展界面（7个文件）
38. `screens/general_list_screen.dart`
39. `screens/general_detail_screen.dart`
40. `screens/world_map_screen.dart`
41. `screens/recruit_screen.dart`
42. `screens/quest_screen.dart`
43. `screens/quest_dialog_screen.dart`
44. `screens/inventory_screen.dart`

### 第七阶段：收尾（2个文件）
45. `screens/story_event_screen.dart`
46. `screens/settings_screen.dart`

---

## 六、pubspec.yaml 依赖配置

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.3.0

flutter:
  uses-material-design: true
  # 无 assets 图片资源
  # 无外部字体
```

---

## 七、关键技术决策

| 决策项 | 选择 | 理由 |
|--------|------|------|
| 状态管理 | `setState` | 简单直接，适合单机文字游戏，每个 Screen 自管理 |
| 数据持久化 | `shared_preferences` + JSON | 轻量，无需 SQLite，存档数据量小 |
| 静态数据源 | Dart 硬编码 | 不依赖 JSON 文件 assets，避免异步加载复杂度 |
| 路由 | `Navigator.pushNamed` + 集中路由表 | 标准方案，避免引入 go_router 等 |
| 战斗引擎 | 纯函数式 | 接收 BattleState 返回新 BattleState，便于测试和调试 |
| 不使用的包 | freezed / part / google_fonts / share_plus / cached_network_image | 按要求排除 |
