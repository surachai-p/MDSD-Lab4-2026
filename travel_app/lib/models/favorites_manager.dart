import 'package:flutter/material.dart';
import 'destination.dart';

// คลาสเก็บข้อมูลสถานที่ที่กดบันทึกไว้
class FavoritesManager extends ChangeNotifier {
  static final FavoritesManager instance = FavoritesManager();

  // จุดที่ 1: ใช้ Set เก็บ id เพราะจะได้ไม่บันทึกซ้ำ และเช็คง่าย
  final Set<String> _savedIds = {'2'};

  Set<String> get savedIds => _savedIds;

  bool isSaved(String id) => _savedIds.contains(id);

  // จุดที่ 2: ฟังก์ชันกดสลับบันทึก/ยกเลิก แล้วสั่งเตือนหน้าอื่นให้รีเฟรชตาม
  void toggleSave(String id) {
    if (_savedIds.contains(id)) {
      _savedIds.remove(id);
    } else {
      _savedIds.add(id);
    }
    notifyListeners();
  }

  // ดึงข้อมูลสถานที่ที่ตรงกับ id ที่บันทึกไว้
  List<Destination> get savedDestinations {
    return sampleDestinations.where((d) => _savedIds.contains(d.id)).toList();
  }
}
