import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// [Checkpoint 5.1 ข้อ 2] หน้าที่แสดงแทน เมื่อหา id ที่ส่งมาใน URL ไม่เจอ
///
/// แทนที่จะ Fallback เงียบ ๆ ไปโชว์ sampleDestinations.first (ข้อมูลผิดตัว)
/// เราบอกผู้ใช้ตรง ๆ ว่าไม่พบข้อมูล พร้อมทางออกให้กลับไปหน้าสำรวจได้
class DestinationNotFoundScreen extends StatelessWidget {
  final String missingId;

  const DestinationNotFoundScreen({super.key, required this.missingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ไม่พบข้อมูล')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.travel_explore_outlined,
                  size: 72, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'ไม่พบข้อมูลที่ต้องการ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'ไม่มี Destination ที่มีรหัส "$missingId" อยู่ในระบบ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/explore'),
                icon: const Icon(Icons.explore),
                label: const Text('กลับไปหน้าสำรวจ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
