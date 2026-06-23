import '../app/constants.dart';
import '../models/player.dart';
import '../models/building.dart';

class ResourceService {
  // 计算每日资源产出
  static Map<String, int> calculateDailyIncome(
    List<Building> buildings,
    int morale,
  ) {
    int getLevel(BuildingType type) {
      final b = buildings.where((b) => b.type == type).firstOrNull;
      return b?.level ?? 0;
    }

    final govLevel = getLevel(BuildingType.government);
    final farmLevel = getLevel(BuildingType.farm);
    final marketLevel = getLevel(BuildingType.market);

    return {
      'coin': coinIncome(govLevel, marketLevel, morale),
      'grain': grainIncome(farmLevel),
      'wood': woodIncome(getLevel(BuildingType.lumberMill)),
      'iron': ironIncome(getLevel(BuildingType.ironWorks)),
      'soldiers': soldierRecovery(getLevel(BuildingType.barracks), morale),
    };
  }

  // 检查资源是否足够
  static bool canAfford(Player player, Map<String, int> cost) {
    for (final entry in cost.entries) {
      final current = player.resources[entry.key] ?? 0;
      if (current < entry.value) return false;
    }
    return true;
  }

  // 扣除资源（返回新Player对象）
  static Player deductResources(Player player, Map<String, int> cost) {
    final newPlayer = player.copy();
    for (final entry in cost.entries) {
      final current = newPlayer.resources[entry.key] ?? 0;
      newPlayer.resources[entry.key] = current - entry.value;
    }
    return newPlayer;
  }

  // 增加资源
  static Player addResources(Player player, Map<String, int> income) {
    final newPlayer = player.copy();
    for (final entry in income.entries) {
      final current = newPlayer.resources[entry.key] ?? 0;
      newPlayer.resources[entry.key] = current + entry.value;
    }
    return newPlayer;
  }

  // 建筑升级费用（根据当前等级）
  static Map<String, int> getUpgradeCost(Building building) {
    final base = building.upgradeCost;
    final multiplier = building.level + 1;
    return base.map((key, value) => MapEntry(key, value * multiplier));
  }

  // 检查建筑是否可以升级
  static bool canUpgradeBuilding(
    Building building,
    Player player,
    List<Building> allBuildings,
  ) {
    if (building.isMaxLevel) return false;

    // 检查官府等级上限
    final gov = allBuildings
        .where((b) => b.type == BuildingType.government)
        .firstOrNull;
    if (gov != null &&
        building.type != BuildingType.government &&
        building.level >= gov.level) {
      return false;
    }

    // 检查同时升级数量
    final upgradingCount = allBuildings.where((b) => b.isUpgrading).length;
    if (upgradingCount >= maxBuildingUpgrades) return false;

    // 检查资源
    final cost = getUpgradeCost(building);
    return canAfford(player, cost);
  }
}
