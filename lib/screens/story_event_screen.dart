import 'dart:math';
import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/game_art.dart';
import '../models/game_save.dart';
import '../models/event.dart';
import '../services/game_data_service.dart';
import '../widgets/game_backdrop_scaffold.dart';
import '../widgets/ornate_game_frame.dart';

class StoryEventScreen extends StatefulWidget {
  final GameSave gameSave;

  const StoryEventScreen({super.key, required this.gameSave});

  @override
  State<StoryEventScreen> createState() => _StoryEventScreenState();
}

class _StoryEventScreenState extends State<StoryEventScreen> {
  GameEvent? _event;
  String? _resultText;
  Map<String, int>? _resultEffects;
  int _displayedChars = 0;
  bool _isTyping = true;

  @override
  void initState() {
    super.initState();
    _pickRandomEvent();
    _startTyping();
  }

  void _pickRandomEvent() {
    final events = GameDataService.getAllEvents();
    final unplayed = events
        .where((e) => !widget.gameSave.completedEventIds.contains(e.id))
        .toList();
    final pool = unplayed.isNotEmpty ? unplayed : events;
    if (pool.isNotEmpty) {
      _event = pool[Random().nextInt(pool.length)];
    }
  }

  void _startTyping() {
    if (_event == null) return;
    _displayedChars = 0;
    _isTyping = true;
    _typeNext();
  }

  void _typeNext() {
    if (_event == null || !_isTyping) return;
    if (_displayedChars < _event!.description.length) {
      Future.delayed(const Duration(milliseconds: 35), () {
        if (!mounted || !_isTyping) return;
        setState(() => _displayedChars++);
        _typeNext();
      });
    } else {
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('事件')),
        body: GamePageBackdrop(
          backgroundAsset: GameArt.worldMapBackground,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_stories,
                  size: 56,
                  color: AppTheme.textSecondaryColor.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 12),
                const Text(
                  '今日无事件发生',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '城中一切平静',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(widget.gameSave),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('返回'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final event = _event!;
    final displayText = event.description.substring(
      0,
      _displayedChars.clamp(0, event.description.length),
    );

    return Scaffold(
      body: GamePageBackdrop(
        backgroundAsset: GameArt.worldMapBackground,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.58),
                AppTheme.surfaceColor.withValues(alpha: 0.42),
                AppTheme.primaryColor.withValues(alpha: 0.78),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 顶部装饰条
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.accentColor.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // 标题区
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.accentColor.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_stories,
                          color: AppTheme.accentColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '突发事件',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              event.title,
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 关闭按钮
                      GameHeaderButton(
                        controlKey: const ValueKey('story-event-close-button'),
                        icon: Icons.close,
                        tooltip: '关闭事件',
                        onPressed: () =>
                            Navigator.of(context).pop(widget.gameSave),
                        size: 40,
                      ),
                    ],
                  ),
                ),
                // 装饰分隔线
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.accentColor.withValues(alpha: 0.2),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.diamond,
                          size: 10,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.accentColor.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
                // 事件描述（打字效果）
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF4A3F30)),
                          ),
                          child: Text(
                            displayText,
                            style: const TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 15,
                              height: 1.8,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 选项区
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      // 结果展示
                      if (_resultText != null) _buildResultPanel(),
                      // 选项按钮
                      if (!_isTyping && _resultText == null)
                        ...event.choices.asMap().entries.map((entry) {
                          final i = entry.key;
                          final choice = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildChoiceButton(choice, i),
                          );
                        }),
                      // 打字中显示跳过
                      if (_isTyping)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _displayedChars = event.description.length;
                              _isTyping = false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.skip_next,
                                  size: 16,
                                  color: AppTheme.textSecondaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '点击跳过',
                                  style: TextStyle(
                                    color: AppTheme.textSecondaryColor
                                        .withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // 结果后显示返回按钮
                      if (_resultText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(widget.gameSave),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentColor,
                                foregroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                '返回城池',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton(EventChoice choice, int index) {
    final effects = choice.effects;
    final hasPositive = effects.values.any((v) => v > 0);
    final hasNegative = effects.values.any((v) => v < 0);

    return GestureDetector(
      onTap: () => _selectChoice(choice),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasPositive && !hasNegative
                ? AppTheme.successColor.withValues(alpha: 0.4)
                : hasNegative && !hasPositive
                ? AppTheme.dangerColor.withValues(alpha: 0.3)
                : const Color(0xFF4A3F30),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    choice.text,
                    style: const TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            // 效果预览
            if (effects.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: effects.entries.map((e) {
                  return _effectPreviewChip(e.key, e.value);
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _effectPreviewChip(String key, int value) {
    final isPositive = value > 0;
    final color = isPositive ? AppTheme.successColor : AppTheme.dangerColor;
    final label = _effectLabel(key);
    final sign = isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label $sign$value',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildResultPanel() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book,
                size: 16,
                color: AppTheme.accentColor,
              ),
              const SizedBox(width: 6),
              const Text(
                '结果',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _resultText ?? '',
            style: const TextStyle(
              color: AppTheme.textColor,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          // 效果汇总
          if (_resultEffects != null && _resultEffects!.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(color: Color(0xFF4A3F30)),
            const SizedBox(height: 6),
            const Text(
              '影响',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _resultEffects!.entries.map((e) {
                if (e.value == 0) return const SizedBox();
                return _effectPreviewChip(e.key, e.value);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _selectChoice(EventChoice choice) {
    // 应用效果
    for (final entry in choice.effects.entries) {
      switch (entry.key) {
        case 'morale':
          widget.gameSave.player.morale =
              (widget.gameSave.player.morale + entry.value).clamp(0, 100);
          break;
        case 'reputation':
          widget.gameSave.player.reputation += entry.value;
          break;
        case 'exp':
          widget.gameSave.player.exp += entry.value;
          break;
        default:
          final current = widget.gameSave.player.resources[entry.key] ?? 0;
          widget.gameSave.player.resources[entry.key] = current + entry.value;
      }
    }

    setState(() {
      _resultText = choice.resultText ?? '选择已确认。';
      _resultEffects = Map<String, int>.from(choice.effects);
    });

    widget.gameSave.completedEventIds.add(_event!.id);
  }

  String _effectLabel(String key) {
    const labels = {
      'coin': '铜钱',
      'grain': '粮草',
      'wood': '木材',
      'iron': '铁矿',
      'soldiers': '兵力',
      'morale': '民心',
      'reputation': '声望',
      'exp': '经验',
    };
    return labels[key] ?? key;
  }
}
