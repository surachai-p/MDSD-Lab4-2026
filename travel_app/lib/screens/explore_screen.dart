import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _searchQuery =
      ''; // เก็บคำค้นหาปัจจุบัน อัปเดตทุกครั้งที่พิมพ์ใน TextField

  // Getter คำนวณรายการที่ตรงกับคำค้นหาใหม่ทุกครั้งที่ถูกเรียก
  List<Destination> get _filteredDestinations {
    if (_searchQuery.isEmpty) return sampleDestinations;
    return sampleDestinations
        .where(
          (d) =>
              d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.country.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.tags.any(
                (t) => t.toLowerCase().contains(_searchQuery.toLowerCase()),
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สำรวจ'), centerTitle: false),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'ค้นหา Destination...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── Grid หรือ Empty State ────────────────────────────────
          Expanded(
            child: _filteredDestinations.isEmpty
                ? _buildEmptyState()
                : _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    // ดึงค่าความกว้างของหน้าจอทั้งหมดผ่าน MediaQuery ตามโจทย์สั่ง
    final screenWidth = MediaQuery.of(context).size.width;

    // พิมพ์ค่าเปรียบเทียบใน Console เพื่อตรวจเช็กตอนรันโปรแกรม
    debugPrint(
      'MediaQuery width: $screenWidth | LayoutBuilder maxWidth: \${constraints.maxWidth}',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;

        // ── 1. เพิ่ม Breakpoint ระดับที่ 4 (Large) ตามเงื่อนไข ──
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2; // Compact: Phone
        } else if (constraints.maxWidth < 840) {
          crossAxisCount = 3; // Medium: Tablet Portrait
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 4; // Expanded: Tablet Landscape / Desktop ขนาดเล็ก
        } else {
          crossAxisCount =
              5; // Large: จอ Desktop ขนาดใหญ่ หรือเบราว์เซอร์กว้างๆ (≥ 1200 dp)
        }

        /* 
         * ── [ปี 3 สรุปความแตกต่างเชิงทฤษฎีภาษามนุษย์] ──
         * 1. MediaQuery.of(context).size.width จะบอก "ความกว้างของหน้าจอฮาร์ดแวร์ทั้งหมด" (Physical Screen) ไม่ว่า Widget จะอยู่ตรงไหน
         * 2. LayoutBuilder constraints.maxWidth จะบอก "พื้นที่ความกว้างสูงสุดที่ Parent เหลือให้ Widget ตัวนี้ใช้จริง" (Local Box Constraints)
         * 3. [สรุปการเลือกใช้]: ไม่จำเป็นต้องเท่ากันเสมอ (เช่น ถ้าแอปเปิดบน iPad แล้วแบ่งครึ่งหน้าจอ หรือมี Sidebar บังอยู่ ข้างขวา) 
         *    - ควรใช้ MediaQuery เมื่อต้องการเช็กสเปกเครื่องรวมๆ เช่น เช็กว่าเป็น Tablet หรือ Phone 
         *    - ควรใช้ LayoutBuilder เมื่อทำ Responsive UI ของ Component นั้นๆ เพื่อให้มันปรับตัวตามขนาดกล่องที่มันไปสิงอยู่ได้อย่างถูกต้อง
         */

        return Column(
          children: [
            // แสดงค่าเปรียบเทียบบนหน้าจอชั่วคราวให้เห็นชัดๆ ตามโจทย์สั่ง
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.amber.shade100,
              width: double.infinity,
              child: Text(
                'Screen (MediaQuery): ${screenWidth.toStringAsFixed(1)} dp | Box (LayoutBuilder): ${constraints.maxWidth.toStringAsFixed(1)} dp',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
                itemCount: _filteredDestinations.length,
                itemBuilder: (context, index) {
                  final destination = _filteredDestinations[index];
                  return DestinationCard(
                    destination: destination,
                    onTap: () {
                      context.pushNamed(
                        'destination-detail',
                        pathParameters: {'id': destination.id},
                        extra: destination,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'ไม่พบ Destination ที่ค้นหา',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            '"$_searchQuery"',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
