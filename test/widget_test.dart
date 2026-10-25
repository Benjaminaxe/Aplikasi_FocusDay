import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aplikasi_focusday/main.dart';

void main() {
  testWidgets('FocusDay app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FocusDayApp(),
      ),
    );

    // Verify app title or branding appears
    expect(find.text('FocusDay'), findsOneWidget);
  });
}
