import 'package:flutter/material.dart';
import '../models/destination.dart';
// ➕ เพิ่มอิมพอร์ตเอาไว้เรียกใช้ตัวจัดการข้อมูลสากล
import '../services/saved_manager.dart';

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
        // ── 1. Decoration: rounded corner + shadow ──────────────
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
        // ── 2. ClipRRect ป้องกัน Image เกิน Rounded Corner ──────
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 3. Stack: Image + Rating Badge + Save Button ────
              Stack(
                children: [
                  // 3a. รูป Destination
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

                  // 3b. ปุ่มบันทึก (หัวใจ) ยึดไว้มุมขวาบนของรูปภาพ
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StatefulBuilder(
                      // 💡 ติวทฤษฎี: ใช้ StatefulBuilder เพื่อ Rebuild สภาพของปุ่มหัวใจดวงนี้ดวงเดียวแบบ Micro-state ไม่ต้องลากตัวพ่อโหลดใหม่
                      builder: (context, cardState) {
                        final isSaved = SavedManager.instance.isSaved(
                          destination.id,
                        );
                        return CircleAvatar(
                          backgroundColor: Colors.white.withValues(alpha: 0.85),
                          radius: 18,
                          child: IconButton(
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              isSaved ? Icons.favorite : Icons.favorite_border,
                              color: isSaved
                                  ? Colors.pink
                                  : Colors.grey.shade700,
                            ),
                            onPressed: () {
                              // สั่งสลับสถานะบันทึกในถังข้อมูลสากล
                              SavedManager.instance.toggleSave(destination.id);
                              // บังคับให้ไอคอนเปลี่ยนรูปในเสี้ยววินาที
                              cardState(() {});
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // 3c. Badge Rating (ย้ายมามุมซ้ายล่างของรูป)
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
                ],
              ),
              // ── 4. Info Section ────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ชื่อและราคา
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
                    // แสดงประเทศ
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
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
                    // Tags
                    Wrap(
                      spacing: 6,
                      runSpacing:
                          6, // เพิ่ม runSpacing เผื่อกรณีขึ้นบรรทัดใหม่แล้วติดกันเกินไป
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
                                side: BorderSide(color: Colors.transparent),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    // ── เพิ่ม Row ใหม่ใต้ Tags (แสดงสถานะห้องพัก) ──
                    Row(
                      children: [
                        Icon(
                          Icons.bed,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 6),
                        // ครอบด้วย Expanded เพื่อจัดการกับ TextOverflow ในกรณีที่ String ยาวเกินขนาดจอ
                        const Expanded(
                          child: Text(
                            "พร้อมเข้าพัก",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
