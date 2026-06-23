import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/game_art.dart';
import '../models/game_save.dart';
import '../models/chapter.dart';
import '../models/event.dart';
import '../models/quest.dart';
import '../services/game_data_service.dart';
import '../widgets/game_backdrop_scaffold.dart';
import '../widgets/ornate_game_frame.dart';

class QuestDialogScreen extends StatefulWidget {
  final GameSave gameSave;
  final String? eventId;
  final Stage? stage;

  const QuestDialogScreen({
    super.key,
    required this.gameSave,
    this.eventId,
    this.stage,
  });

  @override
  State<QuestDialogScreen> createState() => _QuestDialogScreenState();
}

class _QuestDialogScreenState extends State<QuestDialogScreen> {
  GameEvent? _currentEvent;
  String? _resultText;
  int _displayedChars = 0;
  bool _isTyping = true;

  // 剧情关卡模式
  bool get _isStoryMode =>
      widget.stage != null && widget.stage!.storyContent.isNotEmpty;
  String get _storyText => _isStoryMode ? widget.stage!.storyContent : '';
  String? get _storyEnding => _isStoryMode ? widget.stage!.storyEnding : null;
  bool _showingEnding = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
    _startTyping();
  }

  void _loadContent() {
    if (_isStoryMode) return; // 剧情模式不需要加载事件
    final events = GameDataService.getAllEvents();
    if (widget.eventId != null) {
      _currentEvent = events.where((e) => e.id == widget.eventId).firstOrNull;
    }
    _currentEvent ??= events.isNotEmpty ? events.first : null;
  }

  void _startTyping() {
    if (_isStoryMode) {
      _displayedChars = 0;
      _isTyping = true;
      _typeNext();
      return;
    }
    if (_currentEvent == null) return;
    _displayedChars = 0;
    _isTyping = true;
    _typeNext();
  }

  void _typeNext() {
    if (!_isTyping) return;
    final totalLength = _isStoryMode
        ? (_showingEnding ? (_storyEnding?.length ?? 0) : _storyText.length)
        : (_currentEvent?.description.length ?? 0);

    if (_displayedChars < totalLength) {
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
    if (_isStoryMode) {
      return _buildStoryView();
    }
    return _buildEventView();
  }

  Widget _buildStoryView() {
    final stage = widget.stage!;
    final textToShow = _showingEnding ? (_storyEnding ?? '') : _storyText;
    final displayText = textToShow.substring(
      0,
      _displayedChars.clamp(0, textToShow.length),
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
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.accentColor.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          color: AppTheme.accentColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _showingEnding ? '剧情结束' : '主线剧情',
                              style: const TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              stage.name,
                              style: const TextStyle(
                                color: AppTheme.accentColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GameHeaderButton(
                        controlKey: const ValueKey('quest-dialog-close-button'),
                        icon: Icons.close,
                        tooltip: '关闭剧情',
                        onPressed: _onClose,
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
                // 剧情文本
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
                // 底部按钮
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      if (_isTyping)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _displayedChars = textToShow.length;
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
                      if (!_isTyping && !_showingEnding && _storyEnding != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _showEnding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                              foregroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '继续',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      if (!_isTyping &&
                          (_showingEnding || _storyEnding == null))
                        Column(
                          children: [
                            // 奖励展示
                            _buildRewardPreview(stage.rewards),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _onClose(),
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
                                  '完成',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
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

  void _showEnding() {
    setState(() {
      _showingEnding = true;
      _displayedChars = 0;
      _isTyping = true;
    });
    _typeNext();
  }

  void _onClose() {
    Navigator.of(context).pop(widget.gameSave);
  }

  Widget _buildRewardPreview(QuestReward rewards) {
    final chips = <Widget>[];
    if (rewards.coin > 0) chips.add(_rewardChip('💰', '${rewards.coin}'));
    if (rewards.grain > 0) chips.add(_rewardChip('🌾', '${rewards.grain}'));
    if (rewards.exp > 0) chips.add(_rewardChip('⭐', '${rewards.exp}'));
    if (rewards.reputation > 0) {
      chips.add(_rewardChip('🏆', '+${rewards.reputation}'));
    }
    if (chips.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '获得奖励',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 4, children: chips),
        ],
      ),
    );
  }

  Widget _rewardChip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 2),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.accentColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===== 原有事件模式 =====
  Widget _buildEventView() {
    if (_currentEvent == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('剧情')),
        body: const GamePageBackdrop(
          backgroundAsset: GameArt.worldMapBackground,
          child: Center(
            child: Text(
              '暂无剧情',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ),
        ),
      );
    }

    final event = _currentEvent!;
    final displayText = event.description.substring(
      0,
      _displayedChars.clamp(0, event.description.length),
    );

    return Scaffold(
      body: GamePageBackdrop(
        backgroundAsset: GameArt.worldMapBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  event.title,
                  style: const TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      displayText,
                      style: const TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 16,
                        height: 1.8,
                      ),
                    ),
                  ),
                ),
                if (_resultText != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _resultText!,
                      style: const TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                if (!_isTyping && _resultText == null)
                  ...event.choices.map(
                    (choice) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: _buildEventChoiceButton(choice),
                      ),
                    ),
                  ),
                if (_resultText != null)
                  Center(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(widget.gameSave),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('继续'),
                    ),
                  ),
                if (_isTyping)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _displayedChars = event.description.length;
                          _isTyping = false;
                        });
                      },
                      child: const Text(
                        '点击跳过',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventChoiceButton(EventChoice choice) {
    return GestureDetector(
      onTap: () => _selectChoice(choice),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF4A3F30)),
        ),
        child: Text(
          choice.text,
          style: const TextStyle(color: AppTheme.textColor, fontSize: 14),
        ),
      ),
    );
  }

  void _selectChoice(EventChoice choice) {
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
    });

    if (choice.triggerEventId != null) {
      widget.gameSave.completedEventIds.add(widget.eventId ?? '');
    }
  }
}
