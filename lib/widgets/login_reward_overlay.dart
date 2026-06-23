import 'package:flutter/material.dart';

import '../app/game_art.dart';
import 'game_art_layer.dart';
import 'game_item_icon.dart';
import 'ornate_game_frame.dart';

class LoginRewardOverlay extends StatelessWidget {
  final int currentDay;
  final Set<int> claimedDays;
  final VoidCallback onClaim;
  final VoidCallback onClose;

  const LoginRewardOverlay({
    super.key,
    required this.currentDay,
    required this.claimedDays,
    required this.onClaim,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final activeDay = currentDay.clamp(1, 3);
    final isClaimed = claimedDays.contains(activeDay);
    return Scaffold(
      backgroundColor: const Color(0xFF09060A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const GameArtLayer(
            assetPath: GameArt.loginRewardBackground,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            fallback: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [
                    Color(0xFFB13B20),
                    Color(0xFF251018),
                    Color(0xFF070609),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 16,
            right: 16,
            top: 82,
            height: 485,
            child: IgnorePointer(
              child: GameArtLayer(
                assetPath: GameArt.loginLvbu,
                alignment: Alignment.topCenter,
                opacity: 0.92,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xC90A0710),
                  Color(0x19000000),
                  Color(0xEA080609),
                ],
                stops: [0, 0.5, 1],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 102,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const BrushTitle('赢在起点'),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: GameHeaderButton(
                          controlKey: const ValueKey('login-close-button'),
                          tooltip: '关闭',
                          onPressed: onClose,
                          icon: Icons.close,
                          accentColor: const Color(0xFFFFD96A),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: OrnateGameFrame(
                    accentColor: const Color(0xFFFF9E37),
                    backgroundColor: const Color(0xDB32100B),
                    padding: const EdgeInsets.fromLTRB(12, 15, 12, 15),
                    child: Column(
                      children: [
                        const Text(
                          '登录即送 · 连领三日豪礼',
                          style: TextStyle(
                            color: Color(0xFFFFE18A),
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(color: Color(0xFFFF5128), blurRadius: 12),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '每日登录即可领取 · 豪礼不间断',
                          style: TextStyle(
                            color: Color(0xFFFFC7A9),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _RewardDayCard(
                                day: 1,
                                activeDay: activeDay,
                                claimed: claimedDays.contains(1),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: _RewardDayCard(
                                day: 2,
                                activeDay: activeDay,
                                claimed: claimedDays.contains(2),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: _RewardDayCard(
                                day: 3,
                                activeDay: activeDay,
                                claimed: claimedDays.contains(3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isClaimed ? null : onClaim,
                            icon: Icon(
                              isClaimed ? Icons.check_circle : Icons.redeem,
                            ),
                            label: Text(isClaimed ? '今日已领取' : '领取今日豪礼'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB42C19),
                              disabledBackgroundColor: const Color(0xFF50423D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              side: const BorderSide(
                                color: Color(0xFFFFD16D),
                                width: 1.5,
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onClose,
                  icon: const Icon(Icons.diamond_outlined, size: 14),
                  label: const Text('稍后再来'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD7C5B7),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardDayCard extends StatelessWidget {
  final int day;
  final int activeDay;
  final bool claimed;

  const _RewardDayCard({
    required this.day,
    required this.activeDay,
    required this.claimed,
  });

  @override
  Widget build(BuildContext context) {
    final active = day == activeDay;
    final colors = [
      const Color(0xFFB63624),
      const Color(0xFFA76724),
      const Color(0xFF25747A),
    ];
    final rewardLines = [
      const ['招募令 ×1', '铜钱 ×600', '声望 +5'],
      const ['铜钱 ×1200', '粮草 ×600', '声望 +10'],
      const ['铜钱 ×2000', '粮草 ×1000', '声望 +15'],
    ];
    final color = colors[day - 1];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.fromLTRB(7, 9, 7, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: active ? 0.72 : 0.42),
        border: Border.all(
          color: active
              ? const Color(0xFFFFED9E)
              : color.withValues(alpha: 0.75),
          width: active ? 2 : 1,
        ),
        boxShadow: active ? [BoxShadow(color: color, blurRadius: 13)] : null,
      ),
      child: Column(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GameItemIcon(
                  item: switch (day) {
                    1 => GameItemArt.recruitOrder,
                    2 => GameItemArt.scroll,
                    _ => GameItemArt.crystal,
                  },
                  rarity: day == 3
                      ? GameItemRarity.legendary
                      : GameItemRarity.epic,
                  padding: const EdgeInsets.all(3),
                ),
                if (claimed)
                  const Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF61E5A2),
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ...rewardLines[day - 1].map(
            (reward) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                reward,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '登录第${_chineseDay(day)}天',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  String _chineseDay(int value) => switch (value) {
    1 => '一',
    2 => '二',
    _ => '三',
  };
}
