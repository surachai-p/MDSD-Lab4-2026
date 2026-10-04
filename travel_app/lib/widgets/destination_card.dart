import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/favorites_manager.dart';

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
              // ── 3. Stack: Image + Rating Badge ────────────────
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
                  // ย้าย Rating Badge มาไว้มุมล่างซ้ายตาม Checkpoint 3
                  // ข้อ 3: ที่ต้องใช้ Positioned ใน Stack เพราะ Positioned ใช้กำหนดพิกัดใน Stack เท่านั้น ถ้าเอาไปใช้นอก Stack โปรแกรมจะ Error ทันที
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
                  // 3c. การทดลองที่ 8 ข้อ 1: ปุ่มบันทึกรายการ (Heart Icon) ที่มุมขวาบนของการ์ด
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ListenableBuilder(
                      listenable: FavoritesManager.instance,
                      builder: (context, _) {
                        final isSaved =
                            FavoritesManager.instance.isSaved(destination.id);
                        return GestureDetector(
                          onTap: () {
                            FavoritesManager.instance.toggleSave(destination.id);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isSaved
                                    ? 'นำ ${destination.name} ออกจากรายการที่บันทึกแล้ว'
                                    : 'บันทึก ${destination.name} แล้ว! ❤️'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved ? Icons.favorite : Icons.favorite_border,
                              color: isSaved ? Colors.pinkAccent : Colors.white,
                              size: 18,
                            ),
                          ),
                        );
                      },
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
                    // Tags
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
                                  side: BorderSide(color: Colors.transparent)),
                              padding: EdgeInsets.zero,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    // Checkpoint 3 ข้อ 2: เพิ่ม Row แสดงไอคอน Icons.bed พร้อมข้อความ "พร้อมเข้าพัก"
                    Row(
                      children: const [
                        Icon(Icons.bed, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'พร้อมเข้าพัก',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
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
