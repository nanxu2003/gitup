import 'dart:math';
import '../app/constants.dart';
import '../models/general.dart';
import 'game_data_service.dart';

class RecruitService {
  static final Random _random = Random();

  /// 普通招募保底计数（每30次必出蓝色以上）
  static int normalPityCounter = 0;
  static const int normalPityThreshold = 30;

  /// 高级招募保底计数（每10次必出紫色以上）
  static int advancedPityCounter = 0;
  static const int advancedPityThreshold = 10;

  // 普通招募（白40%/绿30%/蓝20%/紫8%/橙2%，30次保底蓝色）
  static General normalRecruit() {
    normalPityCounter++;
    Map<Quality, double> probs;
    if (normalPityCounter >= normalPityThreshold) {
      // 保底：必出蓝色以上
      probs = {Quality.blue: 0.65, Quality.purple: 0.25, Quality.orange: 0.10};
      normalPityCounter = 0;
    } else {
      probs = {
        Quality.white: 0.40,
        Quality.green: 0.30,
        Quality.blue: 0.20,
        Quality.purple: 0.08,
        Quality.orange: 0.02,
      };
    }
    final quality = _rollQuality(probs);
    // 如果出了高品质，重置保底
    if (quality.index >= Quality.blue.index) {
      normalPityCounter = 0;
    }
    return _pickRandomGeneral(quality);
  }

  // 高级招募（蓝45%/紫35%/橙15%/红5%，10次保底紫色）
  static General advancedRecruit() {
    advancedPityCounter++;
    Map<Quality, double> probs;
    if (advancedPityCounter >= advancedPityThreshold) {
      // 保底：必出紫色以上
      probs = {Quality.purple: 0.60, Quality.orange: 0.30, Quality.red: 0.10};
      advancedPityCounter = 0;
    } else {
      probs = {
        Quality.blue: 0.45,
        Quality.purple: 0.35,
        Quality.orange: 0.15,
        Quality.red: 0.05,
      };
    }
    final quality = _rollQuality(probs);
    if (quality.index >= Quality.purple.index) {
      advancedPityCounter = 0;
    }
    return _pickRandomGeneral(quality);
  }

  // 十连普通招募
  static List<General> normalRecruitTen() {
    return List.generate(10, (_) => normalRecruit());
  }

  // 十连高级招募
  static List<General> advancedRecruitTen() {
    return List.generate(10, (_) => advancedRecruit());
  }

  static Quality _rollQuality(Map<Quality, double> probabilities) {
    final roll = _random.nextDouble();
    double cumulative = 0;
    for (final entry in probabilities.entries) {
      cumulative += entry.value;
      if (roll <= cumulative) return entry.key;
    }
    return probabilities.keys.first;
  }

  static General _pickRandomGeneral(Quality targetQuality) {
    final allGenerals = GameDataService.getAllGenerals();
    var candidates = allGenerals
        .where((g) => g.quality == targetQuality)
        .toList();
    if (candidates.isEmpty) {
      candidates = allGenerals;
    }
    final picked = candidates[_random.nextInt(candidates.length)];
    final general = General.fromJson(picked.toJson());
    general.level = 1;
    general.star = 1;
    general.exp = 0;
    general.isDeployed = false;
    general.equippedItemIds = [];
    return general;
  }

  // 获取招募费用
  static Map<String, int> getRecruitCost(String type) {
    switch (type) {
      case 'normal':
        return {'coin': 500};
      case 'normal_ten':
        return {'coin': 4500}; // 十连打折
      case 'advanced':
        return {'coin': 1500, 'recruit_token': 1};
      case 'advanced_ten':
        return {'coin': 13500, 'recruit_token': 9}; // 十连打折
      default:
        return {'coin': 500};
    }
  }

  // 获取当前招募令数量（从背包中查找）
  static int getTokenCount(List<dynamic> inventory) {
    for (final item in inventory) {
      if (item is Map && item['id'] == 'recruit_token') {
        return item['quantity'] as int? ?? 0;
      }
      // 支持 GameItem 对象
      try {
        if (item.id == 'recruit_token') {
          return item.quantity as int;
        }
      } catch (_) {}
    }
    return 0;
  }
}
