import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // แสดง Destination ทั้งหมด ไม่ตัดเหลือแค่ 3 รายการแรกอีกต่อไป
    final featured = sampleDestinations;

    // สร้าง List ใหม่ด้วย [...sampleDestinations] ก่อน sort เพราะ sort() เป็นการ
    // เรียงแบบ in-place ถ้า sort ตัวแปรเดิม (sampleDestinations) ตรง ๆ จะไปเปลี่ยนลำดับ
    // ของ List ต้นฉบับที่หน้าอื่น (เช่น ExploreScreen) ใช้งานร่วมกันอยู่ด้วย
    // ทำให้เกิดผลข้างเคียง (side effect) ที่ไม่ตั้งใจในหน้าอื่น ๆ
    final topRated = [...sampleDestinations]
      ..sort((a, b) => b.rating.compareTo(a.rating)); // เรียงจากมากไปน้อย
    final topThree = topRated.take(3).toList();

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

              // ListView แนวนอน แสดง featured ทั้งหมด
              SizedBox(
                height: 320,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
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

              // ── Section รีวิวยอดนิยม ─────────────────────────────
              // แสดง Top 3 Destination ที่ rating สูงสุด โดยใช้ Column ครอบ ListView
              const Text('รีวิวยอดนิยม',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Column(
                children: [
                  // ListView นี้ซ้อนอยู่ใน Column ที่อยู่ใน SingleChildScrollView อีกที
                  // - shrinkWrap: true → ให้ ListView สูงเท่าที่ item รวมกันจริง แทนที่จะขยายไม่จำกัด
                  //   (ถ้าไม่ใส่ จะ Error "unbounded height" เพราะไม่รู้ว่าตัวเองควรสูงเท่าไหร่)
                  // - physics: NeverScrollableScrollPhysics() → ปิด scroll ของตัวเอง ไม่ให้ไปแย่ง
                  //   gesture กับ SingleChildScrollView ชั้นนอก ปล่อยให้ตัวนอกจัดการ scroll แทนทั้งหมด
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topThree.length,
                    itemBuilder: (context, index) {
                      final dest = topThree[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          tileColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: SizedBox(
                            width: 56,
                            height: 56,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    dest.imageUrl,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, _) => Container(
                                      width: 56,
                                      height: 56,
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                          Icons.image_not_supported,
                                          size: 20),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -2,
                                  left: -2,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade400,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 1.5),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          title: Text(dest.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(dest.country),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text('${dest.rating}'),
                            ],
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
            ],
          ),
        ),
      ),
    );
  }
}

// การ์ดแสดงสถิติตัวเลขเดียว (Trip / Country / Saved) — แยกเป็น Widget ของตัวเอง
// เพื่อลดการเขียนโค้ดซ้ำ 3 รอบใน Row ด้านบน (DRY: Don't Repeat Yourself)
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