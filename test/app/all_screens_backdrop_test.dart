import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every full-page game screen declares an image art layer', () {
    final screenFiles = Directory('lib/screens')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('_screen.dart'));

    final missing = <String>[];
    for (final file in screenFiles) {
      final source = file.readAsStringSync();
      if (!source.contains('GamePageBackdrop(') &&
          !source.contains('GamePageBackdrop.reading(') &&
          !source.contains('GameArtLayer(')) {
        missing.add(file.path);
      }
    }

    expect(
      missing,
      isEmpty,
      reason: 'Screens without image backgrounds: $missing',
    );
  });
}
