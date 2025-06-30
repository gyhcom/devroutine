// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devroutine/main.dart';

void main() {
  testWidgets('DevRoutine app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: DevRoutineApp(),
      ),
    );

    // Verify that the title is displayed
    expect(find.text('DevRoutine'), findsOneWidget);

    // Verify that the empty state message is displayed
    expect(find.text('아직 등록된 루틴이 없습니다'), findsOneWidget);
    expect(find.text('새로운 루틴을 추가해보세요'), findsOneWidget);

    // Verify that the add button is present
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
