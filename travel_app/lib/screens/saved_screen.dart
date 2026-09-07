import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../models/saved_store.dart';
import '../widgets/destination_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บันทึกไว้')),
      body: AnimatedBuilder(
        animation: savedStore,
        builder: (_, __) {
          final saved = sampleDestinations
              .where((destination) => savedStore.contains(destination.id))
              .toList();
          if (saved.isEmpty)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, size: 64, color: Colors.pink.shade200),
                  const SizedBox(height: 16),
                  const Text(
                    'ยังไม่มีรายการที่บันทึก',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          return LayoutBuilder(
            builder: (context, constraints) {
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
                itemCount: saved.length,
                itemBuilder: (_, index) {
                  final destination = saved[index];
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
        },
      ),
    );
  }
}
