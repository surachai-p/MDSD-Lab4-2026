# 📱 ใบงานการทดลองที่ 4: Flutter Layout & Navigation — Multi-Screen Travel App

**รหัสนักศึกษา :** 67030323

**ชื่อ-นามสกุล :** นาย พรพรม สุขใจมิตร

**สถานะโปรเจกต์:** ✅ เสร็จสมบูรณ์ (Completed)

---

## 🗂️ โครงสร้างของพื้นที่ทำงาน (Workspace)

* 📁 **Lab/** : โฟลเดอร์สำหรับเก็บซอร์สโค้ดของโปรเจกต์ Flutter (`travel_app`)
* 📁 **Report/** : โฟลเดอร์จัดเก็บไฟล์รายงานผลการทดลอง (`67030323_report.md`) และไฟล์รูปภาพผลการรันโปรแกรมใน Checkpoint ต่างๆ
* 📄 **Readme.md** : ภาพรวมและรายละเอียดของโปรเจกต์ (ไฟล์นี้)

---

## 🚀 สรุปสิ่งที่ได้เรียนรู้และพัฒนา (Completed Tasks)

* [x] **การทดลองที่ 1** — สร้าง Project และตั้งค่า Dependencies (`go_router`, `cupertino_icons`)
* [x] **การทดลองที่ 2** — สร้าง Data Model แบบ Immutable (`Destination`)
* [x] **การทดลองที่ 3** — สร้าง Reusable Widget (`DestinationCard`) และจัดการ Layout ด้วย `Stack`, `Positioned`, `Row` และ `Column`
* [x] **การทดลองที่ 4** — สร้างหน้าจอ (Screens) แบบ Responsive โดยใช้ `LayoutBuilder` ร่วมกับ `GridView` และ `ListView`
* [x] **การทดลองที่ 5** — ตั้งค่า `GoRouter` ด้วย `StatefulShellRoute` เพื่อรักษา State ของ Tab และจัดการหน้า Fallback กรณีหาข้อมูลไม่พบ
* [x] **การทดลองที่ 6** — รันและทดสอบการทำงานของแอปพลิเคชันตามตารางทดสอบ
* [x] **การทดลองที่ 7** — เพิ่มฟีเจอร์ Category Filter ในหน้าสำรวจ และทำ Transition Animation (Slide) สำหรับหน้า Detail
* [x] **การทดลองที่ 8 (Challenge)** — พัฒนาหน้า Saved Screen ให้ใช้งานได้จริง โดยใช้ `ValueNotifier` เป็น Global State เพื่อให้ข้อมูลการกดบันทึก 🤍 ซิงค์ตรงกันทุกหน้าจอแบบเรียลไทม์
* [x] **📝 ส่วนเพิ่มเติม** — ตอบคำถามท้ายใบงานและสรุปผลการทดลองเสร็จสิ้น

---

## 🛠️ วิธีการรันโปรเจกต์

### 1. เปิด Terminal แล้วทำการย้ายเข้าไปยังโฟลเดอร์ของแอปพลิเคชัน

```
cd Lab/travel_app
```

### 2. ดึงข้อมูลแพ็กเกจที่จำเป็น

```
flutter pub get
```

### 3. รันแอปพลิเคชัน (แนะนำให้รันบน Chrome เพื่อความรวดเร็วในการทดสอบ Responsive)

```
flutter run -d chrome
```
