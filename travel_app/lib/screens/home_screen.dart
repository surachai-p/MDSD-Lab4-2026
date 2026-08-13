import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── 1. แก้ไขให้ดึงรายการทั้งหมดไปแสดงในแนวนอนตามโจทย์ ──
    final allDestinations = sampleDestinations.toList();

    // ── 2. Logic คัดสรร "รีวิวยอดนิยม" (3 อันดับแรกที่ Rating สูงสุด) ──
    // ใช้ Cascade operator (..) เพื่อ copy list มาทำการ sort จะได้ไม่ไปกระทบกับข้อมูลต้นฉบับ
    final topReviewed =
        (List<Destination>.from(sampleDestinations)..sort(
              (a, b) => b.rating.compareTo(a.rating),
            )) // เรียงจากมากไปน้อย
            .take(3)
            .toList();

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
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Text(
                        'ไปไหนดีวันนี้?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
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
                  const Text(
                    'แนะนำสำหรับคุณ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => context.go('/explore'),
                    child: const Text('ดูทั้งหมด'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ListView แนวนอน (แสดงครบทุกตัวแล้ว)
              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: allDestinations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final dest = allDestinations[index];
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
              const Text(
                'สถิติการเดินทาง',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.flight,
                      label: 'Trip',
                      value: '5',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.place,
                      label: 'Country',
                      value: '3',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.favorite,
                      label: 'Saved',
                      value: '12',
                      color: Colors.pink,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── 3. Section ใหม่: รีวิวยอดนิยม ─────────────────────
              const Text(
                'รีวิวยอดนิยม',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              /* 
               * ── [ปี 3 ติวทฤษฎีภาษามนุษย์] ทำไมต้องใช้ shrinkWrap และ NeverScrollableScrollPhysics? ──
               * 
               * ปัญหาเกิดจาก: พ่อคนนอกสุดคือ SingleChildScrollView เขาเปิดพื้นที่ให้ลูกยืดขยายแนวตั้งได้ไม่จำกัด (Infinite Height)
               * แต่พอเราใส่ ListView (แนวตั้ง) เข้าไปข้างใน นิสัยปกติของ ListView คือมันจะพยายาม "ยืดตัวเองให้สุดขอบโลก" 
               * พอ Infinite Height มาเจอกับตัวที่อยากจะยืดแบบเบรกแตก Flutter Engine จะงงทันทีว่าสรุปต้องวาดสูงเท่าไหร่ แล้วบึ้มเป็นข้อผิดพลาด (Vertical viewport was given unbounded height)
               * 
               * วิธีแก้คือ:
               * 1. ใส่ `shrinkWrap: true` เพื่อสั่งให้ ListView "หดกลับมา" เอาความสูงเท่ากับจำนวนการ์ดที่มีอยู่จริงข้างในพอ ไม่ต้องยืดเผื่อ
               * 2. ใส่ `physics: const NeverScrollableScrollPhysics()` เพื่อสั่ง "ปิดการไถหน้าจอของ ListView ตัวใน" แล้วยกหน้าที่ให้ SingleChildScrollView ตัวนอกเป็นคนพาไถทั้งหน้าจอแทน 
               *    (ถ้าไม่ใส่จะเกิดอาการ "สกรอลล์ชนกัน" ล็อกตึกๆ ตักๆ ไถไม่ไปนั่นเองครับ)
               */
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topReviewed.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final dest = topReviewed[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        dest.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      dest.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      dest.country,
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          dest.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    tileColor: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
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

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

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
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
