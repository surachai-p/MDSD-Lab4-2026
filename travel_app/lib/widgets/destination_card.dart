import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../state/saved_state.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

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
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      destination.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, _) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, size: 48),
                      ),
                    ),
                  ),
                  // Badge Rating (Checkpoint 3: ย้ายมาซ้ายล่างแล้ว)
                  // ต้องใช้ Positioned คู่กับ Stack เท่านั้น เพราะ Stack คือ
                  // Layout เดียวที่รองรับการวาง Widget ซ้อนทับกันแบบอิสระ
                  // (แกน Z) หากเอา Positioned ไปวางนอก Stack จะ Error ทันที
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            destination.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ── การทดลองที่ 8 ข้อ 1: ปุ่มหัวใจมุมขวาบน ──────────
                  // ใช้ AnimatedBuilder ครอบเฉพาะไอคอนหัวใจ (ไม่ครอบทั้งการ์ด)
                  // เพื่อให้ rebuild เฉพาะส่วนเล็ก ๆ นี้เวลาข้อมูลใน
                  // SavedState เปลี่ยน ไม่ต้อง rebuild รูปภาพ/ข้อความทั้งการ์ด
                  // ซ้ำ ๆ ทุกครั้งที่กด (ประหยัด performance)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedBuilder(
                      animation: SavedState.instance,
                      builder: (context, _) {
                        final saved = SavedState.instance.isSaved(destination.id);
                        return GestureDetector(
                          // ใช้ GestureDetector ซ้อนใน GestureDetector ใหญ่ได้
                          // (Flutter จะจัดการ Hit-test ให้ event ของปุ่มเล็ก
                          // ทำงานก่อน ไม่ลอดไปโดน onTap ของการ์ดทั้งใบ)
                          onTap: () => SavedState.instance.toggle(destination.id),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              saved ? Icons.favorite : Icons.favorite_border,
                              color: saved ? Colors.redAccent : Colors.white,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              destination.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '\$${destination.price}/คืน',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                            destination.country,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: destination.tags
                            .map(
                              (tag) => Chip(
                                label: Text(
                                  tag,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                backgroundColor: Colors.blue.shade50,
                                shape: const StadiumBorder(
                                    side:
                                        BorderSide(color: Colors.transparent)),
                                padding: EdgeInsets.zero,
                              ),
                            )
                            .toList(),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.bed, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'พร้อมเข้าพัก',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}