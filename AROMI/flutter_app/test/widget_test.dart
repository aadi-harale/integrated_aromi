import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aromi/features/auth/screens/login_screen.dart';
import 'package:aromi/app/theme.dart';

void main() {
  testWidgets('LoginScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AromiTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('AROMI'), findsWidgets);
    expect(find.text('लॉगिन करें (Login)'), findsOneWidget);
  });
}
