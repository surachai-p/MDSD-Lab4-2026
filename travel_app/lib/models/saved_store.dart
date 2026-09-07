import 'package:flutter/foundation.dart';

class SavedStore extends ChangeNotifier {
  final Set<String> savedIds = <String>{};

  bool contains(String id) => savedIds.contains(id);

  void toggle(String id) {
    if (!savedIds.add(id)) savedIds.remove(id);
    notifyListeners();
  }
}

final savedStore = SavedStore();
