// test/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elaka/screens/auth/login_screen.dart';

void main() {
  testWidgets('Login screen form validation', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    // Test form validation
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    // Test valid input
    await tester.enterText(
        find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify validation passes
    expect(find.text('Email is required'), findsNothing);
    expect(find.text('Password is required'), findsNothing);
  });
}
