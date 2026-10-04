import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Checkpoint 4.3 ข้อ 1: แสดง sampleDestinations ทั้งหมด (ไม่ตัดเหลือ 3)
    final featured = sampleDestinations;

    // Checkpoint 4.3 ข้อ 2: Logic จัดเรียง Destination 3 อันดับที่ rating สูงสุด
    final topRatedDestinations = List<Destination>.from(sampleDestinations)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final top3Rated = topRatedDestinations.take(3).toList();

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

              // ListView แนวนอน แสดงทั้งหมดตาม Checkpoint 4.3 ข้อ 1
              SizedBox(
                height: 290,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
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
                  Expanded(
                    child: _StatCard(
                        icon: Icons.flight,
                        label: 'Trip',
                        value: '5',
                        color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
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

              // ── รีวิวยอดนิยม Section (Checkpoint 4.3 ข้อ 2 & 3) ──
              const Text('รีวิวยอดนิยม ⭐',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // ข้อ 3: ที่ต้องใส่ shrinkWrap: true กับ NeverScrollableScrollPhysics เพราะ ListView ซ้อนอยู่ใน SingleChildScrollView
              // ถ้าไม่ใส่ ความสูงของ ListView จะคำนวณไม่ได้จนขึ้น Error สีแดงล้นจอ และระบบเลื่อนหน้าจอจะตีกันเอง
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: top3Rated.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final dest = top3Rated[index];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        dest.imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, size: 24),
                        ),
                      ),
                    ),
                    title: Text(
                      '#${index + 1} ${dest.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${dest.country} • \$${dest.price}/คืน'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          dest.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
              const SizedBox(height: 20),
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
