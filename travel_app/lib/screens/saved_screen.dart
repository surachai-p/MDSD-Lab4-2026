import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';
import '../services/saved_service.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บันทึกไว้')),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: SavedService.savedIds,
        builder: (context, savedSet, _) {
          final savedList = sampleDestinations
              .where((d) => savedSet.contains(d.id))
              .toList();

          if (savedList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite, size: 64, color: Colors.pink.shade200),
                  const SizedBox(height: 16),
                  const Text(
                    'ยังไม่มีรายการที่บันทึก',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              int crossAxisCount = 2;
              if (w < 600) {
                crossAxisCount = 2;
              } else if (w < 840) {
                crossAxisCount = 3;
              } else {
                crossAxisCount = 4;
              }


              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 2,
                ),
                itemCount: savedList.length,
                itemBuilder: (context, index) {
                  final dest = savedList[index];
                  return DestinationCard(
                    destination: dest,
                    onTap: () {
              
                      context.pushNamed(
                        'destination-detail',
                        pathParameters: {'id': dest.id},
                        extra: dest,
                      );
                    },
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
