import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgzb/app/constants.dart';
import 'package:sgzb/app/game_art.dart';
import 'package:sgzb/models/game_save.dart';
import 'package:sgzb/models/general.dart';
import 'package:sgzb/models/player.dart';
import 'package:sgzb/screens/battle_screen.dart';

void main() {
  testWidgets('battle uses the image-backed formation presentation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final hero = General(
      id: 'zhaoyun',
      name: '赵云',
      isDeployed: true,
      attributes: GeneralAttributes(
        force: 95,
        intelligence: 70,
        command: 88,
        politics: 60,
        charm: 85,
        speed: 99,
      ),
    );
    final save = GameSave(
      player: Player(name: '玄德', identity: Identity.royal),
      generals: [hero],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BattleScreen(
          gameSave: save,
          enemyIds: const ['missing_enemy'],
          stageId: '1-2',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('战火争锋'), findsNWidgets(2));
    expect(find.byKey(const ValueKey('battle-close-button')), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('battle-close-button'))).dx,
      lessThan(24),
    );
    expect(
      find.byKey(const ValueKey('game-art:${GameArt.battlefieldBackground}')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('game-art:${GameArt.battleHero}')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('game-art:${GameArt.battleRival}')),
      findsOneWidget,
    );
    expect(find.text('敌军阵列'), findsOneWidget);
    expect(find.text('我军阵列'), findsOneWidget);
    expect(find.text('赵云'), findsOneWidget);
  });
}
