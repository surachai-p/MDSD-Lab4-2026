import 'package:flutter/material.dart';

// AboutScreen (Checkpoint 5.1) — Branch ใหม่ตัวที่ 5 ใน Bottom Navigation
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
              Icon(Icons.flight_takeoff, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'Travel App',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'แอปตัวอย่างสำหรับใบงานการทดลองที่ 4\n'
                'Flutter Layout & Navigation — Multi-Screen Travel App',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
