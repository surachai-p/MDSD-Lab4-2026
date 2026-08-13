import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/screens/home_screen.dart';

void main() {
  testWidgets('home screen renders without layout errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('แนะนำสำหรับคุณ'), findsOneWidget);
    expect(find.text('รีวิวยอดนิยม'), findsOneWidget);
  });
}
