import 'package:flutter_test/flutter_test.dart';
// อิมพอร์ตไฟล์หลักของโปรเจกต์
import 'package:travel_app/main.dart';

void main() {
  testWidgets('Travel App Smoke Test', (WidgetTester tester) async {
    // 1. สั่งรันตัวแอปหลักของคุณ (ในที่นี้เปลี่ยนตามชื่อคลาสแอปจริงใน main.dart เช่น TravelApp)
    // ถ้าระบบใน main.dart ของคุณใช้ชื่ออื่น ให้เปลี่ยนคำว่า TravelApp เป็นชื่อนั้นๆ นะครับ
    await tester.pumpWidget(const TravelApp());

    // 2. ตรวจสอบว่าเปิดแอปมาแล้วเจอคำต้อนรับบน HomeScreen ไหม
    expect(find.text('ไปไหนดีวันนี้?'), findsOneWidget);

    // 3. ตรวจสอบว่ามีเมนู Bottom Navigation Bar ด้านล่างขึ้นมาครบถ้วนไหม
    expect(find.text('หน้าหลัก'), findsOneWidget);
    expect(find.text('สำรวจ'), findsOneWidget);
  });
}
