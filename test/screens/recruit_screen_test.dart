import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgzb/app/constants.dart';
import 'package:sgzb/app/game_art.dart';
import 'package:sgzb/models/game_save.dart';
import 'package:sgzb/models/player.dart';
import 'package:sgzb/screens/recruit_screen.dart';

void main() {
  testWidgets('recruitment presents four featured candidates', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final save = GameSave(
      player: Player(
        name: '玄德',
        identity: Identity.royal,
        resources: {'coin': 30000, 'grain': 5000},
      ),
    );

    await tester.pumpWidget(MaterialApp(home: RecruitScreen(gameSave: save)));
    await tester.pump();

    expect(find.text('神将自选'), findsNWidgets(2));
    expect(
      find.byKey(const ValueKey('game-art:${GameArt.recruitHallBackground}')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('game-art:${GameArt.recruitLady}')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('game-art:${GameArt.recruitWarrior}')),
      findsOneWidget,
    );
    expect(find.text('英雄集结 · 千抽自选'), findsOneWidget);
    expect(find.text('张飞'), findsOneWidget);
    expect(find.text('刘备'), findsOneWidget);
    expect(find.text('周瑜'), findsOneWidget);
    expect(find.text('曹操'), findsOneWidget);
    expect(find.byKey(const ValueKey('recruit-back-button')), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('recruit-back-button'))).dx,
      lessThan(24),
    );
    for (final id in ['zhangfei', 'liubei', 'zhouyu', 'caocao']) {
      expect(find.byKey(ValueKey('featured-portrait-$id')), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('summon-button-招募一次')), findsOneWidget);
    expect(find.byKey(const ValueKey('summon-button-神将十连')), findsOneWidget);
    expect(find.textContaining('充值'), findsNothing);
    expect(find.textContaining('首充'), findsNothing);
  });
}
