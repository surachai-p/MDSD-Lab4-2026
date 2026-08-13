import 'package:flutter/material.dart';

class SavedManager {
  // 1. ทำเป็น Singleton เพื่อให้ทั้งแอปเรียกใช้ instance ตัวเดียวกันเสมอ
  static final SavedManager instance = SavedManager._internal();
  SavedManager._internal();

  // 2. เก็บไอดีของสถานทีที่ถูกบันทึกไว้ (ใช้ Set เพื่อไม่ให้ ID ซ้ำกัน)
  final Set<String> _savedIds = {};

  // 3. ใช้ ValueNotifier เพื่อเวลาข้อมูลเปลี่ยน จะได้ตะโกนบอกหน้าอื่นให้ Rebuild ทันที!
  final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  // เช็กว่าไอดีนี้ถูกบันทึกหรือยัง
  bool isSaved(String id) => _savedIds.contains(id);

  // สลับสถานะ (ถ้ามีให้ลบ ถ้าไม่มีให้เพิ่ม)
  void toggleSave(String id) {
    if (_savedIds.contains(id)) {
      _savedIds.remove(id);
    } else {
      _savedIds.add(id);
    }
    // เพิ่มค่าเพื่อนับก้าว และเป็นการส่งสัญญาณ (Notify) ให้ผู้ฟังรับทราบ
    changeNotifier.value++;
  }

  // ดึงรายการ ID ทั้งหมดออกมา
  List<String> get savedIds => _savedIds.toList();
}
