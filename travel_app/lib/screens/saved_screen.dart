import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../state/saved_state.dart';
import '../widgets/destination_card.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  @override
  void initState() {
    super.initState();
    // สมัครฟัง SavedState — ทุกครั้งที่มีการ toggle หัวใจจากหน้าไหนก็ตาม
    // (Explore, Detail) เมธอด _onSavedChanged จะถูกเรียก แล้วสั่ง setState
    // ให้หน้านี้ rebuild ตัวเองใหม่ทันที โดยไม่ต้องรอให้ผู้ใช้สลับ Tab
    // ออกแล้วกลับเข้ามาใหม่ (ซึ่งเป็นคำตอบของคำถาม "ทำไม setState ที่
    // อื่นไม่ทำให้ Saved Screen รีเฟรช" — เพราะเราต้อง "สมัครฟัง" เอง
    // ผ่าน Listenable แทนที่จะหวังพึ่ง setState ของ Widget อื่น)
    SavedState.instance.addListener(_onSavedChanged);
  }

  @override
  void dispose() {
    // ต้อง removeListener เสมอตอน Widget ถูกทำลาย ไม่งั้น SavedState
    // (ซึ่งเป็น Singleton ที่มีชีวิตอยู่ตลอดทั้งแอป) จะยังถือ Reference
    // ของ Widget ที่ตายไปแล้วไว้ ทำให้เกิด Memory Leak หรือ Error ตอน
    // เรียก setState() ของ Widget ที่ unmount ไปแล้ว
    SavedState.instance.removeListener(_onSavedChanged);
    super.dispose();
  }

  void _onSavedChanged() {
    setState(() {}); // ไม่มี state ในไฟล์นี้ต้องเปลี่ยน แค่สั่งให้ build() ใหม่
  }

  @override
  Widget build(BuildContext context) {
    // ดึงรายการ Destination ที่ id อยู่ใน savedIds เท่านั้น มาแสดงผล
    final savedDestinations = sampleDestinations
        .where((d) => SavedState.instance.isSaved(d.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('บันทึกไว้')),
      body: savedDestinations.isEmpty
          ? _buildEmptyState()
          : _buildGrid(savedDestinations),
    );
  }

  Widget _buildGrid(List<Destination> items) {
    // โครงสร้าง Responsive Grid เดียวกับ ExploreScreen: ใช้ LayoutBuilder
    // อ่านความกว้างที่ Grid ได้รับจริง แล้วปรับ crossAxisCount ตาม M3
    // Window Size Classes เพื่อให้ Layout ของแอปสอดคล้องกันทุกหน้า
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final destination = items[index];
            return DestinationCard(
              destination: destination,
              onTap: () {
                // Navigation รูปแบบเดียวกับหน้าอื่น: ส่ง extra เพื่อไม่ต้อง
                // รอ Fallback หา id ใหม่ (แต่ Fallback ก็ยังทำงานได้ถ้า
                // ผู้ใช้ Refresh หน้าตรง ๆ เพราะ Router มี pathParameters
                // อยู่แล้ว)
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, size: 64, color: Colors.pink.shade200),
          const SizedBox(height: 16),
          const Text('ยังไม่มีรายการที่บันทึก',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            'กดไอคอนหัวใจที่การ์ดหรือหน้ารายละเอียดเพื่อบันทึก',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}