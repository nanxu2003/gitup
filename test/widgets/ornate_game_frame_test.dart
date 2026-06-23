import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgzb/widgets/ornate_game_frame.dart';

void main() {
  testWidgets('ornate frame renders its title and child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrnateGameFrame(title: '乱世征途', child: Text('关卡内容')),
        ),
      ),
    );

    expect(find.text('乱世征途'), findsNWidgets(2));
    expect(find.text('关卡内容'), findsOneWidget);
  });
}
