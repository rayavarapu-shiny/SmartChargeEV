// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('landing page opens login page', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartChargeApp());

    await tester.pumpAndSettle();

    expect(find.text('Charge smarter.\nDrive greener.'), findsOneWidget);
    expect(find.text('SmartCharge EV'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);

    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('Email'), findsOneWidget);
    expect(find.text("Don't have an account? Register"), findsOneWidget);
  });
}
