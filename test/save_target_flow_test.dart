import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shortcode/main.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ShortcodeApp());
    await tester.pumpAndSettle();
  }

  testWidgets('typing a valid number reveals bookmark; saving shows chip '
      'and verification line', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Cash In'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.bookmark_add_outlined), findsNothing);

    await tester.enterText(find.byType(TextField).first, '0772123456');
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.bookmark_add_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmark_add_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Save 0772 123 456'), findsOneWidget);

    final sheetFields = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(sheetFields.at(0), 'Tinotenda Moyo');
    await tester.enterText(sheetFields.at(1), 'Mai Tino');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Mai Tino'), findsOneWidget);
    expect(find.text('Tinotenda Moyo · “Mai Tino”'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    expect(find.text('Tinotenda Moyo · “Mai Tino”'), findsNothing);
    expect(find.text('Mai Tino'), findsOneWidget);

    await tester.tap(find.text('Mai Tino'));
    await tester.pumpAndSettle();
    expect(find.text('0772123456'), findsOneWidget);
    expect(find.text('Tinotenda Moyo · “Mai Tino”'), findsOneWidget);
  });

  testWidgets('save sheet requires a name and nickname stays optional', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField).first, '12345');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark_add_outlined));
    await tester.pumpAndSettle();

    final saveButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Save'),
    );
    expect(saveButton.onPressed, isNull);

    final sheetFields = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(sheetFields.at(0), 'Shop kiosk');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Shop kiosk'), findsNWidgets(2));
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
  });
}
