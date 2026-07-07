import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_keyboard_stuck_after_app_switch/main.dart';

void main() {
  testWidgets("shows the iOS keyboard app switch controls", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KeyboardAppSwitchApp());

    expect(find.text("iOS Keyboard App Switch"), findsOneWidget);
    expect(find.text("First TextField"), findsOneWidget);
    expect(find.text("Second TextField"), findsOneWidget);

    final Finder scrollView = find.byKey(
      const ValueKey("keyboard_app_switch_scroll_view"),
    );

    await tester.drag(scrollView, const Offset(0, -360));
    await tester.pumpAndSettle();

    expect(find.text("Multiline TextField"), findsOneWidget);

    await tester.drag(scrollView, const Offset(0, -360));
    await tester.pumpAndSettle();

    expect(find.text("Call primaryFocus?.unfocus()"), findsOneWidget);
    expect(find.text("Logs"), findsOneWidget);
  });
}
