import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../state/saved_destinations.dart';
import '../widgets/destination_card.dart';

// การทดลองที่ 8 — SavedScreen ที่ใช้งานได้จริง แสดงเฉพาะ Destination ที่ผู้ใช้บันทึกไว้
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บันทึกไว้')),
      // ListenableBuilder ฟัง SavedDestinationsController ตัวเดียวกับ DestinationCard และ
      // DestinationDetailScreen เมื่อผู้ใช้กดหัวใจจากหน้าไหนก็ตาม หน้านี้จะ rebuild ตามทันที
      // โดยไม่ต้องส่งข้อมูลผ่าน Constructor หรือ Callback ข้ามหน้าให้ยุ่งยาก
      body: ListenableBuilder(
        listenable: SavedDestinationsController.instance,
        builder: (context, _) {
          // กรอง sampleDestinations เฉพาะ id ที่อยู่ใน savedIds ของ Controller
          // ทำใหม่ทุกครั้งที่ build เพื่อให้ผลลัพธ์ตรงกับ State ล่าสุดเสมอ ไม่ต้องเก็บ Cache ซ้ำ
          final savedDestinations = sampleDestinations
              .where((d) =>
                  SavedDestinationsController.instance.isSaved(d.id))
              .toList();

          if (savedDestinations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, size: 64, color: Colors.pink.shade200),
                  const SizedBox(height: 16),
                  const Text('ยังไม่มีรายการที่บันทึก',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          // ปรับจำนวนคอลัมน์ตามความกว้างหน้าจอ แบบเดียวกับ ExploreScreen (M3 Breakpoints)
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    );
  }
}
