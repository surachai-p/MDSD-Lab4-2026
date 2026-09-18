import 'package:flutter/material.dart';

/// [Checkpoint 5.1 ข้อ 1] หน้าใหม่สำหรับ Branch ที่ 5 (path: /about)
/// เป็น StatelessWidget ง่าย ๆ มีแค่ Scaffold + Text ตามโจทย์
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เกี่ยวกับ')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.travel_explore, size: 72, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'Travel App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'ใบงานการทดลองที่ 4 — Flutter Layout & Navigation\n'
                'สร้างด้วย Flutter + Go Router (StatefulShellRoute)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text('เวอร์ชัน 1.0.0', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
