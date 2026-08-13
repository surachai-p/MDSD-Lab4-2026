import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../models/app_state.dart';
import '../widgets/destination_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บันทึกไว้')),
      // ใช้ ValueListenableBuilder คลุมทั้ง Body เพื่อให้หน้านี้รีเฟรชตัวเองตลอดเวลามีการอัปเดต
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: globalSavedIds,
        builder: (context, savedIds, child) {
          
          // ตรวจสอบ Empty State
          if (savedIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, size: 64, color: Colors.pink.shade200),
                  const SizedBox(height: 16),
                  const Text('ยังไม่มีรายการที่บันทึก', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          // กรองข้อมูล: หา Destination ที่มี ID ตรงกับใน Set ที่บันทึกไว้
          // ---------------------------------------------------------------------------
          // [จุดที่ซับซ้อนที่ 2]: การเขียน Logic กรองข้อมูล (Filtering) เพื่อนำมาแสดงผล
          // เหตุผล: ข้อมูลต้นฉบับคือ sampleDestinations ซึ่งเป็น List ของ Destination ทั้งหมด
          // แต่เราต้องการแสดงเฉพาะรายการที่ผู้ใช้บันทึกไว้ (ID อยู่ใน savedIds)
          // จึงต้องใช้ Higher-order function อย่าง .where() มาคัดกรอง 
          // โดยเช็คว่า ID ของสถานที่นั้นๆ ถูกบรรจุอยู่ใน Set ของ savedIds หรือไม่ 
          // ก่อนจะแปลงกลับเป็น List (.toList()) เพื่อส่งเข้าไปวาด GridView ต่อไป
          // ---------------------------------------------------------------------------
          final savedDestinations = sampleDestinations
              .where((d) => savedIds.contains(d.id))
              .toList();

          // สร้าง Grid แบบ Responsive
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
                crossAxisCount = 5; // Desktop
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemCount: savedDestinations.length,
                itemBuilder: (context, index) {
                  final destination = savedDestinations[index];
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