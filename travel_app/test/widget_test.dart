// Widget Test สำหรับตรวจว่าแต่ละ Checkpoint ของใบงานที่ 4 ทำงานจริง
// รันด้วย: flutter test
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_app/main.dart';
import 'package:travel_app/models/destination.dart';
import 'package:travel_app/router/app_router.dart';
import 'package:travel_app/services/saved_store.dart';
import 'package:travel_app/widgets/destination_card.dart';

/// รีเซ็ต State ที่เป็น Global ก่อนทุกเทสต์ (router + savedStore)
Future<void> _bootApp(WidgetTester tester, {String at = '/'}) async {
  for (final id in savedStore.savedIds.toList()) {
    savedStore.toggle(id);
  }
  appRouter.go(at);
  await tester.pumpWidget(const TravelApp());
  await tester.pumpAndSettle();
}

/// ตั้งขนาดหน้าจอจำลอง เพื่อทดสอบ Responsive Breakpoint
Future<void> _setScreen(WidgetTester tester, double width, double height) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('เปิดแอป: เห็น Home Screen + Bottom Nav 5 Tab (Checkpoint 5.1)',
      (tester) async {
    await _setScreen(tester, 420, 900);
    await _bootApp(tester);

    expect(find.text('ไปไหนดีวันนี้?'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    // 4 Tab เดิม + "เกี่ยวกับ" ที่เพิ่มใหม่
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('เกี่ยวกับ'), findsOneWidget);
  });

  testWidgets('Checkpoint 4.3: Featured แสดงครบทุก Destination + รีวิวยอดนิยม 3 อันดับ',
      (tester) async {
    await _setScreen(tester, 420, 900);
    await _bootApp(tester);

    // ListView แนวนอนสร้าง Item ครบ 6 ตัว (เดิม take(3) จะได้แค่ 3)
    final horizontalList = find.byType(ListView).first;
    expect(
      tester.widget<ListView>(horizontalList).semanticChildCount,
      sampleDestinations.length,
    );

    // Section รีวิวยอดนิยม: เรียง 4.9(โตเกียว) > 4.8(เชียงใหม่/สิงคโปร์)
    // SingleChildScrollView สร้างลูกทั้งหมดไว้แล้ว จึงหาเจอแม้ยังไม่ได้เลื่อนถึง
    expect(find.text('รีวิวยอดนิยม'), findsOneWidget);
    final ranks = find.byType(ListTile);
    expect(ranks, findsNWidgets(3));
    final first = tester.widget<ListTile>(ranks.first);
    expect((first.title as Text).data, 'โตเกียว'); // rating 4.9 มาเป็นอันดับ 1
  });

  testWidgets('กด Tab สำรวจ แล้วกดการ์ด → เปิดหน้า Detail ได้ (ตารางข้อ 2, 4)',
      (tester) async {
    await _setScreen(tester, 420, 900);
    await _bootApp(tester);

    await tester.tap(find.text('สำรวจ'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'สำรวจ'), findsOneWidget);

    await tester.tap(find.text('กรุงเทพฯ').first);
    await tester.pumpAndSettle();
    expect(find.text('เกี่ยวกับ'), findsWidgets); // หัวข้อ Description
    expect(find.text('จองเลย'), findsOneWidget);
  });

  testWidgets('ค้นหา "โตเกียว" เหลือผลลัพธ์เดียว (ตารางข้อ 3)', (tester) async {
    await _setScreen(tester, 420, 900);
    await _bootApp(tester, at: '/explore');

    await tester.enterText(find.byType(TextField), 'โตเกียว');
    await tester.pumpAndSettle();

    // หมายเหตุ: find.text จะเจอข้อความใน TextField ด้วย จึงเจาะหาเฉพาะในการ์ด
    expect(find.widgetWithText(DestinationCard, 'โตเกียว'), findsOneWidget);
    expect(find.text('กรุงเทพฯ'), findsNothing);
  });

  testWidgets('Checkpoint 4.1: crossAxisCount เปลี่ยนตาม M3 Breakpoint',
      (tester) async {
    Future<int> countColumns(double width) async {
      await _setScreen(tester, width, 1000);
      await _bootApp(tester, at: '/explore');
      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      return delegate.crossAxisCount;
    }

    expect(await countColumns(420), 2); // Compact
    expect(await countColumns(700), 3); // Medium
    expect(await countColumns(1000), 4); // Expanded
    expect(await countColumns(1400), 5); // Large (Checkpoint 4.1 ข้อ 1)
  });

  testWidgets('Checkpoint 5.1: Deep Link id ที่ไม่มีจริง → หน้า "ไม่พบข้อมูลที่ต้องการ"',
      (tester) async {
    await _setScreen(tester, 420, 900);
    await _bootApp(tester, at: '/explore/destinations/999');

    expect(find.text('ไม่พบข้อมูลที่ต้องการ'), findsOneWidget);
    expect(find.textContaining('999'), findsOneWidget);
    // ต้องไม่เผลอไปโชว์ตัวแรกแบบเงียบ ๆ
    expect(find.text('จองเลย'), findsNothing);
  });

  testWidgets('Checkpoint 5.1: Deep Link id ที่มีจริง → แสดงข้อมูลถูกต้อง (Fallback)',
      (tester) async {
    await _setScreen(tester, 420, 900);
    // ไม่ได้ส่ง extra มาเลย (เหมือนกรณีกด F5 บน Chrome) — ต้องค้นจาก id ได้
    await _bootApp(tester, at: '/explore/destinations/4');

    expect(find.text('โตเกียว'), findsOneWidget);
    expect(find.text('จองเลย'), findsOneWidget);
  });

  testWidgets('Checkpoint 5.1: Tab "เกี่ยวกับ" เปิด AboutScreen ได้',
      (tester) async {
    await _setScreen(tester, 420, 900);
    await _bootApp(tester);

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(find.text('Travel App'), findsOneWidget);
    expect(find.text('เวอร์ชัน 1.0.0'), findsOneWidget);
  });

  testWidgets('การทดลองที่ 8: กดหัวใจใน Explore → รายการโผล่ใน Saved Screen',
      (tester) async {
    await _setScreen(tester, 420, 900);
    await _bootApp(tester, at: '/explore');

    // ยังไม่กดหัวใจ → Saved ว่าง
    expect(savedStore.count, 0);

    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();
    expect(savedStore.count, 1);
    // ไอคอนต้องเปลี่ยนเป็นหัวใจทึบ
    expect(find.byIcon(Icons.favorite), findsWidgets);

    // สลับไป Tab บันทึก → ต้องเห็นรายการที่เพิ่งกด (State ข้ามหน้าได้)
    await tester.tap(find.text('บันทึก'));
    await tester.pumpAndSettle();
    expect(find.text('ยังไม่มีรายการที่บันทึก'), findsNothing);
    expect(find.text('กรุงเทพฯ'), findsOneWidget);
  });

  testWidgets('การทดลองที่ 8: Saved Screen ปรับ Layout ตามขนาดจอ',
      (tester) async {
    await _setScreen(tester, 420, 900);
    await _bootApp(tester, at: '/explore');
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();

    appRouter.go('/saved');
    await tester.pumpAndSettle();
    // จอแคบ → ใช้ ListView 1 คอลัมน์ ไม่มี GridView
    expect(find.byType(GridView), findsNothing);

    // ขยายจอเป็น Tablet → ต้องสลับเป็น GridView
    await _setScreen(tester, 1000, 900);
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('Saved Screen: กดการ์ดแล้วไปหน้า Detail ได้ (การทดลองที่ 8 ข้อ 4)',
      (tester) async {
    await _setScreen(tester, 420, 900);
    await _bootApp(tester, at: '/explore');
    await tester.tap(find.byIcon(Icons.favorite_border).first);
    await tester.pumpAndSettle();

    appRouter.go('/saved');
    await tester.pumpAndSettle();
    await tester.tap(find.text('กรุงเทพฯ'));
    await tester.pumpAndSettle();

    expect(find.text('จองเลย'), findsOneWidget);
  });

  testWidgets('ตารางข้อ 5-6: กด Back กลับ Explore แล้วสลับ Tab โดย Stack ไม่หาย',
      (tester) async {
    await _setScreen(tester, 420, 900);
    await _bootApp(tester, at: '/explore');

    // เข้าหน้า Detail
    await tester.tap(find.text('เชียงใหม่').first);
    await tester.pumpAndSettle();
    expect(find.text('จองเลย'), findsOneWidget);

    // ข้อ 5: กด Back → กลับมา Explore
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'สำรวจ'), findsOneWidget);

    // ข้อ 6: เข้า Detail อีกครั้ง แล้วสลับไป Tab หน้าหลัก และกลับมา
    await tester.tap(find.text('เชียงใหม่').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('หน้าหลัก'));
    await tester.pumpAndSettle();
    expect(find.text('ไปไหนดีวันนี้?'), findsOneWidget);

    await tester.tap(find.text('สำรวจ'));
    await tester.pumpAndSettle();
    // StatefulShellRoute เก็บ Stack ของ Branch ไว้ → ต้องยังอยู่หน้า Detail
    expect(find.text('จองเลย'), findsOneWidget);
  });

  testWidgets('ตารางข้อ 7: กดหัวใจบน Detail แล้วขึ้น SnackBar', (tester) async {
    await _setScreen(tester, 420, 900);
    await _bootApp(tester, at: '/explore/destinations/3');

    // ระวัง: Icons.favorite_border กับ Icons.favorite_outline คือไอคอนตัวเดียวกัน
    // ซึ่งไปชนกับไอคอน Tab "บันทึก" ด้วย จึงเจาะหาเฉพาะปุ่มที่เป็น IconButton
    await tester.tap(find.widgetWithIcon(IconButton, Icons.favorite_border));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(SnackBar, 'บันทึก ภูเก็ต แล้ว!'), findsOneWidget);
  });

  testWidgets('ตารางข้อ 8-9: กดจองเลย → Dialog → กลับหน้าหลัก', (tester) async {
    await _setScreen(tester, 420, 900);
    await _bootApp(tester, at: '/explore/destinations/5');

    await tester.ensureVisible(find.text('จองเลย'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('จองเลย'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('จองสำเร็จ! 🎉'), findsOneWidget);

    await tester.tap(find.text('กลับหน้าหลัก'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('ไปไหนดีวันนี้?'), findsOneWidget);
  });

  testWidgets('ตารางข้อ 12: เลื่อน Featured แนวนอนเห็นครบทุก Destination',
      (tester) async {
    await _setScreen(tester, 420, 900);
    await _bootApp(tester);

    // การ์ดใบสุดท้าย (สิงคโปร์) ยังไม่ถูกสร้างตอนเริ่ม เพราะอยู่นอกจอ
    // (หา widgetWithText เฉพาะในการ์ด เพราะชื่อนี้ไปโผล่ใน "รีวิวยอดนิยม" ด้วย)
    expect(find.widgetWithText(DestinationCard, 'สิงคโปร์'), findsNothing);

    await tester.drag(find.byType(ListView).first, const Offset(-1400, 0));
    await tester.pumpAndSettle();
    // ใช้ findsWidgets เพราะการ์ดสิงคโปร์มีคำว่า "สิงคโปร์" ทั้งช่องชื่อและช่องประเทศ
    expect(find.widgetWithText(DestinationCard, 'สิงคโปร์'), findsWidgets);
  });

  testWidgets('การทดลองที่ 7.1: FilterChip กรองตาม Tag ได้', (tester) async {
    await _setScreen(tester, 420, 900);
    await _bootApp(tester, at: '/explore');

    await tester.tap(find.widgetWithText(FilterChip, 'ทะเล'));
    await tester.pumpAndSettle();

    // ภูเก็ต (ทะเล) และ บาหลี (ทะเล) ต้องอยู่ / กรุงเทพฯ ต้องหายไป
    expect(find.widgetWithText(DestinationCard, 'ภูเก็ต'), findsOneWidget);
    expect(find.widgetWithText(DestinationCard, 'บาหลี'), findsOneWidget);
    expect(find.widgetWithText(DestinationCard, 'กรุงเทพฯ'), findsNothing);
  });
}
