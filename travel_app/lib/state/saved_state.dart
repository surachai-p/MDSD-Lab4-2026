import 'package:flutter/foundation.dart';

/// เก็บสถานะ "Destination ไหนถูกบันทึกไว้บ้าง" แบบ Global ตัวเดียว
/// ให้ทุกหน้า (Explore, Detail, Saved) อ่าน/เขียนข้อมูลชุดเดียวกันได้
///
/// ── ทำไมต้องใช้ ChangeNotifier แทน Set<String> ธรรมดา ──
/// ถ้าใช้แค่ static Set<String> ธรรมดา ปัญหาคือ: setState() มีผล
/// แค่กับ widget ที่เรียกมันเท่านั้น เช่นกด "หัวใจ" ที่ Explore Screen
/// แล้ว setState ที่นั่น จะไม่ทำให้ SavedScreen (ซึ่งเป็นคนละ Widget
/// Tree กันเลยใน StatefulShellRoute) รู้ตัวว่าต้อง rebuild ตามไปด้วย
/// ChangeNotifier แก้ปัญหานี้โดยทำหน้าที่เป็น "ผู้ประกาศข่าว" — เมื่อ
/// เรียก notifyListeners() ทุก Widget ที่ "สมัครฟัง" (listen) อยู่ ไม่ว่า
/// จะอยู่ตรงไหนใน Widget Tree ก็จะถูกสั่งให้ rebuild ตัวเองทันที
class SavedState extends ChangeNotifier {
  // Singleton Pattern: บังคับให้ทั้งแอปมี instance เดียวเท่านั้น
  // เพื่อไม่ให้แต่ละหน้าถือข้อมูลคนละชุดกันโดยไม่ตั้งใจ
  SavedState._internal();
  static final SavedState instance = SavedState._internal();

  final Set<String> _savedIds = {};

  Set<String> get savedIds => _savedIds;

  bool isSaved(String id) => _savedIds.contains(id);

  void toggle(String id) {
    if (_savedIds.contains(id)) {
      _savedIds.remove(id);
    } else {
      _savedIds.add(id);
    }
    notifyListeners(); // แจ้งทุกหน้าที่กำลัง listen อยู่ให้ rebuild
  }
}