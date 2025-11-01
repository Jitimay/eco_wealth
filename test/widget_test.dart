import 'package:flutter_test/flutter_test.dart';

import 'package:echo_wealth/main.dart';

void main() {
  testWidgets('EchoWealth app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EchoWealthApp());

    // Verify that the app starts with loading screen
    expect(find.text('Gutegura EchoWealth...'), findsOneWidget);
  });
}
