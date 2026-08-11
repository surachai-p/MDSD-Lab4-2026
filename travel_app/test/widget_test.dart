// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travel_app/main.dart';

void main() {
  testWidgets('Travel app loads Home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TravelApp());
    await tester.pumpAndSettle();

    // ตรวจว่าแอปโหลดขึ้นมาโดยไม่ crash และเจอข้อความทักทายในหน้า Home
    expect(find.text('ไปไหนดีวันนี้?'), findsOneWidget);

    // ตรวจว่ามี Bottom Navigation Bar ครบ 5 แท็บ (Home, Explore, Saved, Profile, About)
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}