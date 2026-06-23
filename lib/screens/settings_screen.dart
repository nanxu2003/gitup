import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/game_art.dart';
import '../services/save_service.dart';
import '../widgets/game_backdrop_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  final SaveService saveService;

  const SettingsScreen({super.key, required this.saveService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: GamePageBackdrop.reading(
        backgroundAsset: GameArt.recruitHallBackground,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('存档管理'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.save, color: AppTheme.accentColor),
                title: const Text(
                  '手动存档',
                  style: TextStyle(color: AppTheme.textColor),
                ),
                subtitle: const Text(
                  '请从主界面点击右上角保存按钮',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('请从主界面保存游戏'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.delete_sweep,
                  color: AppTheme.dangerColor,
                ),
                title: const Text(
                  '删除所有存档',
                  style: TextStyle(color: AppTheme.dangerColor),
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('确认删除'),
                      content: const Text('确定要删除所有存档吗？此操作不可恢复。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            '删除',
                            style: TextStyle(color: AppTheme.dangerColor),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    for (int i = 0; i < 3; i++) {
                      await saveService.deleteSave(i);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('所有存档已删除'),
                          backgroundColor: AppTheme.dangerColor,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            const Divider(color: Color(0xFF4A3F30)),
            _sectionTitle('帮助与法律'),
            _navItem(
              context,
              '使用帮助',
              Icons.help_outline,
              AppTheme.accentColor,
              '/help',
            ),
            _navItem(
              context,
              '用户协议',
              Icons.description_outlined,
              AppTheme.accentColor,
              '/user_agreement',
            ),
            _navItem(
              context,
              '隐私协议',
              Icons.privacy_tip_outlined,
              AppTheme.accentColor,
              '/privacy_policy',
            ),
            _navItem(
              context,
              '反馈与建议',
              Icons.rate_review_outlined,
              AppTheme.accentColor,
              '/feedback',
            ),
            const Divider(color: Color(0xFF4A3F30)),
            _sectionTitle('关于'),
            _navItem(
              context,
              '关于我们',
              Icons.info_outline,
              AppTheme.accentColor,
              '/about',
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                '三国志：问鼎天下 v1.0.0',
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.accentColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(color: AppTheme.textColor)),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondaryColor,
          size: 20,
        ),
        onTap: () => Navigator.of(context).pushNamed(route),
      ),
    );
  }
}
