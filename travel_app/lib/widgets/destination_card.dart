import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../services/saved_store.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  /// [การทดลองที่ 8 ข้อ 1] เปิด/ปิดปุ่มหัวใจบนการ์ด
  final bool showSaveButton;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
    this.showSaveButton = true,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 3. Stack: Image + Rating Badge + ปุ่มหัวใจ ────
              //
              // [Checkpoint 3 ข้อ 3] ทำไม Positioned ต้องอยู่คู่กับ Stack?
              // Positioned ไม่ใช่ Widget ที่วาดอะไรเอง แต่เป็น ParentDataWidget
              // คือมันแค่แปะข้อมูลตำแหน่ง (top/left/right/bottom) ไว้ให้ Parent อ่าน
              // และมีแต่ Stack (RenderStack) เท่านั้นที่รู้จักและอ่านข้อมูลนั้นได้
              // การย้าย Badge จึงทำได้แค่เปลี่ยนตัวเลขใน Positioned เท่านั้น —
              // จาก top: 8, right: 8 (ขวาบน) เป็น bottom: 8, left: 8 (ซ้ายล่าง)
              //
              // ถ้าเอา Positioned ไปวางนอก Stack (เช่นใส่ใน Column/Padding)
              // จะไม่ใช่แค่ "ไม่ขยับ" แต่แอปจะพังทันทีตอน build ด้วย Error ว่า
              // "Incorrect use of ParentDataWidget" เพราะ Parent ตัวนั้น
              // ไม่รู้จัก StackParentData ที่ Positioned ส่งให้
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
                  // 3b. Badge Rating — [Checkpoint 3 ข้อ 1] ย้ายมามุมซ้ายล่าง
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
                  // 3c. [การทดลองที่ 8 ข้อ 1] ปุ่มหัวใจ — ย้ายมาอยู่มุมขวาบน
                  // ที่ Badge Rating เพิ่งย้ายออกไป
                  if (showSaveButton)
                    Positioned(
                      top: 4,
                      right: 4,
                      // ListenableBuilder ฟัง savedStore อยู่ตลอด พอ toggle()
                      // เรียก notifyListeners() เฉพาะปุ่มนี้จะ rebuild ใหม่
                      // (ไม่ต้อง setState ทั้งหน้า)
                      child: ListenableBuilder(
                        listenable: savedStore,
                        builder: (context, _) {
                          final isSaved = savedStore.isSaved(destination.id);
                          return Material(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => savedStore.toggle(destination.id),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  isSaved
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 18,
                                  color: isSaved ? Colors.pink : Colors.white,
                                ),
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
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 6),
                    // ── [Checkpoint 3 ข้อ 2] Row ใหม่ใต้ Tags ────────
                    // Expanded ครอบ Text ทำให้ข้อความรับความกว้าง "ที่เหลือ"
                    // หลังหักไอคอนออกไปแล้ว ถ้าข้อความยาวเกินจะถูกตัดเป็น "..."
                    // แทนที่จะดัน Row จนล้น (RenderFlex overflow แถบเหลือง-ดำ)
                    Row(
                      children: [
                        const Icon(Icons.bed, size: 14, color: Colors.teal),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'พร้อมเข้าพัก',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.teal.shade700,
                            ),
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
