import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sgzb/app/game_art.dart';

void main() {
  test('modular game art uses semantic non-reference asset paths', () {
    final paths = GameArt.all;

    expect(paths, hasLength(11));
    expect(paths.toSet(), hasLength(paths.length));
    expect(paths, everyElement(startsWith('assets/images/')));
    expect(paths, everyElement(isNot(contains('_reference.png'))));
    expect(paths.where((path) => path.contains('/backgrounds/')), hasLength(4));
    expect(paths.where((path) => path.contains('/characters/')), hasLength(6));
    expect(paths.where((path) => path.contains('/items/')), hasLength(1));
  });

  test('every modular game art file exists', () {
    for (final path in GameArt.all) {
      expect(File(path).existsSync(), isTrue, reason: 'Missing asset: $path');
    }
  });

  test('full-screen reference screenshots are absent from runtime', () {
    const references = [
      'assets/images/world_map_reference.png',
      'assets/images/battle_reference.png',
      'assets/images/recruit_reference.png',
      'assets/images/login_reward_reference.png',
    ];
    for (final path in references) {
      expect(File(path).existsSync(), isFalse, reason: 'Remove $path');
    }

    final runtimeSources = <String>[
      ...Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .map((file) => file.readAsStringSync()),
      File('pubspec.yaml').readAsStringSync(),
    ].join('\n');
    expect(runtimeSources, isNot(contains('_reference.png')));
  });

  test('key reward and recruitment UI has no recharge language', () {
    final uiSources = [
      File('lib/screens/recruit_screen.dart').readAsStringSync(),
      File('lib/widgets/login_reward_overlay.dart').readAsStringSync(),
    ].join('\n');

    for (final word in ['充值', '首充', '付费']) {
      expect(uiSources, isNot(contains(word)));
    }
  });
}
