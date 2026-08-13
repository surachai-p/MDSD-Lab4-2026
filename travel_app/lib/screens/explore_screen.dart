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
    final filteredByTag = _selectedTag == 'ทั้งหมด'
        ? sampleDestinations
        : sampleDestinations
              .where((d) => d.tags.contains(_selectedTag))
              .toList();

    if (_searchQuery.isEmpty) return filteredByTag;

    return filteredByTag
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
          SizedBox(
            height: 42,
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
        final effectiveWidth = constraints.maxWidth;
        int crossAxisCount;
        if (effectiveWidth < 600) {
          crossAxisCount = 2; // Compact: Phone
        } else if (effectiveWidth < 840) {
          crossAxisCount = 3; // Medium: Tablet Portrait
        } else if (effectiveWidth < 1200) {
          crossAxisCount = 4; // Expanded: Tablet Landscape / Desktop
        } else {
          crossAxisCount = 5; // Large: Desktop Wide
        }

        // screenWidth คือความกว้างของหน้าจอทั้งหมด,
        // constraints.maxWidth คือความกว้างที่ LayoutBuilder ได้รับจาก Parent.
        // สองค่ามักเท่ากันเมื่อตัว LayoutBuilder อยู่ในระดับบนสุดของ body,
        // แต่ถ้า Widget ถูกฝังในคอลัมน์หรือ container ที่มีขนาดจำกัด ค่าจะต่างกัน.
        // ควรใช้ constraints.maxWidth เมื่อกำหนด layout ของ Widget นั้น ๆ,
        // และใช้ MediaQuery เมื่ออยากได้ขนาดของหน้าจอหรือ device โดยตรง.
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
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
