import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgzb/app/constants.dart';
import 'package:sgzb/app/game_art.dart';
import 'package:sgzb/models/chapter.dart';
import 'package:sgzb/models/game_save.dart';
import 'package:sgzb/models/player.dart';
import 'package:sgzb/screens/world_map_screen.dart';

void main() {
  testWidgets('world map presents chapters as interactive map nodes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final save = GameSave(
      player: Player(name: '玄德', identity: Identity.royal),
      chapters: [
        Chapter(
          id: 1,
          name: '黄巾乱起',
          description: '乱世序幕',
          isUnlocked: true,
          stages: [
            Stage(id: '1-1', name: '流民求援', type: StageType.story),
            Stage(id: '1-2', name: '黄巾伏击', enemyIds: ['yellow_soldier']),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp(home: WorldMapScreen(gameSave: save)));
    await tester.pumpAndSettle();

    expect(find.text('九州征途'), findsNWidgets(2));
    expect(find.byKey(const ValueKey('world-map-back-button')), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('world-map-back-button'))).dx,
      lessThan(24),
    );
    expect(
      find.byKey(const ValueKey('game-art:${GameArt.worldMapBackground}')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('game-art:${GameArt.mapGuide}')),
      findsOneWidget,
    );
    expect(find.text('流民求援'), findsOneWidget);
    expect(find.text('黄巾乱起'), findsOneWidget);
  });
}
