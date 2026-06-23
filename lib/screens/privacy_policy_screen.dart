import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/game_art.dart';
import '../widgets/game_backdrop_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('隐私协议')),
      body: GamePageBackdrop.reading(
        backgroundAsset: GameArt.recruitHallBackground,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '隐私保护政策',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '更新日期：2025年1月1日\n生效日期：2025年1月1日',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            _section(
              '概述',
              '《三国志：问鼎天下》（以下简称"本游戏"）非常重视用户的隐私保护。'
                  '本隐私政策旨在向您说明我们如何收集、使用和保护您的个人信息。\n\n'
                  '本游戏是一款纯单机游戏，不会主动收集、上传您的任何个人数据。',
            ),
            _section(
              '一、数据收集说明',
              '1. 本游戏不收集任何个人身份信息（如姓名、手机号、邮箱等）。\n'
                  '2. 本游戏不收集设备信息（如设备型号、操作系统版本等）。\n'
                  '3. 本游戏不包含任何第三方数据统计SDK。',
            ),
            _section(
              '二、数据存储说明',
              '1. 您的游戏进度数据（包括城池信息、武将数据、资源数量等）'
                  '仅保存在您的设备本地存储中。\n'
                  '2. 这些数据不会上传至任何服务器。\n'
                  '3. 卸载本应用将导致本地存档数据被清除。',
            ),
            _section(
              '三、网络使用说明',
              '1. 本游戏为纯单机游戏，运行过程中不需要网络连接。\n'
                  '2. 本游戏不会发起任何网络请求。\n'
                  '3. 您的游戏数据不会通过网络传输至任何第三方。',
            ),
            _section(
              '四、权限使用说明',
              '本游戏可能申请以下设备权限：\n\n'
                  '1. 存储权限：用于保存游戏存档数据（仅本地读写）。\n'
                  '2. 以上权限仅用于游戏功能实现，不会用于其他用途。',
            ),
            _section(
              '五、未成年人保护',
              '1. 本游戏内容健康向上，适合各年龄段用户。\n'
                  '2. 本游戏不收集未成年人个人信息。\n'
                  '3. 建议未成年人在监护人指导下合理安排游戏时间。',
            ),
            _section(
              '六、政策更新',
              '1. 我们可能会不时更新本隐私政策，更新后的政策将在游戏内公布。\n'
                  '2. 重大变更会通过游戏内公告方式通知用户。',
            ),
            _section('七、联系我们', '如您对本隐私政策有任何疑问或建议，请通过游戏内「反馈与建议」功能与我们联系。'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 13.5,
                  height: 1.65,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
