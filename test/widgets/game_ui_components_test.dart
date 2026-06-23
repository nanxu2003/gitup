import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgzb/widgets/game_action_button.dart';
import 'package:sgzb/widgets/game_atlas_cell.dart';
import 'package:sgzb/widgets/game_feature_tile.dart';
import 'package:sgzb/widgets/game_portrait.dart';
import 'package:sgzb/widgets/game_surface.dart';
import 'package:sgzb/widgets/section_header.dart';

void main() {
  testWidgets('game surface renders illustrated chrome and content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GameSurface(
            style: GameSurfaceStyle.parchment,
            child: Text('政务文书'),
          ),
        ),
      ),
    );

    expect(find.text('政务文书'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('game-surface-parchment')),
      findsOneWidget,
    );
  });

  testWidgets('feature tile uses art and remains interactive', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameFeatureTile(
            icon: GameFeatureIcon.expedition,
            title: '出征讨伐',
            subtitle: '九州征途',
            badge: '3',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('feature-icon-expedition')),
      findsOneWidget,
    );
    expect(find.text('3'), findsOneWidget);
    await tester.tap(find.text('出征讨伐'));
    expect(tapped, isTrue);
  });

  testWidgets('game action button and portrait render semantic art', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              GameActionButton(label: '挥军出征', onPressed: () {}),
              const GamePortrait(index: 5, name: '赵云'),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('game-action-primary')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('game-action-primary'))).height,
      64,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('game-action-primary')),
        matching: find.byType(GameAtlasCell),
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('general-portrait-5')), findsOneWidget);
    expect(find.text('赵云'), findsOneWidget);
  });

  testWidgets('stretchable surfaces and banners do not distort atlas cells', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(width: 320, child: GameSurface(child: Text('城池概况'))),
              SectionHeader(title: '城池政务'),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(GameAtlasCell), findsNothing);
    expect(find.text('城池概况'), findsOneWidget);
    expect(find.text('城池政务'), findsOneWidget);
  });
}
