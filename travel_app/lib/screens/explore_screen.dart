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

  // เพิ่มใน State ของ _ExploreScreenState (การทดลองที่ 7.1)
  String _selectedTag = 'ทั้งหมด';
  final List<String> _allTags = [
    'ทั้งหมด',
    'ทะเล',
    'ธรรมชาติ',
    'วัฒนธรรม',
    'อาหาร',
    'ช้อปปิ้ง',
  ];

  // Getter (ไม่ใช่ Method ธรรมดา เรียกโดยไม่ต้องมี ()) คำนวณรายการที่ตรงกับคำค้นหาใหม่ทุกครั้งที่ถูกเรียก
  // เพื่อให้ build() อ่านค่าที่กรองแล้วได้ตรง ๆ โดยไม่ต้องเก็บ State ซ้ำซ้อน
  List<Destination> get _filteredDestinations {
    return sampleDestinations.where((d) {
      final matchesSearch = _searchQuery.isEmpty ||
          d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.country.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.tags.any(
            (t) => t.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
      final matchesTag = _selectedTag == 'ทั้งหมด' ||
          d.tags.contains(_selectedTag);
      return matchesSearch && matchesTag;
    }).toList();
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
          // ── Category Filter (การทดลองที่ 7.1) ────────────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _allTags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
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
        // MediaQuery.of(context).size.width = ความกว้างของ "ทั้งหน้าจอ/หน้าต่าง" เสมอ
        // ไม่ว่า Widget นี้จะถูกฝังอยู่ลึกแค่ไหนในต้นไม้ Widget ก็ตาม
        // ส่วน constraints.maxWidth (จาก LayoutBuilder) = ความกว้างที่ "Parent widget ตรงนี้"
        // ส่งลงมาให้จริง ๆ ซึ่งอาจแคบกว่าหน้าจอทั้งหมด ถ้ามี Sidebar/Padding/NavigationRail
        // กินพื้นที่ไปก่อนถึง Widget นี้ (Checkpoint 4.1)
        // ค่าที่สังเกตได้จริง: บนหน้านี้ทั้งสองค่าเท่ากันเสมอ เพราะ ExploreScreen ไม่มี
        // Sidebar/Padding ซ้ายขวาที่กิน Layout ก่อนถึง GridView — แต่ในหน้าที่มี
        // Sidebar/NavigationRail/Multi-pane layout สองค่านี้จะต่างกันชัดเจน
        // สรุปหลักการเลือกใช้: จะจัด Layout "เฉพาะพื้นที่ของ Widget นี้เอง" ให้ใช้ LayoutBuilder
        // เพราะสะท้อนพื้นที่จริงที่ได้รับ ถ้าจะตัดสินใจอะไรที่ผูกกับ "ขนาดอุปกรณ์/หน้าจอโดยรวม"
        // (เช่น จะโชว์ Bottom Navigation หรือ Navigation Rail) ให้ใช้ MediaQuery แทน
        final screenWidth = MediaQuery.of(context).size.width;
        debugPrint(
            'screenWidth(MediaQuery)=$screenWidth vs maxWidth(LayoutBuilder)=${constraints.maxWidth}');

        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2; // Compact: Phone
        } else if (constraints.maxWidth < 840) {
          crossAxisCount = 3; // Medium: Tablet Portrait
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 4; // Expanded: Tablet Landscape / Desktop
        } else {
          crossAxisCount = 5; // Large (Checkpoint 4.1): จอกว้างมาก/Desktop ใหญ่
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72, // สัดส่วน Card width/height
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
