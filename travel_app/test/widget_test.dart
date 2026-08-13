// Basic smoke test — ตรวจว่าแอปสร้าง Widget Tree ได้โดยไม่ Error
// และเห็นข้อความในหน้า Home Screen

import 'package:flutter_test/flutter_test.dart';

import 'package:travel_app/main.dart';

void main() {
  testWidgets('App builds and shows Home Screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TravelApp());
    await tester.pumpAndSettle();

    expect(find.text('ไปไหนดีวันนี้?'), findsOneWidget);
  });
}
