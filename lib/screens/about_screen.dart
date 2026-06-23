import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/game_art.dart';
import '../widgets/game_backdrop_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于我们')),
      body: GamePageBackdrop.reading(
        backgroundAsset: GameArt.recruitHallBackground,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 20),
            // 应用图标
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.accentColor.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.castle,
                  color: AppTheme.accentColor,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '三国志：问鼎天下',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                '版本 1.0.0',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _infoCard(
              '游戏简介',
              '《三国志：问鼎天下》是一款以三国时代为背景的单机回合制策略游戏。\n\n'
                  '你将扮演一方城主，从一座小城起步，招兵买马、发展内政、征战四方，'
                  '最终问鼎天下，成就一代霸业。\n\n'
                  '游戏融合了城池经营、武将养成、阵法布阵、回合战斗等多种玩法，'
                  '带你体验波澜壮阔的三国乱世。',
              Icons.info_outline,
            ),
            const SizedBox(height: 12),
            _infoCard(
              '游戏特色',
              '• 纯文字策略：无需下载图片资源，轻量流畅\n'
                  '• 城池经营：发展农业、商业、军事，壮大实力\n'
                  '• 武将系统：招募名将，培养升级，打造最强阵容\n'
                  '• 阵法布阵：排兵布阵，运筹帷幄，决胜千里\n'
                  '• 随机事件：丰富剧情事件，每次游戏体验不同\n'
                  '• 离线畅玩：纯单机游戏，无需联网',
              Icons.star_outline,
            ),
            const SizedBox(height: 12),
            _infoCard(
              '开发团队',
              '独立开发者精心打造\n'
                  '如有任何问题或建议，欢迎通过「反馈与建议」与我们联系。',
              Icons.code,
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                '© 2025 三国志：问鼎天下\nAll Rights Reserved',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String content, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
