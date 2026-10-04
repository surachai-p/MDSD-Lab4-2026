import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เกี่ยวกับ'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.travel_explore, size: 72, color: Theme.of(context).primaryColor),
              const SizedBox(height: 16),
              const Text(
                'Travel App v1.0.0',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'แอปพลิเคชันแนะนำสถานที่ท่องเที่ยวและจัดการการเดินทาง\nสร้างขึ้นสำหรับการเรียนรู้ Flutter Layout & Navigation',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
