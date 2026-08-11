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
  String _searchQuery = ''; // เก็บคำค้นหาปัจจุบัน
  String _selectedTag = 'ทั้งหมด';
  final List<String> _allTags = [
    'ทั้งหมด',
    'ทะเล',
    'ธรรมชาติ',
    'วัฒนธรรม',
    'อาหาร',
    'ช้อปปิ้ง',
    'วัด'
  ];

  // Getter คำนวณรายการที่ตรงกับคำค้นหาและแท็กที่เลือก
  List<Destination> get _filteredDestinations {
    return sampleDestinations.where((d) {
      final matchesSearch = _searchQuery.isEmpty ||
          d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.country.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesTag =
          _selectedTag == 'ทั้งหมด' || d.tags.contains(_selectedTag);

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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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

          // ── Category Filter Chips (การทดลองที่ 7.1) ─────────────────
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
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue.shade700,
                );
              },
            ),
          ),
          const SizedBox(height: 8),

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
        // 🎯 Checkpoint 4.1 (ข้อ 2): เปรียบเทียบ MediaQuery.of(context).size.width กับ constraints.maxWidth
        final screenWidth = MediaQuery.of(context).size.width;
        debugPrint(
            'Checkpoint 4.1 -> ScreenWidth: $screenWidth | Constraints.maxWidth: ${constraints.maxWidth}');

        // 🎯 Checkpoint 4.1 (ข้อ 1): เพิ่ม Breakpoint ระดับ 4: Large (>= 1200 dp) crossAxisCount = 5
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2; // Compact: Phone
        } else if (constraints.maxWidth < 840) {
          crossAxisCount = 3; // Medium: Tablet Portrait
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 4; // Expanded: Tablet Landscape / Desktop
        } else {
          crossAxisCount = 5; // Large: Large Screens / Desktop Wide (>= 1200 dp)
        }

        // 🎯 Checkpoint 4.1 (ข้อ 3) - Comment สรุปความแตกต่าง:
        // MediaQuery.of(context).size.width คือขนาดความกว้างรวมของทั้งหน้าจออุปกรณ์ (Physical/Window Screen Width)
        // ส่วน LayoutBuilder constraints.maxWidth คือความกว้างสูงสุดที่ Parent มอบให้ Widget ตัวนี้ได้จัดวาง Content
        // ค่าทั้งสองจะเท่ากันเมื่อ Widget แสดงแบบเต็มความกว้างหน้าจอ แต่จะต่างกันหาก Widget อยู่ในโครงสร้าง layout ย่อย (เช่น Sidebar หรือ Split View)
        // สรุป: ควรใช้ MediaQuery เมื่อต้องการตัดสินใจเชิงโครงสร้างทั้งหน้า (Global/Page-level Layout)
        // และใช้ LayoutBuilder เมื่อต้องการทำ Responsive ในระดับย่อย (Local Widget Component) เพื่อความยืดหยุ่นและการนำกลับมาใช้ใหม่

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
            '"${_searchQuery.isNotEmpty ? _searchQuery : _selectedTag}"',
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
