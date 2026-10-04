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
  
  // การทดลองที่ 7.1: เพิ่ม Category Filter
  String _selectedTag = 'ทั้งหมด';
  final List<String> _allTags = [
    'ทั้งหมด',
    'ทะเล',
    'ธรรมชาติ',
    'วัฒนธรรม',
    'อาหาร',
    'ช้อปปิ้ง'
  ];

  // Getter คำนวณรายการที่ตรงกับคำค้นหาและแท็กที่เลือกใหม่ทุกครั้งที่ถูกเรียก
  List<Destination> get _filteredDestinations {
    return sampleDestinations.where((d) {
      final matchesSearch = _searchQuery.isEmpty ||
          d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.country.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.tags.any(
            (t) => t.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
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
          const SizedBox(height: 10),
          // ── การทดลองที่ 7.1: Category Filter Chips ────────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _allTags.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
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
        // ข้อ 2: ลองดึงความกว้างจอจาก MediaQuery มาเทียบกับ maxWidth ของ LayoutBuilder
        final screenWidth = MediaQuery.of(context).size.width;
        debugPrint(
            'MediaQuery width: $screenWidth, LayoutBuilder maxWidth: ${constraints.maxWidth}');

        // ข้อ 3: MediaQuery จะบอกความกว้างของจอภาพทั้งหมด ส่วน LayoutBuilder จะบอกความกว้างของพื้นที่ที่ Widget นี้ได้รับจากตัวแม่
        // ถ้าจะเช็คขนาดจอภาพรวมให้ใช้ MediaQuery แต่ถ้าจะจัดคอลัมน์ Grid ให้พอดีกับพื้นที่ให้ใช้ LayoutBuilder

        // Checkpoint 4.1 ข้อ 1: เพิ่ม Breakpoint ระดับที่ 4 คือ Large (≥ 1200 dp) ให้ crossAxisCount = 5
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2; // Compact: Phone
        } else if (constraints.maxWidth < 840) {
          crossAxisCount = 3; // Medium: Tablet Portrait
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 4; // Expanded: Tablet Landscape / Desktop
        } else {
          crossAxisCount = 5; // Large (≥ 1200 dp): Ultra-wide / Large Desktop
        }

        return Column(
          children: [
            // แสดงแถบเปรียบเทียบค่า MediaQuery vs LayoutBuilder ชั่วคราวตาม Checkpoint 4.1 ข้อ 2
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MediaQuery: ${screenWidth.toStringAsFixed(1)} dp',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                  ),
                  Text(
                    'LayoutBuilder: ${constraints.maxWidth.toStringAsFixed(1)} dp (Cols: $crossAxisCount)',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
