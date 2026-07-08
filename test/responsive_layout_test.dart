import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shortcode/core/theme/app_theme.dart';
import 'package:shortcode/features/shortcode/presentation/widgets/action_selector.dart';
import 'package:shortcode/features/shortcode/presentation/widgets/labeled_input.dart';
import 'package:shortcode/main.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Size logicalSize) async {
    tester.view.physicalSize = logicalSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ShortcodeApp());
    await tester.pumpAndSettle();
  }

  testWidgets('content column is capped and centered on tablet', (
    tester,
  ) async {
    await pumpAt(tester, const Size(1024, 1366));

    final input = tester.getRect(find.byType(LabeledInput).first);
    expect(input.width, lessThanOrEqualTo(AppLayout.maxContentWidth));
    expect(input.center.dx, moreOrLessEquals(1024 / 2, epsilon: 1));

    final tile = tester.getRect(
      find.descendant(
        of: find.byType(ActionSelector),
        matching: find.byType(Material),
      ).first,
    );
    expect(tile.height, 118);
    expect(tile.width, lessThanOrEqualTo(280));
  });

  testWidgets('phone layout still fills the usable width', (tester) async {
    await pumpAt(tester, const Size(390, 844));

    final input = tester.getRect(find.byType(LabeledInput).first);
    expect(input.width, 390 - 32);

    final tile = tester.getRect(
      find.descendant(
        of: find.byType(ActionSelector),
        matching: find.byType(Material),
      ).first,
    );
    expect(tile.height, 118);
  });
}
