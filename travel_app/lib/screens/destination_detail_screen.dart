import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../services/saved_store.dart';

class DestinationDetailScreen extends StatelessWidget {
  final Destination destination;

  const DestinationDetailScreen({
    super.key,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: ทำให้ Body ขยายใต้ AppBar (Hero Effect)
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            // ถ้า Stack ว่าง (เช่นเปิดจาก Deep Link ตรง ๆ) จะ pop ไม่ได้
            // ต้อง go กลับไปหน้า Explore แทน ไม่งั้นแอปจะค้าง
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/explore');
            }
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        actions: [
          // ── [การทดลองที่ 8 ข้อ 1] ปุ่มหัวใจสลับสถานะบันทึก ──────
          // ListenableBuilder ฟัง savedStore ตัวเดียวกับที่ DestinationCard ฟัง
          // กดที่นี่ → ไอคอนบนการ์ดใน Explore และรายการใน Saved อัปเดตตามทันที
          ListenableBuilder(
            listenable: savedStore,
            builder: (context, _) {
              final isSaved = savedStore.isSaved(destination.id);
              return Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: isSaved ? Colors.pink : Colors.white,
                  ),
                  onPressed: () {
                    savedStore.toggle(destination.id);
                    final nowSaved = savedStore.isSaved(destination.id);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(nowSaved
                              ? 'บันทึก ${destination.name} แล้ว!'
                              : 'นำ ${destination.name} ออกจากรายการบันทึกแล้ว'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image ──────────────────────────────────────────
            Stack(
              children: [
                // รูป Destination
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Image.network(
                    destination.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, _) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, size: 64),
                    ),
                  ),
                ),
                // Gradient Overlay สำหรับ Text ด้านล่างรูป
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                  ),
                ),
                // ชื่อ Destination ทับบน Gradient
                Positioned(
                  bottom: 16,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            destination.country,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Info Section ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating และ Price Row
                  Row(
                    children: [
                      // Rating
                      _InfoChip(
                        icon: Icons.star,
                        iconColor: Colors.amber,
                        label: '${destination.rating}',
                        subtitle: 'Rating',
                      ),
                      const SizedBox(width: 16),
                      // Price
                      _InfoChip(
                        icon: Icons.attach_money,
                        iconColor: Colors.green,
                        label: '\$${destination.price}',
                        subtitle: 'ต่อคืน',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'เกี่ยวกับ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    destination.description,
                    style: const TextStyle(
                        fontSize: 15, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),

                  // Tags
                  const Text(
                    'สิ่งที่น่าสนใจ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: destination.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(tag,
                                style: TextStyle(color: Colors.blue.shade700)),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // showDialog เปิด Popup แบบ Modal (บล็อกหน้าจอด้านหลังจนกว่าจะปิด)
                        // ใช้ context ปัจจุบันเป็นตัวอ้างอิงตำแหน่งของ Navigator
                        showDialog(
                          context: context,
                          // รับ context ของ Dialog เอง (dialogContext) มาใช้
                          //
                          // ข้อควรระวัง: showDialog วาง Dialog ไว้บน "root Navigator"
                          // แต่หน้า Detail นี้อยู่ใน Navigator ของ Shell Branch
                          // ถ้าเขียน Navigator.pop(context) โดยใช้ context ของหน้า
                          // Flutter จะไล่หา Navigator ที่ใกล้ที่สุด = Navigator ของ
                          // Branch → กลายเป็นปิดหน้า Detail ทิ้ง ส่วน Dialog ยังค้างอยู่
                          // ต้องใช้ dialogContext เพื่อให้ pop ตัว Dialog ได้ถูกตัว
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('จองสำเร็จ! 🎉'),
                            content: Text(
                                'คุณได้จอง ${destination.name} เรียบร้อยแล้ว'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // ปิด Dialog ก่อน แล้วค่อย context.go('/')
                                  // เพื่อกลับไปหน้า Home ผ่าน Go Router
                                  Navigator.pop(dialogContext);
                                  context.go('/');
                                },
                                child: const Text('กลับหน้าหลัก'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.flight_takeoff),
                      label: const Text('จองเลย',
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Info Chip Widget — ขึ้นต้นด้วย _ (underscore) แปลว่าเป็น Private Class
// ใช้ได้แค่ภายในไฟล์นี้เท่านั้น เหมาะกับ Widget เล็ก ๆ ที่ใช้ซ้ำแค่ในหน้านี้
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;

  const _InfoChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
