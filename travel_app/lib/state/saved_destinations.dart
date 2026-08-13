import 'package:flutter/foundation.dart';

// เก็บ ID ของ Destination ที่ผู้ใช้กดบันทึกไว้ เป็น Global Singleton ตัวเดียวทั้งแอป
// ใช้ ChangeNotifier แทน State Management Library เพื่อให้ Explore, Detail และ Saved Screen
// อ่าน/แก้ไขข้อมูลชุดเดียวกันได้ และ Widget ที่ Listen ผ่าน ListenableBuilder จะรีเฟรชอัตโนมัติ
// ทุกครั้งที่มีการ toggle จากหน้าไหนก็ตาม โดยไม่ต้องส่ง Callback ไล่ผ่านทุกชั้น (Prop Drilling)
class SavedDestinationsController extends ChangeNotifier {
  SavedDestinationsController._internal();
  static final SavedDestinationsController instance =
      SavedDestinationsController._internal();

  final Set<String> _savedIds = {};

  Set<String> get savedIds => _savedIds;

  bool isSaved(String id) => _savedIds.contains(id);

  void toggle(String id) {
    if (_savedIds.contains(id)) {
      _savedIds.remove(id);
    } else {
      _savedIds.add(id);
    }
    notifyListeners();
  }
}
