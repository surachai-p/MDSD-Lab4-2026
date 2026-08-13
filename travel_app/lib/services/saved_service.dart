import 'package:flutter/foundation.dart';
import '../models/destination.dart';

/// Simple app-scoped saved manager using a ValueNotifier so widgets can
/// listen for changes without pulling in a full state-management package.
class SavedService {
  // ValueNotifier holds the Set of saved destination IDs. Using ValueNotifier
  // keeps the API minimal while allowing UI to rebuild via
  // ValueListenableBuilder when the set changes.
  static final ValueNotifier<Set<String>> savedIds = ValueNotifier({});

  static bool isSaved(String id) => savedIds.value.contains(id);

  static void toggle(String id) {
    final newSet = Set<String>.from(savedIds.value);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    savedIds.value = newSet;
  }

  static List<Destination> getSavedDestinations() {
    return sampleDestinations
        .where((d) => savedIds.value.contains(d.id))
        .toList();
  }
}
