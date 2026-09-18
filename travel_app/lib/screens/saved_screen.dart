import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../services/saved_store.dart';
import '../widgets/destination_card.dart';

/// [การทดลองที่ 8] หน้า "บันทึกไว้" ที่ใช้งานได้จริง
///
/// COMMENT (จุดซับซ้อนที่ 1): ทำไมทั้งหน้าถูกครอบด้วย ListenableBuilder?
/// หน้านี้เป็น Branch หนึ่งของ StatefulShellRoute.indexedStack ซึ่ง "ไม่ถูกทำลาย"
/// เวลาสลับ Tab (Keep-Alive) — แปลว่า build() จะไม่ถูกเรียกใหม่เองตอนกลับมา
/// ถ้าไปกดหัวใจที่หน้า Explore แล้วสลับมา Tab นี้ รายการจะยังเป็นของเก่า
/// การครอบด้วย ListenableBuilder ทำให้หน้านี้ rebuild ทุกครั้งที่ savedStore
/// เรียก notifyListeners() ไม่ว่าจะถูกกดมาจากหน้าไหนก็ตาม
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บันทึกไว้')),
      body: ListenableBuilder(
        listenable: savedStore,
        builder: (context, _) {
          // COMMENT (จุดซับซ้อนที่ 2): เก็บใน Store แค่ Set<String> ของ id
          // ไม่ได้เก็บ Object Destination ทั้งก้อน เพื่อไม่ให้ข้อมูลซ้ำซ้อน
          // (Single Source of Truth อยู่ที่ sampleDestinations ที่เดียว)
          // ตรงนี้จึงต้อง map id กลับเป็น Object ก่อนนำไปแสดง
          // .whereType<Destination>() คือการกรอง null ทิ้ง พร้อมเปลี่ยนชนิดของ
          // List จาก List<Destination?> เป็น List<Destination> ในขั้นตอนเดียว
          final saved = savedStore.savedIds
              .map(findDestinationById)
              .whereType<Destination>()
              .toList();

          if (saved.isEmpty) return _buildEmptyState(context);

          // COMMENT (จุดซับซ้อนที่ 3): ใช้ LayoutBuilder เลือก Layout 2 แบบ
          // จอ Compact (< 600 dp) เนื้อที่แนวนอนน้อย → ใช้ ListView 1 คอลัมน์
          // จอกว้างขึ้น → ใช้ GridView และเพิ่มจำนวนคอลัมน์ตาม M3 Breakpoint
          // เหมือนที่ทำใน Explore Screen
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              if (width < 600) {
                return _buildList(context, saved);
              }
              final crossAxisCount = width < 840
                  ? 3
                  : width < 1200
                      ? 4
                      : 5;
              return _buildGrid(context, saved, crossAxisCount);
            },
          );
        },
      ),
    );
  }

  /// เปิดหน้ารายละเอียด — ใช้ Named Route แบบเดียวกับหน้าอื่นทั้งแอป
  void _openDetail(BuildContext context, Destination d) {
    context.pushNamed(
      'destination-detail',
      pathParameters: {'id': d.id},
      extra: d,
    );
  }

  Widget _buildList(BuildContext context, List<Destination> saved) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: saved.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final d = saved[index];
        return _SavedListTile(
          destination: d,
          onTap: () => _openDetail(context, d),
        );
      },
    );
  }

  Widget _buildGrid(
      BuildContext context, List<Destination> saved, int crossAxisCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.62,
      ),
      itemCount: saved.length,
      itemBuilder: (context, index) {
        final d = saved[index];
        return DestinationCard(
          destination: d,
          onTap: () => _openDetail(context, d),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, size: 64, color: Colors.pink.shade200),
          const SizedBox(height: 16),
          const Text('ยังไม่มีรายการที่บันทึก',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('กดรูปหัวใจบนการ์ดในหน้า "สำรวจ" เพื่อบันทึกไว้ที่นี่',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () => context.go('/explore'),
            icon: const Icon(Icons.explore),
            label: const Text('ไปหน้าสำรวจ'),
          ),
        ],
      ),
    );
  }
}

/// การ์ดแนวนอนสำหรับ Layout แบบ List บนจอ Compact
/// ใช้ Row + Expanded เพื่อให้รูปกว้างคงที่ ส่วนข้อความยืดตามพื้นที่ที่เหลือ
class _SavedListTile extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const _SavedListTile({required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                height: 100,
                child: Image.network(
                  destination.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, _) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        destination.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              destination.country,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.star,
                              size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text('${destination.rating}',
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${destination.price}/คืน',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
              // ปุ่มเอาออกจากรายการบันทึก (toggle ตัวเดียวกับหน้าอื่น)
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.pink),
                tooltip: 'นำออกจากรายการบันทึก',
                onPressed: () => savedStore.toggle(destination.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
