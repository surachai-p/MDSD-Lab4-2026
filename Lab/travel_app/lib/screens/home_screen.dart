import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // [แก้ Checkpoint 4.3 (ข้อ 1)] เปลี่ยนให้ดึง sampleDestinations มาทั้งหมด ไม่ต้อง .take(3)
    final featured = sampleDestinations;
    
    // [เตรียมข้อมูล Checkpoint 4.3 (ข้อ 2)] เรียงลำดับ rating จากมากไปน้อย แล้วเอา 3 อันดับแรก
    final topRated = List<Destination>.from(sampleDestinations)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final top3 = topRated.take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สวัสดี, นักเดินทาง! 👋',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const Text(
                        'ไปไหนดีวันนี้?',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Featured Section ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('แนะนำสำหรับคุณ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => context.go('/explore'),
                    child: const Text('ดูทั้งหมด'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ListView แนวนอน
              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final dest = featured[index];
                    return SizedBox(
                      width: 220,
                      child: DestinationCard(
                        destination: dest,
                        onTap: () => context.pushNamed(
                          'destination-detail',
                          pathParameters: {'id': dest.id},
                          extra: dest,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── Quick Stats ─────────────────────────────────────
              const Text('สถิติการเดินทาง',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: _StatCard(
                        icon: Icons.flight,
                        label: 'Trip',
                        value: '5',
                        color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _StatCard(
                        icon: Icons.place,
                        label: 'Country',
                        value: '3',
                        color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                        icon: Icons.favorite,
                        label: 'Saved',
                        value: '12',
                        color: Colors.pink),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── [แก้ Checkpoint 4.3 (ข้อ 2 และ 3)] รีวิวยอดนิยม ──────────────────
              const Text('รีวิวยอดนิยม',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              // [คำตอบ Checkpoint 4.3 (ข้อ 3)] เหตุผลที่ต้องใส่ shrinkWrap และ NeverScrollableScrollPhysics:
              // 1. shrinkWrap: true ป้องกัน Error เรื่อง Unbounded Height เพราะ ListView ปกติจะพยายามขยายความสูงให้สุด 
              //    แต่ Column ไม่ได้กำหนดขอบเขตความสูงให้มัน การใส่ shrinkWrap จะบังคับให้ ListView ยืดความสูงเท่ากับจำนวน Item ที่มีจริงๆ
              // 2. NeverScrollableScrollPhysics() ป้องกันปัญหา Scroll ซ้อนกัน 
              //    เพื่อให้หน้าจอนี้เลื่อนขึ้นลงด้วย SingleChildScrollView ตัวหลักเพียงตัวเดียว ไม่ใช่เลื่อนข้างใน ListView แยกกัน
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: top3.length,
                itemBuilder: (context, index) {
                  final dest = top3[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(dest.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                    ),
                    title: Text(dest.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(dest.rating.toString()),
                      ],
                    ),
                    onTap: () => context.pushNamed(
                      'destination-detail',
                      pathParameters: {'id': dest.id},
                      extra: dest,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}