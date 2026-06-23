import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/game_art.dart';
import '../widgets/styled_button.dart';
import '../services/save_service.dart';
import '../widgets/game_backdrop_scaffold.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  final SaveService saveService;
  final StorageService storageService;

  const SplashScreen({
    super.key,
    required this.saveService,
    required this.storageService,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasSave = false;
  List<int> _slots = [];

  @override
  void initState() {
    super.initState();
    _checkSaves();
  }

  Future<void> _checkSaves() async {
    _hasSave = widget.saveService.hasAnySave();
    _slots = await widget.saveService.getSaveSlots();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GamePageBackdrop(
        backgroundAsset: GameArt.worldMapBackground,
        scrimColors: const [Color(0x801A0F0A), Color(0xD91A0F0A)],
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x661A0F0A), Color(0x993E2723), Color(0xCC1A0F0A)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // 装饰线
                  Container(
                    width: 120,
                    height: 2,
                    color: AppTheme.accentColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  // 标题
                  const Icon(
                    Icons.shield,
                    size: 56,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '三国志',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 12,
                      shadows: [
                        Shadow(color: Color(0x66D4A017), blurRadius: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 1,
                    color: AppTheme.accentColor.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '问 鼎 天 下',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 20,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '东汉末年，天下大乱\n群雄并起，逐鹿中原',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 2,
                    color: AppTheme.accentColor.withValues(alpha: 0.5),
                  ),
                  const Spacer(),
                  // 菜单按钮
                  StyledButton(
                    text: '新的乱世',
                    icon: Icons.play_arrow,
                    width: 200,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/create_player');
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_hasSave)
                    StyledButton(
                      text: '继续游戏',
                      icon: Icons.refresh,
                      width: 200,
                      onPressed: () async {
                        final save = await widget.saveService.loadGame(0);
                        if (!context.mounted) return;
                        if (save != null) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/home',
                            (r) => false,
                            arguments: save,
                          );
                        }
                      },
                    ),
                  if (_hasSave) const SizedBox(height: 16),
                  if (_slots.isNotEmpty)
                    StyledButton(
                      text: '读取存档',
                      icon: Icons.folder_open,
                      width: 200,
                      onPressed: () => _showLoadDialog(),
                    ),
                  const SizedBox(height: 16),
                  StyledButton(
                    text: '游戏设置',
                    icon: Icons.settings,
                    width: 200,
                    isPrimary: false,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/settings');
                    },
                  ),
                  const Spacer(),
                  Text(
                    '适逢游戏启航，沉浸游戏传奇\n合纵连横时，享健康生活',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLoadDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('读取存档'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final hasSlot = _slots.contains(i);
            return ListTile(
              leading: Icon(
                hasSlot ? Icons.save : Icons.save_outlined,
                color: hasSlot
                    ? AppTheme.accentColor
                    : AppTheme.textSecondaryColor,
              ),
              title: Text('存档槽 ${i + 1}'),
              subtitle: FutureBuilder<String?>(
                future: hasSlot
                    ? widget.saveService.getSaveInfo(i)
                    : Future.value(null),
                builder: (ctx, snap) => Text(
                  snap.data ?? '空',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              onTap: hasSlot
                  ? () async {
                      final save = await widget.saveService.loadGame(i);
                      if (!context.mounted) return;
                      if (save != null) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home',
                          (r) => false,
                          arguments: save,
                        );
                      }
                    }
                  : null,
              trailing: hasSlot
                  ? IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: AppTheme.dangerColor,
                        size: 18,
                      ),
                      onPressed: () async {
                        await widget.saveService.deleteSave(i);
                        _checkSaves();
                        Navigator.of(ctx).pop();
                      },
                    )
                  : null,
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
