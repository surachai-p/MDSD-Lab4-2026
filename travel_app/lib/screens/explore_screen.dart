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
  String _searchQuery = ''; // เก็บคำค้นหาปัจจุบัน อัปเดตทุกครั้งที่พิมพ์ใน TextField

  // ── [การทดลองที่ 7.1] Category Filter ──────────────────────────
  String _selectedTag = 'ทั้งหมด';
  final List<String> _allTags = [
    'ทั้งหมด',
    'ทะเล',
    'ธรรมชาติ',
    'วัฒนธรรม',
    'อาหาร',
    'ช้อปปิ้ง',
  ];

  // [Checkpoint 4.1 ข้อ 2] สวิตช์เปิด/ปิดแถบ Debug ที่เทียบ
  // MediaQuery.size.width กับ LayoutBuilder constraints.maxWidth
  // (ใช้ตอนทดสอบข้อ 15 ในตาราง แล้วปิดได้ด้วยการเปลี่ยนเป็น false)
  static const bool _showSizeDebug = true;

  // Getter (ไม่ใช่ Method ธรรมดา เรียกโดยไม่ต้องมี ()) คำนวณรายการที่ตรงกับคำค้นหาใหม่ทุกครั้งที่ถูกเรียก
  // เพื่อให้ build() อ่านค่าที่กรองแล้วได้ตรง ๆ โดยไม่ต้องเก็บ State ซ้ำซ้อน
  List<Destination> get _filteredDestinations {
    // กรองด้วย Tag ที่เลือกก่อน แล้วค่อยกรองด้วยคำค้นหาซ้อนอีกชั้น
    final byTag = _selectedTag == 'ทั้งหมด'
        ? sampleDestinations
        : sampleDestinations.where((d) => d.tags.contains(_selectedTag)).toList();

    if (_searchQuery.isEmpty) return byTag;
    return byTag
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
      appBar: AppBar(
        title: const Text('สำรวจ'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              // ทุกครั้งที่พิมพ์ จะเรียก setState เพื่อบันทึกคำค้นหาใหม่
              // แล้วสั่งให้ build() ทำงานใหม่ ซึ่งจะไปเรียก _filteredDestinations ที่กรองด้วยค่าล่าสุด
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
          // ── [การทดลองที่ 7.1] แถบ FilterChip แนวนอน ──────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _allTags.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tag = _allTags[index];
                final isSelected = tag == _selectedTag;
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedTag = tag),
                );
              },
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
    // ── LayoutBuilder: ปรับ Column Count ตามมาตรฐาน M3 Window Size Classes ──
    return LayoutBuilder(
      builder: (context, constraints) {
        // [Checkpoint 4.1 ข้อ 2] ดึงความกว้าง "ทั้งหน้าจอ" มาเทียบกับ
        // ความกว้าง "ที่ Widget นี้ได้รับจริง" จาก LayoutBuilder
        final screenWidth = MediaQuery.of(context).size.width;

        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2; // Compact: Phone
        } else if (constraints.maxWidth < 840) {
          crossAxisCount = 3; // Medium: Tablet Portrait
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 4; // Expanded: Tablet Landscape / Desktop
        } else {
          // [Checkpoint 4.1 ข้อ 1] Breakpoint ระดับที่ 4
          crossAxisCount = 5; // Large: จอคอมพิวเตอร์ขนาดใหญ่ (>= 1200 dp)
        }

        // พิมพ์ค่าลง Debug Console ทุกครั้งที่ขนาดเปลี่ยน
        debugPrint(
          '[Checkpoint 4.1] MediaQuery.width = ${screenWidth.toStringAsFixed(1)} | '
          'LayoutBuilder.maxWidth = ${constraints.maxWidth.toStringAsFixed(1)} | '
          'crossAxisCount = $crossAxisCount',
        );

        // ─────────────────────────────────────────────────────────────
        // [Checkpoint 4.1 ข้อ 3] สรุปความต่างของค่าทั้งสองตัว
        //
        // 1) MediaQuery.of(context).size.width = ความกว้างของ "ทั้งหน้าต่าง/หน้าจอ"
        //    เป็นค่าเดียวกันหมดไม่ว่าจะเรียกจาก Widget ตัวไหนในแอป
        // 2) constraints.maxWidth ของ LayoutBuilder = ความกว้าง "ที่ Parent
        //    ยอมให้ Widget ตัวนี้ใช้" ซึ่งจะถูกหักด้วย Padding / Margin /
        //    Navigation Rail / Drawer ที่คั่นอยู่ก่อนหน้าเสมอ
        // 3) ในหน้านี้สองค่าเท่ากัน (ต่างกัน 0) เพราะ Grid กินเต็มความกว้าง
        //    ของ Scaffold body พอดี — แต่แถบ Debug ด้านล่างมีตัวอย่างกล่องที่
        //    ถูก Padding 16 สองข้างครอบไว้ จะเห็นว่า maxWidth น้อยกว่าจอ 32 dp
        // สรุปการเลือกใช้: ตัดสินใจ Layout ของ Widget ตัวใดตัวหนึ่ง (เช่นจำนวน
        // คอลัมน์ของ Grid) ให้ใช้ LayoutBuilder เพราะสะท้อนพื้นที่จริงที่มี
        // ส่วน MediaQuery เหมาะกับการตัดสินใจระดับทั้งแอป (เช่น จะโชว์
        // Bottom Navigation หรือ Navigation Rail) และข้อมูลระดับอุปกรณ์อื่น ๆ
        // เช่น orientation, textScaler, padding ของ Safe Area
        // ─────────────────────────────────────────────────────────────

        return Column(
          children: [
            if (_showSizeDebug)
              _SizeDebugBanner(
                screenWidth: screenWidth,
                layoutMaxWidth: constraints.maxWidth,
                crossAxisCount: crossAxisCount,
              ),
            Expanded(
              child: GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  // สัดส่วน Card width/height — ปรับจาก 0.72 เป็น 0.62
                  // เพราะ Checkpoint 3 เพิ่มแถว "พร้อมเข้าพัก" เข้ามาในการ์ด
                  // ถ้าไม่ปรับ การ์ดจะสูงเกินช่องจนเกิด RenderFlex overflow
                  childAspectRatio: 0.62,
                ),
                itemCount: _filteredDestinations.length,
                itemBuilder: (context, index) {
                  final destination = _filteredDestinations[index];
                  return DestinationCard(
                    destination: destination,
                    onTap: () {
                      // เรียกใช้ Named Route แบบมี Type-safe parameters
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
                color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// [Checkpoint 4.1 ข้อ 2-3] แถบชั่วคราวที่โชว์ค่าความกว้าง 3 แบบพร้อมกัน
/// เพื่อให้เห็นด้วยตาว่า MediaQuery กับ LayoutBuilder ต่างกันตรงไหน
class _SizeDebugBanner extends StatelessWidget {
  final double screenWidth;
  final double layoutMaxWidth;
  final int crossAxisCount;

  const _SizeDebugBanner({
    required this.screenWidth,
    required this.layoutMaxWidth,
    required this.crossAxisCount,
  });

  String _sizeClass(double w) {
    if (w < 600) return 'Compact';
    if (w < 840) return 'Medium';
    if (w < 1200) return 'Expanded';
    return 'Large';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MediaQuery.size.width = ${screenWidth.toStringAsFixed(1)} dp  '
            '(ทั้งหน้าจอ)',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            'LayoutBuilder.maxWidth  = ${layoutMaxWidth.toStringAsFixed(1)} dp  '
            '(พื้นที่ที่ Grid ได้รับ)',
            style: const TextStyle(fontSize: 12),
          ),
          // กล่องตัวอย่างที่ถูก Padding 16 สองข้างครอบไว้อีกชั้น —
          // LayoutBuilder ตัวในนี้จะได้ maxWidth น้อยกว่าจอ 32 dp ทันที
          // พิสูจน์ว่า constraints ขึ้นกับ "ตำแหน่งใน Widget Tree" ไม่ใช่ขนาดจอ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, inner) => Text(
                'กล่องที่ซ้อนใน Padding(16) ได้ maxWidth = '
                '${inner.maxWidth.toStringAsFixed(1)} dp',
                style: const TextStyle(fontSize: 12, color: Colors.deepOrange),
              ),
            ),
          ),
          Text(
            'Window Size Class: ${_sizeClass(layoutMaxWidth)}  →  '
            'crossAxisCount = $crossAxisCount',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
