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
  String _selectedTag = 'ทั้งหมด';
  final _allTags = const [
    'ทั้งหมด',
    'ทะเล',
    'ธรรมชาติ',
    'วัฒนธรรม',
    'อาหาร',
    'ช้อปปิ้ง',
  ];

  List<Destination> get _filteredDestinations => sampleDestinations.where((
    destination,
  ) {
    final query = _searchQuery.toLowerCase();
    final matchesQuery =
        query.isEmpty ||
        destination.name.toLowerCase().contains(query) ||
        destination.country.toLowerCase().contains(query) ||
        destination.tags.any((tag) => tag.toLowerCase().contains(query));
    final matchesTag =
        _selectedTag == 'ทั้งหมด' || destination.tags.contains(_selectedTag);
    return matchesQuery && matchesTag;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สำรวจ')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'ค้นหา Destination...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _allTags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final tag = _allTags[index];
                return FilterChip(
                  label: Text(tag),
                  selected: tag == _selectedTag,
                  onSelected: (_) => setState(() => _selectedTag = tag),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredDestinations.isEmpty
                ? const Center(child: Text('ไม่พบ Destination ที่ค้นหา'))
                : _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        // MediaQuery คือความกว้างทั้งหน้าจอ เหมาะกับการเลือกโครงสร้างระดับแอป.
        // LayoutBuilder คือความกว้างที่ Parent จัดให้ Widget นี้ จึงเหมาะกับ component ที่อยู่ในพื้นที่ย่อย.
        debugPrint(
          'MediaQuery width: $screenWidth, LayoutBuilder width: ${constraints.maxWidth}',
        );
        final columns = constraints.maxWidth < 600
            ? 2
            : constraints.maxWidth < 840
            ? 3
            : constraints.maxWidth < 1200
            ? 4
            : 5;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 360,
          ),
          itemCount: _filteredDestinations.length,
          itemBuilder: (_, index) {
            final destination = _filteredDestinations[index];
            return DestinationCard(
              destination: destination,
              onTap: () => context.pushNamed(
                'destination-detail',
                pathParameters: {'id': destination.id},
                extra: destination,
              ),
            );
          },
        );
      },
    );
  }
}
