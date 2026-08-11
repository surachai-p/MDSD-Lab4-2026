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
  String _searchQuery = '';

  // ── การทดลองที่ 7.1: Category Filter ──────────────────────────
  String _selectedTag = 'ทั้งหมด';
  final List<String> _allTags = [
    'ทั้งหมด',
    'ทะเล',
    'ธรรมชาติ',
    'วัฒนธรรม',
    'อาหาร',
    'ช้อปปิ้ง'
  ];

  // กรองด้วยทั้ง Search Query และ Tag ที่เลือกพร้อมกัน
  List<Destination> get _filteredDestinations {
    var list = sampleDestinations;

    // กรองตาม Tag ก่อน (ถ้าเลือก "ทั้งหมด" ไม่ต้องกรอง)
    if (_selectedTag != 'ทั้งหมด') {
      list = list.where((d) => d.tags.contains(_selectedTag)).toList();
    }

    // แล้วค่อยกรองตามคำค้นหาซ้อนอีกชั้น
    if (_searchQuery.isNotEmpty) {
      list = list
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

    return list;
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
          const SizedBox(height: 12),

          // ── Category Filter Chips (การทดลองที่ 7.1) ──────────────
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
    final screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2; // Compact
        } else if (constraints.maxWidth < 840) {
          crossAxisCount = 3; // Medium
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 4; // Expanded
        } else {
          crossAxisCount = 5; // Large
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'screenWidth=${screenWidth.toStringAsFixed(1)} | '
                'maxWidth=${constraints.maxWidth.toStringAsFixed(1)} | '
                'columns=$crossAxisCount',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
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
            _searchQuery.isNotEmpty ? '"$_searchQuery"' : '"$_selectedTag"',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}