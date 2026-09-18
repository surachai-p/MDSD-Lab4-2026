import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../services/saved_store.dart';
import '../widgets/destination_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // [Checkpoint 4.3 ข้อ 1] เดิมใช้ sampleDestinations.take(3) แสดงแค่ 3 อันแรก
    // เปลี่ยนเป็นแสดง "ทั้งหมด" ใน ListView.separated แนวนอนเดิม
    final featured = sampleDestinations;

    // [Checkpoint 4.3 ข้อ 2] Logic Sort หา 3 อันดับที่ rating สูงสุด
    // ต้อง copy List ออกมาก่อนด้วย List.of(...) เพราะ sort() แก้ไข List ต้นฉบับ
    // ในที่ (in-place) ถ้า sort ทับ sampleDestinations ตรง ๆ ลำดับข้อมูลเดิม
    // ของทั้งแอป (รวมถึง Explore Screen) จะถูกสลับตามไปด้วย
    final topRated = List<Destination>.of(sampleDestinations)
      ..sort((a, b) => b.rating.compareTo(a.rating)); // มาก → น้อย
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
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'สวัสดี, นักเดินทาง! 👋',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Text(
                          'ไปไหนดีวันนี้?',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
                  // Flexible กัน Row ล้นบนจอแคบ/ฟอนต์ใหญ่
                  const Flexible(
                    child: Text(
                      'แนะนำสำหรับคุณ',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/explore'),
                    child: const Text('ดูทั้งหมด'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ListView แนวนอน
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
                  // ตัวเลข Saved ผูกกับ savedStore จริง (การทดลองที่ 8)
                  Expanded(
                    child: ListenableBuilder(
                      listenable: savedStore,
                      builder: (context, _) => _StatCard(
                        icon: Icons.favorite,
                        label: 'Saved',
                        value: '${savedStore.count}',
                        color: Colors.pink,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── [Checkpoint 4.3 ข้อ 2] Section "รีวิวยอดนิยม" ──────
              const Text(
                'รีวิวยอดนิยม',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Column ครอบ ListView แนวตั้งอีกชั้นตามโจทย์
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── [Checkpoint 4.3 ข้อ 3] ทำไมต้องใส่ shrinkWrap + NeverScrollableScrollPhysics ──
                  //
                  // ปัญหา: ListView ปกติจะ "ขอพื้นที่สูงไม่จำกัด" (infinite height)
                  // แต่ SingleChildScrollView ด้านนอกก็ส่ง Constraint ความสูงแบบ
                  // unbounded (ไม่จำกัด) ลงมาให้ลูกเช่นกัน เพราะตัวมันเองเลื่อนได้
                  // เมื่อ "ลูกขอไม่จำกัด" เจอ "พ่อให้ไม่จำกัด" Flutter คำนวณขนาดไม่ได้
                  // → แอปพังด้วย Error "Vertical viewport was given unbounded height"
                  //
                  // shrinkWrap: true  = สั่งให้ ListView วัดความสูงของลูกทุกตัวก่อน
                  //                     แล้วหดตัวเองให้พอดีเนื้อหา (ได้ความสูงที่แน่นอน)
                  // NeverScrollableScrollPhysics() = ปิดการเลื่อนของ ListView ตัวใน
                  //                     ถ้าไม่ปิด จะมีพื้นที่เลื่อนซ้อนกัน 2 ชั้น
                  //                     ทำให้ผู้ใช้ปัดแล้วสะดุด/แย่งกันเลื่อน
                  //                     ปล่อยให้ SingleChildScrollView ตัวนอกเลื่อนคนเดียว
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: top3.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final dest = top3[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.amber.shade100,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                        title: Text(dest.name),
                        subtitle: Text(dest.country),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${dest.rating}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
