import 'package:flutter/foundation.dart';

// ใช้ ValueNotifier เพื่อให้ Widget ต่างๆ สามารถ "ดักฟัง" (Listen) การเปลี่ยนแปลงได้
// เมื่อค่าข้างในเปลี่ยน UI ที่เชื่อมอยู่จะอัปเดตอัตโนมัติข้ามหน้าจอ

// ---------------------------------------------------------------------------
// [จุดที่ซับซ้อนที่ 1]: การจัดการ State ข้ามหน้าจอด้วย ValueNotifier
// เหตุผล: การใช้ setState ปกติจะไม่สามารถอัปเดต UI ข้ามหน้าจอได้ (เช่น กดเซฟหน้า Detail แล้วให้หน้า Saved อัปเดตตาม) 
// จึงต้องสร้าง ValueNotifier<Set<String>> เป็น Global Variable ไว้ตรงกลาง 
// เพื่อให้ Widget ในหน้าต่างๆ สามารถดึงค่าไปใช้ และใช้ ValueListenableBuilder มาดักฟังการเปลี่ยนแปลง
// เมื่อมีการเรียก toggleSaved ค่า value เปลี่ยน UI ทุกหน้าที่ดักฟังอยู่จะรีเฟรชตัวเองอัตโนมัติ
// ---------------------------------------------------------------------------
final ValueNotifier<Set<String>> globalSavedIds = ValueNotifier<Set<String>>({});

// ฟังก์ชันสำหรับสลับสถานะการบันทึก (เพิ่ม/ลบ ID)
void toggleSaved(String id) {
  final currentSet = Set<String>.from(globalSavedIds.value);
  if (currentSet.contains(id)) {
    currentSet.remove(id); // ถ้ามีอยู่แล้วให้เอาออก
  } else {
    currentSet.add(id);    // ถ้ายังไม่มีให้เพิ่มเข้าไป
  }
  globalSavedIds.value = currentSet; // อัปเดตค่าใหม่เข้า Notifier เพื่อกระตุ้น UI
}