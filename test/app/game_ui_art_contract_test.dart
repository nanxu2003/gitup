import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sgzb/app/game_ui_art.dart';

void main() {
  test('game UI art contract has four semantic sheets', () {
    expect(GameUiArt.all, hasLength(4));
    expect(GameUiArt.all.toSet(), hasLength(4));
    expect(GameUiArt.uiChrome, contains('/ui/'));
    expect(GameUiArt.featureIcons, contains('/icons/'));
    expect(GameUiArt.buildingTiles, contains('/buildings/'));
    expect(GameUiArt.generalPortraits, contains('/portraits/'));
  });

  test('every game UI art sheet exists', () {
    for (final path in GameUiArt.all) {
      expect(File(path).existsSync(), isTrue, reason: 'Missing asset: $path');
    }
  });
}
