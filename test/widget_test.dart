import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shortcode/main.dart';

void main() {
  testWidgets('Shortcode app renders primary flow', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ShortcodeApp());

    expect(find.text('Shortcode'), findsOneWidget);
    expect(find.text('Agent to Agent'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('USSD preview'), findsOneWidget);
    expect(find.text('Dial shortcode'), findsOneWidget);
  });
}
