import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/game_art.dart';
import '../widgets/game_backdrop_scaffold.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('使用帮助')),
      body: GamePageBackdrop.reading(
        backgroundAsset: GameArt.recruitHallBackground,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '游戏帮助指南',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _helpSection('新手入门', Icons.play_circle_outline, [
              _qa('如何开始游戏？', '在主界面点击"开始新游戏"，输入您的城主名号和城池名称即可创建角色，进入游戏世界。'),
              _qa(
                '游戏的基本流程是什么？',
                '每天您可以执行一系列操作：处理内政、建设城池、招募武将、排兵布阵，'
                    '然后点击右下角"结束一天"进入下一日。每日结束后会自动获得资源收入。',
              ),
            ]),
            _helpSection('资源系统', Icons.monetization_on, [
              _qa(
                '有哪些资源？',
                '游戏中有五种资源：铜钱（经济建设）、粮草（军队补给）、'
                    '木材（建筑升级）、铁矿（装备制造）、兵力（出征作战）。',
              ),
              _qa(
                '如何获取资源？',
                '1. 每日自动收入：通过升级建筑提高每日产出。\n'
                    '2. 内政治理：处理政务事件获得额外奖励。\n'
                    '3. 出征讨伐：战胜敌人获得战利品。',
              ),
            ]),
            _helpSection('武将系统', Icons.people, [
              _qa(
                '如何招募武将？',
                '在主界面点击"招募贤才"进入招募页面。不同等级的招募需要消耗不同数量的铜钱，'
                    '高级招募有概率获得稀有武将。',
              ),
              _qa(
                '如何提升武将实力？',
                '1. 升级：通过内政治理和出征获得经验。\n'
                    '2. 装备：在背包中为武将装备武器和防具。\n'
                    '3. 布阵：合理安排武将上阵位置，发挥最大战力。',
              ),
            ]),
            _helpSection('战斗系统', Icons.map, [
              _qa(
                '如何进行战斗？',
                '1. 在布阵页面安排上阵武将和阵型。\n'
                    '2. 在主界面点击"出征讨伐"选择要攻打的目标。\n'
                    '3. 战斗自动进行，根据双方实力计算结果。',
              ),
              _qa(
                '战斗失败怎么办？',
                '提升武将等级和装备品质，调整阵法布局，'
                    '增加上阵兵力都可以提高胜率。',
              ),
            ]),
            _helpSection('存档管理', Icons.save, [
              _qa(
                '如何保存进度？',
                '在主界面点击右上角保存按钮即可手动存档。'
                    '游戏也会在每次页面操作后自动保存。',
              ),
              _qa(
                '存档会丢失吗？',
                '游戏数据保存在本地设备上。请注意：卸载应用会清除所有存档数据，'
                    '建议定期备份。',
              ),
            ]),
            _helpSection('常见问题', Icons.help_outline, [
              _qa('行动点用完了怎么办？', '每天行动点有限，合理安排使用。点击"结束一天"可以重置行动点。'),
              _qa('如何提升民心？', '通过内政治理中的惠民政策可以提升民心。民心越高，每日资源收入越多。'),
              _qa('如何解锁新章节？', '提升城主等级，完成当前章节的主线任务后即可解锁新章节。'),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _helpSection(String title, IconData icon, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppTheme.accentColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...items,
            ],
          ),
        ),
      ),
    );
  }

  Widget _qa(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Q',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              answer,
              style: TextStyle(
                color: AppTheme.textColor.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
