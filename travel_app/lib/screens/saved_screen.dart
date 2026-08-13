import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บันทึกไว้')),
      // ใช้ ValueListenableBuilder รอรับค่าจาก globalSavedIds
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: globalSavedIds,
        builder: (context, savedIds, child) {
          // ดึงข้อมูล Destination จริงๆ ออกมา โดยกรองเอาเฉพาะตัวที่มี ID ตรงกับใน savedIds
          final savedDestinations = sampleDestinations
              .where((dest) => savedIds.contains(dest.id))
              .toList();

          // แสดง Empty State หากยังไม่มีการบันทึก
          if (savedDestinations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.pink.shade200),
                  const SizedBox(height: 16),
                  const Text('ยังไม่มีรายการที่บันทึก',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          // 🎯 [Comment 3] การทำ Responsive Layout สำหรับ Saved Screen
          // นำ LayoutBuilder มาใช้คำนวณจำนวนคอลัมน์ของ Grid แบบเดียวกับ Explore Screen
          // เพื่อให้เวลากด Card เข้าไปดู Detail หรือขยายจอ การ์ดจะไม่ยืดจนพัง
          return LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              if (constraints.maxWidth < 600) {
                crossAxisCount = 2;
              } else if (constraints.maxWidth < 840) {
                crossAxisCount = 3;
              } else if (constraints.maxWidth < 1200) {
                crossAxisCount = 4;
              } else {
                crossAxisCount = 5;
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
                  final dest = savedDestinations[index];
                  return DestinationCard(
                    destination: dest,
                    onTap: () {
                      // กดแล้วไปหน้า Detail
                      context.pushNamed(
                        'destination-detail',
                        pathParameters: {'id': dest.id},
                        extra: dest,
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