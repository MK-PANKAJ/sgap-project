import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgap_app/main.dart';

void main() {
  testWidgets('S-GAP app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SgapApp());
    // Verify splash screen loads with brand name
    expect(find.text('S-GAP'), findsOneWidget);
  });
}
