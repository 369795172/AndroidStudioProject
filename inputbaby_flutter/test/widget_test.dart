// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  testWidgets('InputBabyApp widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const InputBabyApp());

    // Verify that our Flutter app is working - look for video home page content
    // The app should show some video-related content or at least load without errors
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Let the app fully render
    await tester.pumpAndSettle();
    
    // Since our app navigates to the video home page, check if it rendered successfully
    // This test mainly verifies the app can start without crashing
    expect(tester.allWidgets.isNotEmpty, true);
  });
}
