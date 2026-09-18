import 'package:flutter/foundation.dart';

/// [การทดลองที่ 8 ข้อ 2] — State ที่ใช้ร่วมกันข้ามหน้า
///
/// COMMENT #1 (จุดที่ซับซ้อน): ทำไมต้องมี Class นี้แยกออกมาเป็น Global?
/// ถ้าเก็บ `Set<String> savedIds` ไว้ใน State ของหน้าใดหน้าหนึ่ง (เช่น
/// `_ExploreScreenState`) หน้าอื่น (Detail / Saved) จะมองไม่เห็นตัวแปรนั้นเลย
/// และ `setState()` ของหน้าหนึ่งก็สั่งให้อีกหน้า rebuild ไม่ได้ เพราะ setState
/// จะ mark dirty เฉพาะ Element ของ Widget ตัวเองเท่านั้น
/// จึงยกข้อมูลออกมาไว้นอก Widget Tree แล้วให้ทุกหน้า "ฟัง" ตัวเดียวกัน
///
/// COMMENT #2: ทำไม extends ChangeNotifier?
/// ChangeNotifier คือ Listenable ที่มี `notifyListeners()` ในตัว เมื่อเรียกแล้ว
/// ทุก `ListenableBuilder` ที่ผูกกับ Object นี้ (ไม่ว่าจะอยู่คนละหน้า คนละ Tab)
/// จะ rebuild ให้อัตโนมัติ — ได้ผลเหมือน setState แต่ข้ามหน้าได้
/// (ยังไม่ต้องใช้ Provider / Riverpod ในระดับนี้)
class SavedStore extends ChangeNotifier {
  final Set<String> _savedIds = <String>{};

  /// คืนค่าแบบ unmodifiable กันไม่ให้หน้าอื่นเผลอ add/remove ตรง ๆ
  /// โดยไม่ผ่าน toggle() (ถ้าแก้ตรง ๆ จะไม่มีการ notifyListeners → UI ไม่อัปเดต)
  Set<String> get savedIds => Set.unmodifiable(_savedIds);

  int get count => _savedIds.length;

  bool isSaved(String id) => _savedIds.contains(id);

  /// COMMENT #3: `Set.add()` คืน false ถ้ามีสมาชิกนั้นอยู่แล้ว
  /// จึงใช้ค่า return มาตัดสินว่าต้อง remove ต่อหรือไม่ ได้ toggle ในบรรทัดเดียว
  void toggle(String id) {
    if (!_savedIds.add(id)) {
      _savedIds.remove(id);
    }
    notifyListeners(); // ← หัวใจ: แจ้งทุกหน้าที่ฟังอยู่ให้ rebuild
  }
}

/// Instance เดียวที่ใช้ทั้งแอป (Global Singleton แบบง่ายที่สุด)
final SavedStore savedStore = SavedStore();
