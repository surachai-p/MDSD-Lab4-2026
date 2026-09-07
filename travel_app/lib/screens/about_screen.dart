import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('เกี่ยวกับ')),
    body: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.travel_explore, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Travel App',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('แอปตัวอย่างสำหรับการทดลอง Flutter Layout & Navigation'),
        ],
      ),
    ),
  );
}
