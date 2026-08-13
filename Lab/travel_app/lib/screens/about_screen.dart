import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เกี่ยวกับแอป')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.travel_explore, size: 80, color: Colors.blue),
            SizedBox(height: 16),
            Text('Travel App Version 1.0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('พัฒนาด้วย Flutter & Go Router', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}