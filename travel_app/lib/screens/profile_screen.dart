import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('โปรไฟล์')),
    body: ListView(
      children: [
        Container(
          color: Colors.blue.shade50,
          padding: const EdgeInsets.all(24),
          child: const Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
              SizedBox(height: 12),
              Text(
                'นักศึกษา Flutter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('student@example.com', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        const ListTile(
          leading: Icon(Icons.notifications_outlined),
          title: Text('การแจ้งเตือน'),
          trailing: Icon(Icons.chevron_right),
        ),
        const ListTile(
          leading: Icon(Icons.language_outlined),
          title: Text('ภาษา'),
          trailing: Icon(Icons.chevron_right),
        ),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('เกี่ยวกับแอป'),
          trailing: Icon(Icons.chevron_right),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.logout, color: Colors.red),
          title: Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
