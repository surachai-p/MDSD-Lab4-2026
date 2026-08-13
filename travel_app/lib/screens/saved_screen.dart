import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';
import '../services/saved_manager.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'รายการบันทึกไว้',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        // ── 🧠 ซับซ้อนจุดที่ 1: ใช้ ValueListenableBuilder ดักฟัง State ข้ามหน้า ──
        // เนื่องจากหน้าแต่ละหน้าถูก Freeze State ไว้บนตัวจัดการ Router
        // ตัว Builder นี้จะบังคับให้หน้า SavedScreen ตื่นขึ้นมารีเฟรชโครงสร้างใหม่ทันทีที่มีข้อมูลเปลี่ยน
        child: ValueListenableBuilder<int>(
          valueListenable: SavedManager.instance.changeNotifier,
          builder: (context, value, child) {
            // ดึง ID ทั้งหมดที่บันทึกไว้มาตรวจสอบ
            final savedIds = SavedManager.instance.savedIds;

            // กรองหา Object จากชุดข้อมูล Master ดั้งเดิมตามไอดีที่ถูกบันทึกจริง
            final savedDestinations = sampleDestinations
                .where((element) => savedIds.contains(element.id))
                .toList();

            // ── 📭 ซับซ้อนจุดที่ 2: จัดการ Empty State กรณีไม่มีข้อมูล ──
            if (savedDestinations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ยังไม่มีรายการที่บันทึกไว้',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            // ── 📱 ซับซ้อนจุดที่ 3: ใช้ LayoutBuilder ทำ Responsive Grid ──
            // คำนวณขอบเขตความกว้างสูงสุด (constraints.maxWidth) ที่ได้รับจากหน้าจอขนาดต่างๆ
            // เพื่อตัดสินใจขยายจำนวน CrossAxisCount (คอลัมน์) ไม่ให้การ์ดยืดจนเสียสัดส่วน
            return LayoutBuilder(
              builder: (context, constraints) {
                final int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedDestinations.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio:
                        0.68, // ควบคุมสัดส่วนความกว้างต่อความสูงของการ์ด
                  ),
                  itemBuilder: (context, index) {
                    final destination = savedDestinations[index];
                    return DestinationCard(
                      destination: destination,
                      // ── 🧭 ลิงก์นำทางไปยังหน้ารายละเอียดได้อย่างถูกต้อง ──
                      onTap: () => context.pushNamed(
                        'destination-detail',
                        pathParameters: {'id': destination.id},
                        extra: destination,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
