import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/game_art.dart';
import '../widgets/game_backdrop_scaffold.dart';

class UserAgreementScreen extends StatelessWidget {
  const UserAgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户协议')),
      body: GamePageBackdrop.reading(
        backgroundAsset: GameArt.recruitHallBackground,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '用户服务协议',
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
              '一、总则',
              '欢迎您使用《三国志：问鼎天下》游戏服务！本协议是您与游戏开发方之间关于使用本游戏服务所订立的协议。\n\n'
                  '请您在使用本游戏前仔细阅读本协议，一旦您使用本游戏服务即表示您已充分理解并同意本协议全部内容。',
            ),
            _section(
              '二、服务内容',
              '本游戏为用户提供一款以三国时代为背景的单机回合制策略游戏服务，包括但不限于：\n\n'
                  '1. 城池经营与资源管理\n'
                  '2. 武将招募与培养系统\n'
                  '3. 阵法布阵与回合战斗\n'
                  '4. 剧情事件与任务系统\n'
                  '5. 游戏数据本地存档管理',
            ),
            _section(
              '三、用户账号',
              '1. 本游戏为单机游戏，用户无需注册账号即可游玩。\n'
                  '2. 游戏数据保存在本地设备上，卸载应用将导致存档丢失。\n'
                  '3. 用户应妥善保管设备，避免因设备丢失导致数据损失。',
            ),
            _section(
              '四、用户行为规范',
              '1. 用户应遵守国家法律法规，不得利用本游戏从事违法违规活动。\n'
                  '2. 用户不得对本游戏进行反向工程、破解或修改。\n'
                  '3. 用户不得利用本游戏的漏洞或错误获取不正当利益。',
            ),
            _section(
              '五、知识产权',
              '1. 本游戏的所有内容，包括但不限于文字、图标、界面设计、游戏机制等，'
                  '均受知识产权法律法规保护。\n'
                  '2. 未经开发方书面授权，任何单位或个人不得以任何形式复制、传播、'
                  '展示本游戏的内容。',
            ),
            _section(
              '六、免责声明',
              '1. 本游戏为单机游戏，不对因设备故障、系统兼容性问题等导致的'
                  '数据丢失承担责任。\n'
                  '2. 游戏内容基于三国历史进行虚构创作，部分情节与史实可能有出入。\n'
                  '3. 因不可抗力导致的服务中断，开发方不承担责任。',
            ),
            _section(
              '七、协议修改',
              '1. 开发方有权根据需要修改本协议内容，修改后的协议将在游戏内公布。\n'
                  '2. 用户在协议修改后继续使用本游戏，即视为同意修改后的协议。',
            ),
            _section('八、联系方式', '如您对本协议有任何疑问，请通过游戏内「反馈与建议」功能与我们联系。'),
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
