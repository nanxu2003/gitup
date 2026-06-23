import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../app/constants.dart';
import '../app/game_art.dart';
import '../models/chapter.dart';
import '../models/game_save.dart';
import '../services/game_data_service.dart';
import '../widgets/game_art_layer.dart';
import '../widgets/ornate_game_frame.dart';
import 'quest_dialog_screen.dart';

class WorldMapScreen extends StatefulWidget {
  final GameSave gameSave;

  const WorldMapScreen({super.key, required this.gameSave});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> {
  late GameSave _save;
  int _chapterIndex = 0;

  static const _stageDescriptions = <String, String>{
    '1-1': '流民涌入城中，请求庇护。乱世序幕就此拉开。',
    '1-2': '黄巾贼军突袭，小心伏击！守卫平原城！',
    '1-3': '村庄百姓危急，速速救援！',
    '1-4': '张角施放妖术，天降异象。',
    '1-5': '黄巾渠帅盘踞县城，一战定乾坤。',
    '2-1': '洛阳传来密信，讨董联盟正在组建。',
    '2-2': '虎牢关前，董卓铁骑严阵以待。',
    '2-3': '十八路诸侯齐聚，人心难测。',
    '2-4': '人中吕布，马中赤兔！谁敢一战？',
    '2-5': '董卓焚烧洛阳，火光冲天。',
  };

  static const _nodePositions = <Offset>[
    Offset(0.70, 0.19),
    Offset(0.49, 0.35),
    Offset(0.72, 0.52),
    Offset(0.25, 0.66),
    Offset(0.48, 0.82),
    Offset(0.72, 0.89),
  ];

  @override
  void initState() {
    super.initState();
    _save = widget.gameSave;
  }

  List<Chapter> get _chapters =>
      _save.chapters.where((chapter) => chapter.isUnlocked).toList();

  bool _isStageUnlocked(Chapter chapter, int index) {
    if (index == 0) return true;
    return chapter.stages[index - 1].isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    final chapters = _chapters;
    if (chapters.isEmpty) {
      return const Scaffold(body: Center(child: Text('尚未解锁征途')));
    }
    final chapter = chapters[_chapterIndex.clamp(0, chapters.length - 1)];

    return Scaffold(
      backgroundColor: const Color(0xFF12080D),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GameArtLayer(
            assetPath: GameArt.worldMapBackground,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            fallback: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF083A52),
                    Color(0xFF486E64),
                    Color(0xFF391B18),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: -72,
            bottom: -42,
            width: 270,
            height: 430,
            child: IgnorePointer(
              child: GameArtLayer(
                assetPath: GameArt.mapGuide,
                alignment: Alignment.bottomLeft,
                opacity: 0.7,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xB30C0710),
                  Color(0x08000000),
                  Color(0xB30E080B),
                ],
                stops: [0, 0.28, 1],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(chapters, chapter),
                Expanded(child: _buildMap(chapter)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(List<Chapter> chapters, Chapter chapter) {
    final stars = chapter.stages.fold<int>(
      0,
      (sum, stage) => sum + stage.starsEarned,
    );
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 82,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const BrushTitle('九州征途'),
              Positioned(
                left: 10,
                top: 10,
                child: GameHeaderButton(
                  controlKey: const ValueKey('world-map-back-button'),
                  tooltip: '返回',
                  onPressed: () => Navigator.of(context).pop(_save),
                  icon: Icons.arrow_back_ios_new,
                ),
              ),
              Positioned(
                right: 12,
                bottom: 4,
                child: Text(
                  '★ $stars',
                  style: const TextStyle(
                    color: Color(0xFFFFD75B),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 37,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 54),
            scrollDirection: Axis.horizontal,
            itemCount: chapters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final selected = index == _chapterIndex;
              return GestureDetector(
                onTap: () => setState(() => _chapterIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xD98B1B18)
                        : const Color(0xB3190C0F),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFFFC35C)
                          : const Color(0x887F6C58),
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: selected
                        ? const [
                            BoxShadow(color: Color(0x99FF4D24), blurRadius: 10),
                          ]
                        : null,
                  ),
                  child: Text(
                    '第${chapters[index].id}章',
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFFD6C8B7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMap(Chapter chapter) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 12,
              top: 8,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 14, 6),
                decoration: const BoxDecoration(
                  color: Color(0xCC1B1010),
                  border: Border(
                    left: BorderSide(color: Color(0xFFE34829), width: 4),
                  ),
                ),
                child: Text(
                  chapter.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            ...List.generate(chapter.stages.length, (index) {
              final stage = chapter.stages[index];
              final position = _nodePositions[index % _nodePositions.length];
              final unlocked = _isStageUnlocked(chapter, index);
              return Positioned(
                left: constraints.maxWidth * position.dx - 45,
                top: constraints.maxHeight * position.dy - 38,
                child: _StageNode(
                  stage: stage,
                  unlocked: unlocked,
                  onTap: () {
                    if (!unlocked) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('需先攻克上一关卡')));
                      return;
                    }
                    _showStagePanel(stage);
                  },
                ),
              );
            }),
          ],
        );
      },
    );
  }

  void _showStagePanel(Stage stage) {
    final grainCost = stage.recommendedLevel * 100;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final typeColor = _stageColor(stage.type);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: OrnateGameFrame(
              title: stage.name,
              accentColor: typeColor,
              padding: const EdgeInsets.fromLTRB(18, 15, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stageDescriptions[stage.id] ?? '旌旗猎猎，前路未明。整军备战，静候将令。',
                    style: const TextStyle(
                      color: Color(0xFFEADFCF),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip('推荐 Lv.${stage.recommendedLevel}', typeColor),
                      if (stage.type != StageType.story)
                        _chip('粮草 -$grainCost', Colors.orange),
                      if (stage.rewards.coin > 0)
                        _chip(
                          '铜钱 +${stage.rewards.coin}',
                          AppTheme.accentColor,
                        ),
                      if (stage.rewards.exp > 0)
                        _chip('经验 +${stage.rewards.exp}', Colors.cyan),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        if (stage.type == StageType.story ||
                            stage.enemyIds.isEmpty) {
                          _triggerStory(stage);
                        } else {
                          _startBattle(stage);
                        }
                      },
                      icon: Icon(
                        stage.type == StageType.story
                            ? Icons.auto_stories
                            : Icons.sports_martial_arts,
                      ),
                      label: Text(
                        stage.type == StageType.story ? '阅览剧情' : '挥军出征',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8D211B),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFFFC35C)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _triggerStory(Stage stage) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => QuestDialogScreen(gameSave: _save, stage: stage),
          ),
        )
        .then((_) {
          if (!mounted) return;
          setState(() {
            stage.isCompleted = true;
            stage.starsEarned = 3;
          });
        });
  }

  void _startBattle(Stage stage) {
    final deployedCount = _save.generals
        .where((general) => general.isDeployed)
        .length;
    if (deployedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先在布阵界面安排出征武将'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final grainCost = stage.recommendedLevel * 100;
    if ((_save.player.resources['grain'] ?? 0) < grainCost) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('粮草不足'),
          content: Text(
            '出征需要 $grainCost 粮草\n当前：${_save.player.resources['grain'] ?? 0}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('知道了'),
            ),
          ],
        ),
      );
      return;
    }

    final enemies = stage.enemyIds
        .map(GameDataService.findEnemy)
        .where((enemy) => enemy != null)
        .toList();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('出征 · ${stage.name}'),
        content: Text(
          '敌军 ${enemies.length} 队\n消耗粮草 $grainCost\n此战凶险，将军可已整备妥当？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('且慢'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _save.player.resources['grain'] =
                  (_save.player.resources['grain'] ?? 0) - grainCost;
              Navigator.of(context)
                  .pushNamed(
                    '/battle',
                    arguments: {
                      'gameSave': _save,
                      'enemyIds': stage.enemyIds,
                      'stageId': stage.id,
                    },
                  )
                  .then((_) {
                    if (mounted) setState(() {});
                  });
            },
            child: const Text('确认出征'),
          ),
        ],
      ),
    );
  }

  Color _stageColor(StageType type) {
    return switch (type) {
      StageType.story => const Color(0xFFE6BE55),
      StageType.normal => const Color(0xFF50D7B3),
      StageType.elite => const Color(0xFFB36CFF),
      StageType.boss => const Color(0xFFFF513B),
    };
  }
}

class _StageNode extends StatelessWidget {
  final Stage stage;
  final bool unlocked;
  final VoidCallback onTap;

  const _StageNode({
    required this.stage,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = !unlocked
        ? Colors.blueGrey
        : stage.isCompleted
        ? const Color(0xFF43D69A)
        : stage.type == StageType.boss
        ? const Color(0xFFFF4B30)
        : const Color(0xFF75E9FF);
    return Semantics(
      button: true,
      label: stage.name,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 102,
          height: 88,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.92),
                      const Color(0xFF162A33),
                    ],
                  ),
                  border: Border.all(color: const Color(0xFFF6D789), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.75),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                    const BoxShadow(
                      color: Colors.black87,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  unlocked
                      ? stage.type == StageType.story
                            ? Icons.temple_buddhist
                            : Icons.fort
                      : Icons.lock,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              if (unlocked)
                Positioned(
                  right: 11,
                  top: -6,
                  child: AlertDiamond(completed: stage.isCompleted, size: 24),
                ),
              Positioned(
                top: 55,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 100),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xE61A0D10),
                    border: Border.all(color: color.withValues(alpha: 0.85)),
                  ),
                  child: Text(
                    stage.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unlocked ? Colors.white : const Color(0xFF9C9C9C),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 3),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
