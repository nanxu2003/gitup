import 'package:flutter/material.dart';
import '../app/app_theme.dart';
import '../app/constants.dart';
import '../app/game_art.dart';
import '../models/player.dart';
import '../models/general.dart';
import '../models/game_save.dart';
import '../services/game_data_service.dart';
import '../services/save_service.dart';
import '../widgets/styled_button.dart';
import '../widgets/game_backdrop_scaffold.dart';

class CreatePlayerScreen extends StatefulWidget {
  final SaveService saveService;

  const CreatePlayerScreen({super.key, required this.saveService});

  @override
  State<CreatePlayerScreen> createState() => _CreatePlayerScreenState();
}

class _CreatePlayerScreenState extends State<CreatePlayerScreen> {
  final _nameController = TextEditingController();
  Identity? _selectedIdentity;
  bool _hasName = false;

  @override
  void initState() {
    super.initState();
    // 监听名字输入框变化，触发重建以更新按钮状态
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final hasName = _nameController.text.trim().isNotEmpty;
    if (hasName != _hasName) {
      setState(() => _hasName = hasName);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  bool get _canStart => _selectedIdentity != null && _hasName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('开创新的乱世')),
      body: GamePageBackdrop(
        backgroundAsset: GameArt.recruitHallBackground,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 名字输入区
              const Text(
                '主公姓名',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '为你的主公取一个响亮的名字',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
                maxLength: 8,
                decoration: InputDecoration(
                  hintText: '请输入名字（如：刘玄、赵勇）',
                  hintStyle: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                  counterText: '',
                  prefixIcon: const Icon(
                    Icons.person,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF4A3F30)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _hasName
                          ? AppTheme.accentColor.withValues(alpha: 0.5)
                          : const Color(0xFF4A3F30),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppTheme.accentColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              if (!_hasName)
                const Padding(
                  padding: EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    '⚠ 请输入名字后才能开始征战',
                    style: TextStyle(color: Colors.orange, fontSize: 11),
                  ),
                ),

              const SizedBox(height: 24),

              // 身份选择区
              const Text(
                '选择身份',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '不同身份有不同的初始加成和发展路线',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              if (_selectedIdentity == null)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    '⚠ 请选择一个身份',
                    style: TextStyle(color: Colors.orange, fontSize: 11),
                  ),
                ),
              const SizedBox(height: 12),
              ...Identity.values.map((id) => _buildIdentityCard(id)),
              const SizedBox(height: 24),

              // 开始按钮
              Center(
                child: Column(
                  children: [
                    StyledButton(
                      text: '开始征战',
                      icon: Icons.flag,
                      width: 200,
                      onPressed: _canStart ? _createPlayer : null,
                    ),
                    const SizedBox(height: 8),
                    if (!_canStart)
                      Text(
                        _getDisabledHint(),
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getDisabledHint() {
    if (!_hasName && _selectedIdentity == null) return '请输入名字并选择身份';
    if (!_hasName) return '请输入主公名字';
    return '请选择一个身份';
  }

  Widget _buildIdentityCard(Identity id) {
    final isSelected = _selectedIdentity == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedIdentity = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentColor.withValues(alpha: 0.15)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : const Color(0xFF4A3F30),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentColor.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _identityIcon(id),
                color: isSelected
                    ? AppTheme.accentColor
                    : AppTheme.textSecondaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    identityNames[id] ?? '',
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.accentColor
                          : AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    identityDescriptions[id] ?? '',
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppTheme.accentColor,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _identityIcon(Identity id) {
    switch (id) {
      case Identity.royal:
        return Icons.workspace_premium;
      case Identity.warrior:
        return Icons.shield;
      case Identity.scholar:
        return Icons.auto_stories;
      case Identity.merchant:
        return Icons.monetization_on;
    }
  }

  Future<void> _createPlayer() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedIdentity == null) return;

    final player = Player.createWithIdentity(_selectedIdentity!, name);

    final save = GameSave(
      player: player,
      buildings: GameDataService.getDefaultBuildings(),
      generals: [
        General.fromJson(
          GameDataService.getAllGenerals()
              .firstWhere((g) => g.id == 'zhaoyun')
              .toJson(),
        ),
      ],
      inventory: GameDataService.getDefaultItems(),
      quests: GameDataService.getInitialQuests(),
      formations: GameDataService.getDefaultFormations(),
      chapters: GameDataService.getAllChapters(),
    );

    await widget.saveService.autoSave(save);

    if (mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/home', (r) => false, arguments: save);
    }
  }
}
