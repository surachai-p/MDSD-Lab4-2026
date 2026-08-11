import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';

// 🎯 Checkpoint 8 (Independent Challenge): หน้าแสดงรายการสถานที่ที่ถูกบันทึกไว้จริง
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายการที่บันทึกไว้')),

      // 💡 Comment Checkpoint 8 จุดที่ 1:
      // ใช้ ValueListenableBuilder คอยดักรับความเปลี่ยนแปลงจากตัวแปร savedDestinationIds (ValueNotifier)
      // เมื่อผู้ใช้กดสลับสถานะหัวใจในหน้า Home, Explore หรือ Detail Widget ตัวนี้จะ Rebuild โดยอัตโนมัติ
      // ทำให้ UI อัปเดตข้อมูลสถานที่บันทึกตรงกันแบบ Real-time โดยไม่ต้องพึ่ง State Management Package ภายนอก
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: savedDestinationIds,
        builder: (context, savedIds, _) {
          // ดึงเฉพาะรายการที่ ID อยู่ใน savedIds
          final savedList = sampleDestinations
              .where((d) => savedIds.contains(d.id))
              .toList();

          if (savedList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: Colors.pink.shade200),
                  const SizedBox(height: 16),
                  const Text(
                    'ยังไม่มีรายการที่บันทึกไว้',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.go('/explore'),
                    child: const Text('สำรวจสถานที่ท่องเที่ยวน่าสนใจ'),
                  ),
                ],
              ),
            );
          }

          // 💡 Comment Checkpoint 8 จุดที่ 2:
          // ใช้ LayoutBuilder ในการทำ Responsive Grid ตามขนาดความกว้างหน้าจอ (Material Design 3 Window Size Classes)
          // เช่นเดียวกับ ExploreScreen เพื่อให้การแสดงผลบน Phone, Tablet และ Desktop มีความสวยงามสมส่วน
          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              if (constraints.maxWidth < 600) {
                crossAxisCount = 2; // Phone
              } else if (constraints.maxWidth < 840) {
                crossAxisCount = 3; // Tablet Portrait
              } else if (constraints.maxWidth < 1200) {
                crossAxisCount = 4; // Tablet Landscape
              } else {
                crossAxisCount = 5; // Desktop Large Screen
              }

              // 💡 Comment Checkpoint 8 จุดที่ 3:
              // ใช้ GridView.builder ร่วมกับ DestinationCard ที่สร้างไว้ และรองรับการกดเปิดดูรายละเอียดผ่าน
              // Go Router pushNamed โดยส่ง ID ผ่าน pathParameters และ Object ผ่าน extra เพื่อการนำทางที่สมบูรณ์
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemCount: savedList.length,
                itemBuilder: (context, index) {
                  final destination = savedList[index];
                  return DestinationCard(
                    destination: destination,
                    onTap: () {
                      context.pushNamed(
                        'destination-detail',
                        pathParameters: {'id': destination.id},
                        extra: destination,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
