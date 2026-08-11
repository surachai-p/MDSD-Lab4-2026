import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎯 Checkpoint 4.3 (ข้อ 1): แสดง sampleDestinations ทั้งหมดใน Featured ListView
    final featured = sampleDestinations;

    // 🎯 Checkpoint 4.3 (ข้อ 2): ค้นหา 3 อันดับที่มี rating สูงสุดสำหรับ section "รีวิวยอดนิยม"
    final topRated = List<Destination>.from(sampleDestinations)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final top3Rated = topRated.take(3).toList();

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

              // ListView แนวนอน แสดงรายการทั้งหมด (Checkpoint 4.3 ข้อ 1)
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
              ValueListenableBuilder<Set<String>>(
                valueListenable: savedDestinationIds,
                builder: (context, savedIds, _) {
                  return Row(
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
                            value: '${savedIds.length}',
                            color: Colors.pink),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // 🎯 Checkpoint 4.3 (ข้อ 2): เพิ่ม Section ใหม่ "รีวิวยอดนิยม" 3 อันดับแรก rating สูงสุด
              const Text('รีวิวยอดนิยม ⭐',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // 🎯 Checkpoint 4.3 (ข้อ 3) - Comment อธิบายการใช้ shrinkWrap และ NeverScrollableScrollPhysics:
              // เหตุผลที่ต้องใส่ shrinkWrap: true และ NeverScrollableScrollPhysics():
              // 1. shrinkWrap: true บังคับให้ ListView คำนวณขอบเขตความสูงตามจำนวนของ Item จริงภายใน
              //    แทนที่จะร้องขอความสูงแบบไม่จำกัด (Unbounded height) จาก Column Parent
              // 2. NeverScrollableScrollPhysics() ทำหน้าที่ปิดการทำงานการเลื่อน (Scroll) ของ ListView ตัวใน
              //    เพื่อป้องกันปัญหา Scroll Conflict และส่งต่อการเลื่อนทั้งหมดให้ SingleChildScrollView Parent ด้านนอกควบคุมเพียงผู้เดียว
              // หากไม่ใส่ จะเกิด Runtime Error "Vertical viewport was given unbounded height" หรือเกิดอาการหน้าจอกระตุกจากการ Scroll ซ้อนกัน
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: top3Rated.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final dest = top3Rated[index];
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          dest.imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, _) => Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image),
                          ),
                        ),
                      ),
                      title: Text(
                        dest.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${dest.country} • \$${dest.price}/คืน'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${dest.rating}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      onTap: () => context.pushNamed(
                        'destination-detail',
                        pathParameters: {'id': dest.id},
                        extra: dest,
                      ),
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
