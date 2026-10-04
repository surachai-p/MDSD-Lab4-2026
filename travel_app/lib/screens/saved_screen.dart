import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/favorites_manager.dart';
import '../widgets/destination_card.dart';

// หน้าแสดงรายการที่กดบันทึกไว้
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // จุดที่ 1: ใช้ ListenableBuilder คอยดูว่าถ้ามีการกดใจเพิ่มหรือลบ หน้านี้ก็จะรีเฟรชเองอัตโนมัติ
    return ListenableBuilder(
      listenable: FavoritesManager.instance,
      builder: (context, _) {
        final savedList = FavoritesManager.instance.savedDestinations;

        return Scaffold(
          appBar: AppBar(
            title: Text('บันทึกไว้ (${savedList.length})'),
          ),
          body: savedList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('ยังไม่มีรายการที่บันทึก',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : _buildGrid(context, savedList),
        );
      },
    );
  }

  // จุดที่ 2: ใช้ LayoutBuilder เช็คขนาดจอ ถ้าจอกว้างก็เพิ่มจำนวนคอลัมน์ ถ้าจอมือถือก็ 2 คอลัมน์
  Widget _buildGrid(BuildContext context, List savedList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2; // จอมือถือ
        } else if (constraints.maxWidth < 840) {
          crossAxisCount = 3; // จอแท็บเล็ต
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 4; // จอคอม
        } else {
          crossAxisCount = 5; // จอกว้างมาก
        }

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

            // จุดที่ 3: เอา DestinationCard มาใช้ซ้ำ พอกดการ์ดก็พาไปหน้า detail พร้อมส่ง id ไปด้วย
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
  }
}
