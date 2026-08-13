import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// แสดงเมื่อหา Destination จาก id ใน URL ไม่เจอจริง ๆ (Checkpoint 5.1.2)
// แทนที่จะเงียบ ๆ แล้วโชว์ข้อมูลของสถานที่อื่นแทนแบบเดิม (orElse: sampleDestinations.first)
class DestinationNotFoundScreen extends StatelessWidget {
  const DestinationNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ไม่พบข้อมูล')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'ไม่พบข้อมูลที่ต้องการ',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/explore'),
              child: const Text('กลับไปหน้าสำรวจ'),
            ),
          ],
        ),
      ),
    );
  }
}
