import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgzb/app/game_art.dart';
import 'package:sgzb/widgets/login_reward_overlay.dart';

void main() {
  testWidgets('login reward shows three days and claims the current day', (
    tester,
  ) async {
    var claimed = false;
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: LoginRewardOverlay(
          currentDay: 1,
          claimedDays: const {},
          onClaim: () => claimed = true,
          onClose: () {},
        ),
      ),
    );

    expect(find.text('赢在起点'), findsNWidgets(2));
    expect(find.byKey(const ValueKey('login-close-button')), findsOneWidget);
    expect(
      tester.getTopRight(find.byKey(const ValueKey('login-close-button'))).dx,
      greaterThan(406),
    );
    expect(
      find.byKey(const ValueKey('game-art:${GameArt.loginRewardBackground}')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('game-art:${GameArt.loginLvbu}')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('item-atlas-recruitOrder')),
      findsOneWidget,
    );
    expect(find.text('登录即送 · 连领三日豪礼'), findsOneWidget);
    expect(find.textContaining('充值'), findsNothing);
    expect(find.textContaining('首充'), findsNothing);
    expect(find.text('登录第一天'), findsOneWidget);
    expect(find.text('登录第二天'), findsOneWidget);
    expect(find.text('登录第三天'), findsOneWidget);

    await tester.tap(find.text('领取今日豪礼'));
    expect(claimed, isTrue);
  });
}
