# 📱 ใบงานการทดลองที่ 4
# Flutter Layout & Navigation — Multi-Screen Travel App

> **รายวิชา:** การพัฒนาซอฟต์แวร์สำหรับอุปกรณ์เคลื่อนที่  
> **เครื่องมือ:** Flutter SDK, Dart, VS Code, Go Router  

---

## 📋 วัตถุประสงค์การเรียนรู้

เมื่อจบใบงานการทดลองนี้ นักศึกษาสามารถ:

1. ใช้ Layout Widgets หลัก (`Row`, `Column`, `Stack`, `GridView`, `ListView`) ได้อย่างถูกต้อง
2. สร้าง Responsive Layout ที่ปรับขนาดตามหน้าจอโดยอ้างอิงมาตรฐาน Material Design 3 (Window Size Classes) ด้วย `LayoutBuilder` และ `MediaQuery` ได้
3. ตั้งค่า Navigation แบบ Multi-screen ด้วย **Go Router** พร้อม Named Routes และ `StatefulShellRoute` ได้
4. ส่งผ่านข้อมูล (Arguments / Path Parameters) ระหว่าง Screen และจัดการ Fallback กรณี Deep Link / Web Refresh ได้อย่างถูกต้อง
5. ออกแบบ Navigation Hierarchy ที่เหมาะสมสำหรับ Mobile และ Web Application

### 🎯 การเชื่อมโยงวัตถุประสงค์กับการประเมินผล

| วัตถุประสงค์ | วัดผลจาก |
|---|---|
| 1. Layout Widgets | Checkpoint 3 (DestinationCard), Checkpoint 4.3 (ListView), ตารางทดสอบ #2, #10, #12 |
| 2. Responsive + LayoutBuilder/MediaQuery | Checkpoint 4.1, ตารางทดสอบ #10, #15, คำถามข้อ 1 |
| 3. Go Router Multi-screen | Checkpoint 5.1, ตารางทดสอบ #1, #2, #5, #6, #8, #9, #14, คำถามข้อ 2 |
| 4. ส่งข้อมูล + Fallback | Checkpoint 5.1, ตารางทดสอบ #4, #11, #13, คำถามข้อ 4 |
| 5. Navigation Hierarchy | คำถามข้อ 5, การทดลองที่ 8 |

---

## 🧪 ทฤษฎีก่อนการทดลอง

### ส่วนที่ 1 — Flutter Layout System & Material Design 3 Breakpoints

Flutter ใช้ **Constraint-based Layout** โดยมีกระบวนการทำงาน 3 ขั้น:

```
Parent → ส่ง Constraints (min/max width/height) ลงไป → Child
Child  → คำนวณขนาดตัวเอง → แจ้ง Size กลับ → Parent
Parent → จัดวางตำแหน่ง Child ตาม Size ที่ได้รับ
```

**Widget หลักที่ใช้ใบงานนี้:**

| Widget | หน้าที่ | คุณสมบัติสำคัญ |
|---|---|---|
| `Row` | จัดวาง Children แนวนอน | `mainAxisAlignment`, `crossAxisAlignment` |
| `Column` | จัดวาง Children แนวตั้ง | `mainAxisAlignment`, `crossAxisAlignment` |
| `Stack` | วาง Children ซ้อนกัน (Z-axis) | `alignment`, `fit` |
| `Expanded` | ยืดให้เต็มพื้นที่ใน Row/Column | `flex` (กำหนดสัดส่วน) |
| `Flexible` | ยืดได้แต่ไม่บังคับให้เต็ม | `flex`, `fit` |
| `SizedBox` | กำหนดขนาดตายตัว / ช่องว่าง | `width`, `height` |
| `Padding` | เพิ่ม Padding รอบ Child | `EdgeInsets` |
| `Container` | Box Model ครบ (padding, margin, border, color) | หลายคุณสมบัติ |
| `GridView` | แสดง Items เป็น Grid | `crossAxisCount`, `crossAxisSpacing` |
| `ListView` | แสดง Items เป็น List แบบ Scrollable | `builder`, `itemCount` |
| `LayoutBuilder` | รับ Constraints ของ Parent เพื่อทำ Responsive | `BoxConstraints` |

**Alignment ใน Row และ Column:**

```
MainAxis = แกนหลัก       CrossAxis = แกนตั้งฉาก

Row:    MainAxis = แนวนอน (←→)   CrossAxis = แนวตั้ง (↑↓)
Column: MainAxis = แนวตั้ง (↑↓)   CrossAxis = แนวนอน (←→)

MainAxisAlignment:
  .start          .center         .end
  .spaceBetween   .spaceAround    .spaceEvenly

CrossAxisAlignment:
  .start    .center    .end    .stretch    .baseline
```

**ตัวอย่าง Expanded กับ flex:**

```dart
Row(
  children: [
    Expanded(flex: 1, child: Container(color: Colors.red)),    // 1/3
    Expanded(flex: 2, child: Container(color: Colors.blue)),   // 2/3
  ],
)
```

**📐 มาตรฐาน Window Size Classes ของ Material Design 3 (M3):**

ในการออกแบบ Responsive Layout บน M3 จะใช้ความกว้างหน้าจอ (Width Breakpoints) แบ่งออกเป็น 3 ระดับหลัก:

- **Compact (< 600 dp):** มือถือแนวตั้ง (Phone Portrait) — แนะนำใช้ Grid 2 Columns หรือ List 1 Column, ใช้ Bottom Navigation Bar
- **Medium (600 dp – 839 dp):** แท็บเล็ตแนวตั้ง / มือถือพับได้ (Tablet Portrait / Phone Landscape) — แนะนำใช้ Grid 3 Columns, ใช้ Navigation Rail
- **Expanded (≥ 840 dp):** แท็บเล็ตแนวนอน / หน้าจอคอมพิวเตอร์ (Tablet Landscape / Desktop) — แนะนำใช้ Grid 4 Columns ขึ้นไป, ใช้ Navigation Drawer

---

### ส่วนที่ 2 — Go Router & Deep Linking

**Go Router** คือ Package Navigation ที่ Google แนะนำสำหรับ Flutter ซึ่งใช้ **Declarative / URL-based Navigation (Navigator 2.0)** เหมาะกับทั้ง Mobile และ Web

**แนวคิดหลัก:**

```
GoRouter (Router Configuration)
└── StatefulShellRoute (Bottom Navigation Wrapper)
    ├── Branch 0: GoRoute path: '/'                  → HomeScreen
    ├── Branch 1: GoRoute path: '/explore'           → ExploreScreen
    │   └── GoRoute path: 'destinations/:id'        → DestinationDetailScreen (รับ param :id)
    ├── Branch 2: GoRoute path: '/saved'             → SavedScreen
    └── Branch 3: GoRoute path: '/profile'           → ProfileScreen
```

**คำสั่งการนำทางที่สำคัญ:**

```dart
context.go('/explore')                                // เปลี่ยนไปหน้า /explore ตามโครงสร้าง Route Tree
context.push('/explore/destinations/1')               // Push หน้าใหม่ซ้อนทับขึ้นไปบน Stack (มีปุ่มย้อนกลับ)
context.pushNamed('destination-detail', pathParameters: {'id': '1'}) // เรียกผ่าน Named Route (ลดความเสี่ยงพิมพ์ Path ผิด)
context.pop()                                         // ย้อนกลับหน้าก่อนหน้า
```

**ความแตกต่างระหว่าง `ShellRoute` และ `StatefulShellRoute`:**

- **`ShellRoute`:** เมื่อผู้ใช้สลับ Tab ตัวหน้าเก่าจะถูกทำลาย (Destroy) ทำให้ State และตำแหน่ง Scroll หายไป
- **`StatefulShellRoute.indexedStack`:** รักษาสภาพหน้าและ State ของแต่ละ Tab ไว้ (Keep-Alive) เมื่อสลับ Tab กลับมา หน้าเดิมจะยังอยู่ตำแหน่งเดิม

> **⚠️ ข้อระวังการใช้ `extra` และ Deep Link:**
> การส่ง Object ผ่าน `extra` (เช่น `context.pushNamed('detail', extra: myObject)`) ช่วยให้ส่งข้อมูลข้ามหน้าได้สะดวก แต่หากผู้ใช้กด Refresh หน้าเว็บ หรือเปิดผ่าน Deep Link URL ตรง ๆ ค่า `extra` จะกลายเป็น `null` ดังนั้นในการทำงานจริง ต้องดึง `pathParameters['id']` มาใช้ค้นหาข้อมูลสำรอง (Fallback) เสมอ

---

## 🗂️ โครงสร้างโครงงานที่จะสร้าง

```
travel_app/
├── lib/
│   ├── main.dart                    ← Entry Point + Router Config
│   ├── router/
│   │   └── app_router.dart          ← GoRouter Setup (StatefulShellRoute + Named Routes)
│   ├── models/
│   │   └── destination.dart         ← Data Model & Sample Data
│   ├── screens/
│   │   ├── home_screen.dart         ← หน้าหลัก + Featured Items
│   │   ├── explore_screen.dart      ← รายการ Destination (Responsive Grid)
│   │   ├── destination_detail_screen.dart ← รายละเอียดสถานที่
│   │   ├── saved_screen.dart        ← รายการที่บันทึก
│   │   └── profile_screen.dart      ← Profile
│   └── widgets/
│       └── destination_card.dart    ← Reusable Card Widget
└── pubspec.yaml
```

---

## 🔬 การทดลอง

---

### การทดลองที่ 1 — สร้าง Project และ Setup Dependencies

#### ขั้นตอนที่ 1.1 — สร้าง Flutter Project ใหม่

```bash
flutter create travel_app
cd travel_app
```

#### ขั้นตอนที่ 1.2 — เพิ่ม Dependencies

เปิดไฟล์ `pubspec.yaml` แล้วแก้ไขส่วน `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.0.0
  cupertino_icons: ^1.0.8
```

บันทึกไฟล์แล้วรันคำสั่ง:

```bash
flutter pub get
```

ตรวจสอบว่าดาวน์โหลดสำเร็จ:

```bash
flutter pub deps | grep go_router
# ควรเห็น: go_router x.x.x
```

#### ขั้นตอนที่ 1.3 — สร้างโครงสร้าง Directory

```bash
mkdir -p lib/router lib/models lib/screens lib/widgets
```

---

### การทดลองที่ 2 — สร้าง Data Model

#### ขั้นตอนที่ 2.1 — สร้าง Destination Model

สร้างไฟล์ `lib/models/destination.dart`:

```dart
// ทุก Field เป็น final เพราะ Destination ควรเป็น Immutable Object
// (สร้างแล้วไม่แก้ไขค่าเดิม ถ้าต้องการเปลี่ยนค่าให้สร้าง Object ใหม่แทน)
class Destination {
  final String id;
  final String name;
  final String country;
  final String description;
  final String imageUrl;
  final double rating;
  final int price; // ราคาโดยประมาณ (USD/คืน)
  final List<String> tags;

  const Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.price,
    required this.tags,
  });
}

// ข้อมูลตัวอย่าง
final List<Destination> sampleDestinations = [
  Destination(
    id: '1',
    name: 'กรุงเทพฯ',
    country: 'ไทย',
    description:
        'เมืองหลวงที่คึกคักของไทย เต็มไปด้วยวัดวาอาราม อาหารริมทาง และชีวิตยามค่ำคืนที่ไม่รู้จบ',
    imageUrl: 'https://picsum.photos/seed/bangkok/400/300',
    rating: 4.7,
    price: 50,
    tags: ['วัด', 'อาหาร', 'ช้อปปิ้ง'],
  ),
  Destination(
    id: '2',
    name: 'เชียงใหม่',
    country: 'ไทย',
    description:
        'เมืองทางเหนือที่ล้อมรอบด้วยภูเขา วัดโบราณ และวัฒนธรรมล้านนา',
    imageUrl: 'https://picsum.photos/seed/chiangmai/400/300',
    rating: 4.8,
    price: 35,
    tags: ['ธรรมชาติ', 'วัฒนธรรม', 'Trekking'],
  ),
  Destination(
    id: '3',
    name: 'ภูเก็ต',
    country: 'ไทย',
    description: 'เกาะที่สวยงามที่สุดของไทย มีหาดทรายขาว น้ำทะเลใส และกิจกรรมดำน้ำ',
    imageUrl: 'https://picsum.photos/seed/phuket/400/300',
    rating: 4.6,
    price: 80,
    tags: ['ทะเล', 'ดำน้ำ', 'รีสอร์ท'],
  ),
  Destination(
    id: '4',
    name: 'โตเกียว',
    country: 'ญี่ปุ่น',
    description: 'มหานครที่ผสมผสานความทันสมัยและวัฒนธรรมดั้งเดิมได้อย่างลงตัว',
    imageUrl: 'https://picsum.photos/seed/tokyo/400/300',
    rating: 4.9,
    price: 120,
    tags: ['เทคโนโลยี', 'อาหาร', 'อนิเมะ'],
  ),
  Destination(
    id: '5',
    name: 'บาหลี',
    country: 'อินโดนีเซีย',
    description: 'เกาะแห่งพระเจ้า เต็มไปด้วยวัดและชายหาดสวยงาม',
    imageUrl: 'https://picsum.photos/seed/bali/400/300',
    rating: 4.7,
    price: 60,
    tags: ['วัฒนธรรม', 'ทะเล', 'Yoga'],
  ),
  Destination(
    id: '6',
    name: 'สิงคโปร์',
    country: 'สิงคโปร์',
    description: 'นครรัฐที่สะอาด ทันสมัย และปลอดภัย มีอาหารหลากหลายวัฒนธรรม',
    imageUrl: 'https://picsum.photos/seed/singapore/400/300',
    rating: 4.8,
    price: 150,
    tags: ['ช้อปปิ้ง', 'อาหาร', 'สวนสนุก'],
  ),
];
```

> **📌 สังเกต:** ใช้ `const` constructor เพราะ Destination ไม่เปลี่ยนแปลงหลังสร้าง (Immutable)

---

### การทดลองที่ 3 — สร้าง Reusable Widget

#### ขั้นตอนที่ 3.1 — สร้าง DestinationCard Widget

สร้างไฟล์ `lib/widgets/destination_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/destination.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ── 1. Decoration: rounded corner + shadow ──────────────
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        // ── 2. ClipRRect ป้องกัน Image เกิน Rounded Corner ──────
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 3. Stack: Image + Rating Badge ────────────────
              Stack(
                children: [
                  // 3a. รูป Destination
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      destination.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, _) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, size: 48),
                      ),
                    ),
                  ),
                  // 3b. Badge Rating (ซ้อนบนรูป)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            destination.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // ── 4. Info Section ────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ชื่อและราคา
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            destination.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${destination.price}/คืน',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // แสดงประเทศ
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text(
                          destination.country,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Tags
                    Wrap(
                      spacing: 6,
                      children: destination.tags
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(fontSize: 11),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              backgroundColor: Colors.blue.shade50,
                              shape: const StadiumBorder(
                                  side: BorderSide(color: Colors.transparent)),
                              padding: EdgeInsets.zero,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

> **📌 สังเกตการใช้ Layout:**
> - `Column` → จัดภาพและ Info section แนวตั้ง
> - `Stack` → วาง Rating Badge ทับบนรูป
> - `Positioned` → กำหนดตำแหน่ง Badge ใน Stack
> - `Row` → จัดชื่อและราคาในบรรทัดเดียวกัน
> - `Expanded` → ทำให้ชื่อยืดและตัด ... เมื่อยาวเกิน
> - `Wrap` → จัด Tags โดย Wrap ขึ้นบรรทัดใหม่เองเมื่อไม่พอ

> **🎯 Checkpoint 3 — แก้ไขโค้ดด้วยตนเอง :**
> แก้ไข `DestinationCard` ด้วยตัวเอง ดังนี้:
> 1. ย้าย Rating Badge จากมุมขวาบน (`top: 8, right: 8`) ไปเป็นมุม**ซ้ายล่าง**ของรูปแทน
> 2. เพิ่ม `Row` ใหม่ใต้ Tags แสดงไอคอน `Icons.bed` พร้อมข้อความ "พร้อมเข้าพัก" โดยครอบข้อความด้วย `Expanded` เพื่อกันไม่ให้ล้นถ้าชื่อยาว
> 3. เขียน Comment สั้น ๆ ในโค้ดของตัวเองอธิบายว่าทำไมต้องใช้ `Positioned` คู่กับ `Stack` ถึงจะย้ายตำแหน่ง Badge ได้ (ถ้าใช้ `Positioned` นอก `Stack` จะเกิดอะไรขึ้น)

บันทึกรูปผลการทดลอง

<img width="801" height="882" alt="image" src="https://github.com/user-attachments/assets/670d4db0-503a-4585-acf7-3169cb90af5b" />
<img width="831" height="832" alt="image" src="https://github.com/user-attachments/assets/3ef3eeb0-bd50-4279-9f22-5e249afd8bb8" />
<img width="848" height="825" alt="image" src="https://github.com/user-attachments/assets/95afb9f4-7b03-43a6-ac0c-b73fe39d5191" />
<img width="840" height="833" alt="image" src="https://github.com/user-attachments/assets/a88beaef-8b07-4746-ba9e-133a056deaf7" />
<img width="848" height="832" alt="image" src="https://github.com/user-attachments/assets/7541a2c2-cd33-4578-8dc8-8d6adea9fa3b" />
<img width="872" height="826" alt="image" src="https://github.com/user-attachments/assets/430afbc3-1990-48e7-bde9-e9f6afa97ea4" />
<img width="842" height="611" alt="image" src="https://github.com/user-attachments/assets/98be8335-38f3-44a3-9f5a-4f8a2adf66a0" />
<img width="1912" height="970" alt="image" src="https://github.com/user-attachments/assets/872bc03d-4188-4de9-8b20-d1ceac8ed126" />


---

### การทดลองที่ 4 — สร้าง Screens

#### ขั้นตอนที่ 4.1 — Explore Screen (Responsive Grid Layout)

สร้างไฟล์ `lib/screens/explore_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _searchQuery = ''; // เก็บคำค้นหาปัจจุบัน อัปเดตทุกครั้งที่พิมพ์ใน TextField

  // Getter (ไม่ใช่ Method ธรรมดา เรียกโดยไม่ต้องมี ()) คำนวณรายการที่ตรงกับคำค้นหาใหม่ทุกครั้งที่ถูกเรียก
  // เพื่อให้ build() อ่านค่าที่กรองแล้วได้ตรง ๆ โดยไม่ต้องเก็บ State ซ้ำซ้อน
  List<Destination> get _filteredDestinations {
    if (_searchQuery.isEmpty) return sampleDestinations;
    return sampleDestinations
        .where(
          (d) =>
              d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.country.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              d.tags.any(
                (t) => t.toLowerCase().contains(_searchQuery.toLowerCase()),
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สำรวจ'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              // ทุกครั้งที่พิมพ์ จะเรียก setState เพื่อบันทึกคำค้นหาใหม่
              // แล้วสั่งให้ build() ทำงานใหม่ ซึ่งจะไปเรียก _filteredDestinations ที่กรองด้วยค่าล่าสุด
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'ค้นหา Destination...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── Grid หรือ Empty State ────────────────────────────────
          Expanded(
            child: _filteredDestinations.isEmpty
                ? _buildEmptyState()
                : _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    // ── LayoutBuilder: ปรับ Column Count ตามมาตรฐาน M3 Window Size Classes ──
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2; // Compact: Phone
        } else if (constraints.maxWidth < 840) {
          crossAxisCount = 3; // Medium: Tablet Portrait
        } else {
          crossAxisCount = 4; // Expanded: Tablet Landscape / Desktop
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72, // สัดส่วน Card width/height
          ),
          itemCount: _filteredDestinations.length,
          itemBuilder: (context, index) {
            final destination = _filteredDestinations[index];
            return DestinationCard(
              destination: destination,
              onTap: () {
                // เรียกใช้ Named Route แบบมี Type-safe parameters
                context.pushNamed(
                  'destination-detail',
                  pathParameters: {'id': destination.id},
                  extra: destination,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'ไม่พบ Destination ที่ค้นหา',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            '"$_searchQuery"',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
```

> **🎯 Checkpoint 4.1 — แก้โค้ดเอง (ประเมินตามวัตถุประสงค์ข้อ 2):**
> 1. เพิ่ม Breakpoint ระดับที่ 4 คือ **Large (≥ 1200 dp)** ให้ `crossAxisCount = 5`
> 2. ใน `_buildGrid()` เพิ่มบรรทัด `final screenWidth = MediaQuery.of(context).size.width;` แล้วลองแสดงค่านี้เทียบกับ `constraints.maxWidth` ของ `LayoutBuilder` (เช่น พิมพ์ด้วย `print()` หรือแสดงเป็น `Text` ชั่วคราวบนหน้าจอ)
> 3. สังเกตว่าค่าทั้งสองตัวเท่ากันหรือไม่ แล้วเขียนสรุป 2-3 บรรทัดเป็น Comment ในโค้ดว่า `MediaQuery.of(context).size.width` (ความกว้างของทั้งหน้าจอ) กับ `LayoutBuilder` `constraints.maxWidth` (ความกว้างที่ Widget นั้น ๆ ได้รับจาก Parent) ต่างกันอย่างไร และควรเลือกใช้ตัวไหนเมื่อไหร่

บันทึกรูปผลการทดลอง

<img width="828" height="881" alt="image" src="https://github.com/user-attachments/assets/3a5eff34-525f-4d9d-a74e-cb4c6a62c02d" />
<img width="842" height="826" alt="image" src="https://github.com/user-attachments/assets/14ae6ad7-683b-4c7b-a1b9-1e37a8537854" />
<img width="841" height="823" alt="image" src="https://github.com/user-attachments/assets/f38a53ed-1270-4d65-9b0a-114b1b4cf14d" />
<img width="842" height="828" alt="image" src="https://github.com/user-attachments/assets/c39f9115-d5a0-45c2-81bb-5ef446d495b9" />
<img width="847" height="823" alt="image" src="https://github.com/user-attachments/assets/f36bc2fc-532c-4bf5-ac44-03ae45e36be4" />
<img width="857" height="607" alt="image" src="https://github.com/user-attachments/assets/0f6a9542-bd96-45ad-a784-6d18ac41e628" />
<img width="1916" height="967" alt="image" src="https://github.com/user-attachments/assets/119d9a4a-7d5b-41bb-8d54-5c93af216f58" />

```
```
#### ขั้นตอนที่ 4.2 — Destination Detail Screen

สร้างไฟล์ `lib/screens/destination_detail_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';

class DestinationDetailScreen extends StatelessWidget {
  final Destination destination;

  const DestinationDetailScreen({
    super.key,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: ทำให้ Body ขยายใต้ AppBar (Hero Effect)
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('บันทึก ${destination.name} แล้ว!'),
                      duration: const Duration(seconds: 2)),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image ──────────────────────────────────────────
            Stack(
              children: [
                // รูป Destination
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Image.network(
                    destination.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, _) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, size: 64),
                    ),
                  ),
                ),
                // Gradient Overlay สำหรับ Text ด้านล่างรูป
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                  ),
                ),
                // ชื่อ Destination ทับบน Gradient
                Positioned(
                  bottom: 16,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        destination.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            destination.country,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Info Section ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating และ Price Row
                  Row(
                    children: [
                      // Rating
                      _InfoChip(
                        icon: Icons.star,
                        iconColor: Colors.amber,
                        label: '${destination.rating}',
                        subtitle: 'Rating',
                      ),
                      const SizedBox(width: 16),
                      // Price
                      _InfoChip(
                        icon: Icons.attach_money,
                        iconColor: Colors.green,
                        label: '\$${destination.price}',
                        subtitle: 'ต่อคืน',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'เกี่ยวกับ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    destination.description,
                    style: const TextStyle(
                        fontSize: 15, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),

                  // Tags
                  const Text(
                    'สิ่งที่น่าสนใจ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: destination.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(tag,
                                style: TextStyle(color: Colors.blue.shade700)),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // showDialog เปิด Popup แบบ Modal (บล็อกหน้าจอด้านหลังจนกว่าจะปิด)
                        // ใช้ context ปัจจุบันเป็นตัวอ้างอิงตำแหน่งของ Navigator
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('จองสำเร็จ! 🎉'),
                            content: Text(
                                'คุณได้จอง ${destination.name} เรียบร้อยแล้ว'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Navigator.pop(context) ปิด Dialog ก่อน (Dialog เป็น Route ซ้อนอยู่บนสุด)
                                  // แล้วค่อย context.go('/') เพื่อกลับไปหน้า Home ผ่าน Go Router
                                  Navigator.pop(context);
                                  context.go('/');
                                },
                                child: const Text('กลับหน้าหลัก'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.flight_takeoff),
                      label: const Text('จองเลย',
                          style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Info Chip Widget — ขึ้นต้นด้วย _ (underscore) แปลว่าเป็น Private Class
// ใช้ได้แค่ภายในไฟล์นี้เท่านั้น เหมาะกับ Widget เล็ก ๆ ที่ใช้ซ้ำแค่ในหน้านี้
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;

  const _InfoChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
```

#### ขั้นตอนที่ 4.3 — Home, Saved, Profile Screens

สร้างไฟล์ `lib/screens/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = sampleDestinations.take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สวัสดี, นักเดินทาง! 👋',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const Text(
                        'ไปไหนดีวันนี้?',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Featured Section ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('แนะนำสำหรับคุณ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => context.go('/explore'),
                    child: const Text('ดูทั้งหมด'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ListView แนวนอน
              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final dest = featured[index];
                    return SizedBox(
                      width: 220,
                      child: DestinationCard(
                        destination: dest,
                        onTap: () => context.pushNamed(
                          'destination-detail',
                          pathParameters: {'id': dest.id},
                          extra: dest,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── Quick Stats ─────────────────────────────────────
              const Text('สถิติการเดินทาง',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                        icon: Icons.flight,
                        label: 'Trip',
                        value: '5',
                        color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                        icon: Icons.place,
                        label: 'Country',
                        value: '3',
                        color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                        icon: Icons.favorite,
                        label: 'Saved',
                        value: '12',
                        color: Colors.pink),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// การ์ดแสดงสถิติตัวเลขเดียว (Trip / Country / Saved) — แยกเป็น Widget ของตัวเอง
// เพื่อลดการเขียนโค้ดซ้ำ 3 รอบใน Row ด้านบน (DRY: Don't Repeat Yourself)
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
```

> **🎯 Checkpoint 4.3 — แก้ไขโค้ด (ประเมินตามวัตถุประสงค์ข้อ 1):**
> 1. เปลี่ยน Featured Section จากที่โชว์แค่ 3 รายการแรก (`sampleDestinations.take(3)`) ให้แสดง `sampleDestinations` **ทั้งหมด** ใน `ListView.separated` แนวนอนเดิม
> 2. เพิ่ม Section ใหม่ด้านล่าง Quick Stats ชื่อ "รีวิวยอดนิยม" ที่ใช้ `Column` ครอบ `ListView` แนวตั้งแบบ `shrinkWrap: true` และ `physics: NeverScrollableScrollPhysics()` แสดงชื่อ Destination 3 อันดับที่ `rating` สูงสุด (ต้องเขียน Logic Sort เอง)
> 3. เขียน Comment อธิบายว่าทำไมต้องใส่ `shrinkWrap: true` และ `NeverScrollableScrollPhysics()` เมื่อวาง `ListView` ซ้อนอยู่ใน `Column` ที่อยู่ใน `SingleChildScrollView` อีกที (จะเกิดอะไรขึ้นถ้าไม่ใส่)

บันทึกรูปผลการทดลอง

<img width="837" height="875" alt="image" src="https://github.com/user-attachments/assets/0cc0e24c-0fa5-4b50-b329-b18e61871ba9" />
<img width="832" height="823" alt="image" src="https://github.com/user-attachments/assets/4123aa93-3152-4ecd-9651-528e8d63f68e" />
<img width="845" height="822" alt="image" src="https://github.com/user-attachments/assets/f93ba4a2-45ef-4580-b9fe-86f4cddc221e" />
<img width="846" height="823" alt="image" src="https://github.com/user-attachments/assets/9d8d40b7-8f8f-4c25-9c53-e2719a47caef" />
<img width="842" height="823" alt="image" src="https://github.com/user-attachments/assets/2b082110-ef36-4300-bcd6-ba00c0393b67" />
<img width="842" height="822" alt="image" src="https://github.com/user-attachments/assets/45c3d517-4d5d-424f-82b8-8873d752c5ef" />
<img width="842" height="822" alt="image" src="https://github.com/user-attachments/assets/babb2a5a-57f4-4320-b899-484678e54c7b" />
<img width="852" height="820" alt="image" src="https://github.com/user-attachments/assets/5f4a219f-1d7d-4f6a-a051-c804e8cd5283" />
<img width="837" height="826" alt="image" src="https://github.com/user-attachments/assets/32c6aef2-7631-4e8e-be67-3172781c1fb2" />
<img width="843" height="818" alt="image" src="https://github.com/user-attachments/assets/f62ccee1-0af3-4d65-8dfc-ba25aac8e10c" />
<img width="850" height="692" alt="image" src="https://github.com/user-attachments/assets/f7046ca2-7559-480b-99b5-7c4504d0e0dd" />
<img width="1911" height="967" alt="image" src="https://github.com/user-attachments/assets/46fa8507-c612-408f-8b4c-c6157573d783" />


สร้างไฟล์ `lib/screens/saved_screen.dart`:

```dart
import 'package:flutter/material.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บันทึกไว้')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 64, color: Colors.pink.shade200),
            const SizedBox(height: 16),
            const Text('ยังไม่มีรายการที่บันทึก',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
```

สร้างไฟล์ `lib/screens/profile_screen.dart`:

```dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์')),
      body: ListView(
        children: [
          // Profile Header
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(24),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 48, color: Colors.white),
                ),
                SizedBox(height: 12),
                Text('นักศึกษา Flutter',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('student@example.com',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          // Settings List
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('การแจ้งเตือน'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('ภาษา'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('เกี่ยวกับแอป'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('ออกจากระบบ',
                style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
```
บันทึกรูปผลการทดลอง
<img width="1913" height="967" alt="image" src="https://github.com/user-attachments/assets/90a0f934-e829-4b37-a9d1-855e2833d8ec" />

---

### การทดลองที่ 5 — ตั้งค่า Go Router

#### ขั้นตอนที่ 5.1 — สร้าง Router Configuration

สร้างไฟล์ `lib/router/app_router.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../screens/home_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/destination_detail_screen.dart';
import '../screens/saved_screen.dart';
import '../screens/profile_screen.dart';

// ── Scaffold Shell Wrapper ─────────────────────────────────────────
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell, // แสดง Content ของ active branch
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // goBranch เปลี่ยนไป Branch (Tab) ที่เลือก โดยที่ Stack ของ Branch อื่น ๆ ยังอยู่ครบ (ไม่ถูก Reset)
          // initialLocation: true จะรีเซ็ต Branch นั้นกลับไปหน้าแรกสุด — ใช้ตอนกด Tab เดิมซ้ำ (เหมือนแอปทั่วไปที่กด Tab ซ้ำแล้วเด้งกลับหน้าแรก)
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'สำรวจ',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'บันทึก',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}

// ── Router Definition ──────────────────────────────────────────────
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    // StatefulShellRoute.indexedStack ช่วยรักษาสภาพ State ของแต่ละ Tab
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // ── Branch 0: Home ──────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // ── Branch 1: Explore + Detail ──────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              name: 'explore',
              builder: (context, state) => const ExploreScreen(),
              routes: [
                GoRoute(
                  path: 'destinations/:id', // Sub-route path ไม่ต้องมี / นำหน้า
                  name: 'destination-detail',
                  builder: (context, state) {
                    final id = state.pathParameters['id'];
                    // Fallback ดึงข้อมูลจาก ID กรณี extra เป็น null (เช่น กด Refresh บน Web)
                    final destination = state.extra as Destination? ??
                        sampleDestinations.firstWhere(
                          (d) => d.id == id,
                          orElse: () => sampleDestinations.first,
                        );
                    return DestinationDetailScreen(destination: destination);
                  },
                ),
              ],
            ),
          ],
        ),
        // ── Branch 2: Saved ─────────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saved',
              name: 'saved',
              builder: (context, state) => const SavedScreen(),
            ),
          ],
        ),
        // ── Branch 3: Profile ───────────────────────────────────
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
  // errorBuilder ทำงานเมื่อ URL ที่ไปไม่ตรงกับ Route ใดเลยในระบบ (เช่นพิมพ์ Path ผิด)
  // ควรใช้แสดงหน้า "ไม่พบหน้า" แทนที่จะปล่อยให้แอป Crash
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('ไม่พบหน้าที่ต้องการ: ${state.error}'),
    ),
  ),
);
```

> **🎯 Checkpoint 5.1 — แก้ไขโค้ด (ประเมินตามวัตถุประสงค์ข้อ 3 และ 4):**
> 1. เพิ่ม Branch ที่ 4 ใหม่ในเมนู Bottom Navigation ชื่อ "เกี่ยวกับ" (path `/about`) ที่ชี้ไปหน้า `AboutScreen` ที่สร้างเอง (เป็น `StatelessWidget` ง่าย ๆ มี `Scaffold` + `Text` พอ) — ต้องเพิ่มทั้ง `NavigationDestination` ใน `ScaffoldWithNavBar` และ `StatefulShellBranch` ใหม่ใน `appRouter`
> 2. แก้ไข Fallback Logic ใน Route `destination-detail` จากเดิมที่ใช้ `orElse: () => sampleDestinations.first` (ซึ่งถ้าหา `id` ไม่เจอจะเด้งไปโชว์ข้อมูลผิดตัวแบบเงียบ ๆ โดยไม่แจ้งผู้ใช้) ให้เปลี่ยนไปแสดงหน้า "ไม่พบข้อมูลที่ต้องการ" แทน เมื่อหา `id` นั้นไม่เจอจริง ๆ
> 3. ทดสอบ Fallback ที่แก้ไข โดยรันแอปบน Chrome (`flutter run -d chrome`) แล้วพิมพ์ URL `/explore/destinations/999` ตรง ๆ ใน Address Bar (เป็น `id` ที่ไม่มีอยู่จริง) — ต้องเห็นหน้า "ไม่พบข้อมูลที่ต้องการ" ไม่ใช่ Error สีแดงหรือข้อมูลผิดตัว

บันทึกรูปผลการทดลอง

<img width="851" height="910" alt="image" src="https://github.com/user-attachments/assets/c0d67b82-36d2-46f4-88b7-dd4a99eea109" />
<img width="847" height="825" alt="image" src="https://github.com/user-attachments/assets/6e5d5d87-c4ea-4238-8119-4ff060fd09c2" />
<img width="852" height="828" alt="image" src="https://github.com/user-attachments/assets/d08a95be-920f-4bbc-8f1f-0fbb0962760e" />
<img width="855" height="845" alt="image" src="https://github.com/user-attachments/assets/5a96b3ac-0484-41f5-9512-b9a0416fe20e" />
<img width="850" height="850" alt="image" src="https://github.com/user-attachments/assets/50e2117f-38c7-4f29-a308-1e239d621d85" />
<img width="847" height="853" alt="image" src="https://github.com/user-attachments/assets/ad670e38-f7ec-4f10-85e4-f4a7daa25e6e" />
<img width="847" height="528" alt="image" src="https://github.com/user-attachments/assets/f050e385-431b-4171-b0a5-0f081b39f1e6" />
<img width="850" height="478" alt="image" src="https://github.com/user-attachments/assets/359c14a5-fe03-4495-9206-06a84ed003f6" />
<img width="1913" height="970" alt="image" src="https://github.com/user-attachments/assets/114f6688-a319-4d10-8fcb-1864662f98a8" />
<img width="1912" height="961" alt="image" src="https://github.com/user-attachments/assets/9b35f9e4-65ec-4832-9ef3-2ede721db59f" />

```
```

#### ขั้นตอนที่ 5.2 — ตั้งค่า main.dart

แก้ไขไฟล์ `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'router/app_router.dart';

void main() {
  runApp(const TravelApp());
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Travel App',
      debugShowCheckedModeBanner: false,
      // ── Theme Configuration ──────────────────────────────────
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // AppBar theme
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
      ),
      // ── Router Config ────────────────────────────────────────
      routerConfig: appRouter,
    );
  }
}
```

---

### การทดลองที่ 6 — รันและทดสอบ

#### ขั้นตอนที่ 6.1 — ตรวจสอบว่า Build ผ่าน

```bash
flutter analyze
# ควรไม่มี Error หลัก
```

#### ขั้นตอนที่ 6.2 — รันบน Device ที่เลือกไว้

เลือก Target Device ตามวิธีที่ตั้งค่าไว้ในสัปดาห์ที่ 1 (ไม่ต้องใช้ Android Studio):

```bash
# ตัวเลือกที่ 1: รันบน Chrome (เร็วที่สุด ไม่ต้องมี Emulator/Device)
flutter run -d chrome

# ตัวเลือกที่ 2: รันบน Android Emulator ที่สร้างด้วย avdmanager (ต้องเปิด Emulator ไว้ก่อน)
flutter run

# ตัวเลือกที่ 3: รันบนเครื่อง Android จริงที่เชื่อมต่อผ่าน adb
flutter run

# ตรวจสอบ Device ที่ตรวจพบทั้งหมดก่อนเลือก
flutter devices
```

> 💡 หรือกด `F5` ใน VS Code แล้วเลือก Device จาก Status Bar ด้านล่างขวาแทนก็ได้ เช่นเดียวกับที่ทำในสัปดาห์ที่ 1

#### ขั้นตอนที่ 6.3 — ทดสอบฟีเจอร์ต่าง ๆ

ทดสอบตามรายการและบันทึกผลการทดลองด้วยเครื่องหมาย ✅ หรือ ❌:

| # | สิ่งที่ทดสอบ | ผลที่คาดหวัง | ผลจริง |
|---|---|---|---|
| 1 | เปิดแอป | เห็น Home Screen + Bottom Navigation Bar |✅|
| 2 | กด Tab "สำรวจ" | เปลี่ยนไป Explore Screen แสดง Grid |✅|
| 3 | พิมพ์ค้นหา "โตเกียว" | ผลการค้นหาเหลือเฉพาะโตเกียว |✅|
| 4 | กดที่ Card ใด ๆ | เปิด Detail Screen พร้อมข้อมูลถูกต้อง |✅|
| 5 | กด Back บน Detail | กลับมา Explore Screen |✅|
| 6 | กด Tab "หน้าหลัก" | กลับหน้าหลัก โดยที่ Stack ใน Explore ยังไม่หาย |✅|
| 7 | กดหัวใจบน Detail | Snackbar แจ้งบันทึกสำเร็จ |✅|
| 8 | กด "จองเลย" บน Detail | Dialog แสดงการจองสำเร็จ |✅|
| 9 | กด "กลับหน้าหลัก" ใน Dialog | Navigate กลับ Home |✅|
| 10 | ปรับความกว้างหน้าจอ (ดูวิธีตาม Device ด้านล่าง) | Grid ปรับ Column Count ตาม M3 Breakpoint |✅|
| 11 | Refresh หน้า Detail บน Chrome (กด `F5` ขณะอยู่ที่หน้ารายละเอียด) | ข้อมูล Destination ยังแสดงถูกต้อง ไม่ใช่ null/Error (Fallback ทำงาน) |✅|
| 12 | เลื่อนดู Featured List แนวนอนบนหน้า Home (หลังทำ Checkpoint 4.3) | เห็นครบทุก Destination เลื่อนซ้าย-ขวาได้ลื่นไหล |✅|
| 13 | พิมพ์ URL `/explore/destinations/999` ตรง ๆ (หลังทำ Checkpoint 5.1) | แสดงหน้า "ไม่พบข้อมูลที่ต้องการ" ไม่ใช่ Error สีแดง |✅|
| 14 | กด Tab "เกี่ยวกับ" ที่เพิ่มใหม่ (หลังทำ Checkpoint 5.1) | เปลี่ยนไปหน้า AboutScreen ได้ |✅|
| 15 | เทียบค่า `MediaQuery.size.width` กับ `constraints.maxWidth` (ตาม Checkpoint 4.1) | บันทึกค่าที่สังเกตได้และสรุปความแตกต่าง |✅ จากการทดลอง Checkpoint 4.1 พบว่า MediaQuery.size.width มีค่า 1536.0 dp และ constraints.maxWidth มีค่า 1536.0 dp ซึ่งมีค่าเท่ากัน เนื่องจากหน้า Explore แสดงผลเต็มพื้นที่หน้าจอ ทำให้ความกว้างของหน้าจอโดยรวมและพื้นที่ที่ LayoutBuilder ได้รับจาก Parent มีขนาดเท่ากัน|

---

> 📝 **วิธีทดสอบข้อ 10 ตาม Device ที่ใช้ (ไม่มี Android Studio):**
> - **Chrome:** ปรับขนาดหน้าต่าง Browser ให้แคบ/กว้างขึ้น หรือเปิด DevTools (`F12`) แล้วใช้ Device Toolbar (`Ctrl+Shift+M`) จำลองขนาดจอต่าง ๆ
> - **Android Emulator (จาก `avdmanager`):** กด `Ctrl+ลูกศรซ้าย` หรือ `Ctrl+ลูกศรขวา` เพื่อหมุนจอ
> - **เครื่อง Android จริง:** หมุนตัวเครื่องโดยตรง (ต้องเปิด Auto-rotate ไว้)

### การทดลองที่ 7 — ทดลองเพิ่มเติม 

#### ขั้นตอนที่ 7.1 — เพิ่ม Category Filter

เพิ่ม Filter Chip แนวนอนใน ExploreScreen ระหว่าง Search Bar กับ Grid:

```dart
// เพิ่มใน State ของ _ExploreScreenState
String _selectedTag = 'ทั้งหมด';
final List<String> _allTags = ['ทั้งหมด', 'ทะเล', 'ธรรมชาติ', 'วัฒนธรรม', 'อาหาร', 'ช้อปปิ้ง'];

// Widget Filter:
SizedBox(
  height: 40,
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: _allTags.length,
    separatorBuilder: (_, __) => const SizedBox(width: 8),
    itemBuilder: (context, index) {
      final tag = _allTags[index];
      final isSelected = tag == _selectedTag;
      return FilterChip(
        label: Text(tag),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedTag = tag),
      );
    },
  ),
),
```

#### ขั้นตอนที่ 7.2 — เพิ่ม Transition Animation

แก้ใน GoRoute ของ Detail Screen เพิ่ม `pageBuilder`:

```dart
GoRoute(
  path: 'destinations/:id',
  name: 'destination-detail',
  pageBuilder: (context, state) {
    final id = state.pathParameters['id'];
    final destination = state.extra as Destination? ??
        sampleDestinations.firstWhere((d) => d.id == id);

    return CustomTransitionPage(
      child: DestinationDetailScreen(destination: destination),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  },
),
```

---

### การทดลองที่ 8 — โจทย์ท้าทาย: ทำ Saved Screen ให้ใช้งานได้จริง (Independent Challenge)

> ⚠️ **ส่วนนี้ไม่มีโค้ดตัวอย่างให้คัดลอก** ให้นักศึกษาออกแบบและเขียนเอง โดยใช้ความรู้เรื่อง Layout Widgets, Responsive Design และ Go Router ที่ฝึกมาตลอดใบงานนี้

**โจทย์:** ปัจจุบันหน้า "บันทึกไว้" (`SavedScreen`) เป็นแค่ Static UI ที่ไม่มีข้อมูลจริง ให้ทำการเขียนโค้ดเพื่อทำให้ฟีเจอร์นี้ **ใช้งานได้จริง** ตามข้อกำหนดต่อไปนี้:

1. **เพิ่มปุ่มบันทึก :** เพิ่ม Icon รูปหัวใจบน `DestinationCard` หรือ `DestinationDetailScreen` (เลือกจุดใดจุดหนึ่งหรือทั้งสองจุด) ให้กดแล้วสลับสถานะ "บันทึกแล้ว / ยังไม่บันทึก" ได้ โดยไอคอนต้องเปลี่ยนรูปตามสถานะ (เช่น `Icons.favorite` ↔ `Icons.favorite_border`)

2. **จัดการ State ที่ใช้ร่วมกันข้ามหน้า:** ข้อมูลว่า Destination ไหนถูกบันทึกไว้บ้าง ต้องเข้าถึงได้จากทั้ง Explore Screen, Detail Screen และ Saved Screen พร้อมกัน (คำใบ้: ลองสร้าง Class ง่าย ๆ เก็บ `Set<String> savedIds` ไว้เป็นตัวแปร Global หรือส่งผ่าน Constructor — ยังไม่ต้องใช้ State Management Library ใด ๆ ในระดับนี้)

3. **แสดงผลใน Saved Screen (Objective 1 & 2):** ให้ `SavedScreen` แสดงรายการ Destination ที่ถูกบันทึกไว้จริง โดยใช้ `GridView` หรือ `ListView` (เลือกอย่างใดอย่างหนึ่ง) และต้องปรับจำนวนคอลัมน์/Layout ตามขนาดหน้าจอด้วย `LayoutBuilder` เหมือนที่ทำใน Explore Screen — ถ้ายังไม่มีรายการที่บันทึกไว้ ให้แสดง Empty State เหมือนเดิม

4. **Navigation (Objective 3 & 4):** กดที่ Card ใน Saved Screen แล้วต้องไปหน้า Detail ได้ถูกต้อง โดยใช้ `context.pushNamed('destination-detail', ...)` แบบเดียวกับหน้าอื่น ๆ

5. **เขียน Comment อธิบายโค้ดของตัวเอง** อย่างน้อย 3 จุดที่คิดว่าซับซ้อนที่สุด เพื่อให้เพื่อนหรืออาจารย์อ่านเข้าใจการทำงานได้

> 💡 **หลีกเลี่ยงการขอโค้ดทั้งไฟล์จาก AI** ให้ลองเขียนเองก่อน ถ้าติดจริง ๆ ให้ถามเป็นจุด ๆ ไป (เช่น "ทำไม setState ใน Widget อื่นไม่ทำให้ Saved Screen รีเฟรช") จะได้เรียนรู้มากกว่าการคัดลอกมาทั้งหมด

บันทึกรูปผลการทดลอง

<img width="847" height="758" alt="image" src="https://github.com/user-attachments/assets/2e677728-fb3f-4dc8-85c6-e16d88f7e198" />
<img width="847" height="898" alt="image" src="https://github.com/user-attachments/assets/60211f52-ae44-479c-af3b-6a1929248570" />
<img width="837" height="827" alt="image" src="https://github.com/user-attachments/assets/dee25488-d26c-4511-b146-cf473f9f498d" />
<img width="852" height="886" alt="image" src="https://github.com/user-attachments/assets/dcfc08f0-9ef1-40ae-a98c-67fb0e5a4cb7" />
<img width="853" height="530" alt="image" src="https://github.com/user-attachments/assets/28ef28ac-5123-45a3-bc48-205d75e90691" />
<img width="851" height="902" alt="image" src="https://github.com/user-attachments/assets/32813662-6c00-4e82-b2ae-8a63b7fb35aa" />
<img width="858" height="830" alt="image" src="https://github.com/user-attachments/assets/9a162d66-706a-42d0-b944-1745e880088a" />
<img width="848" height="831" alt="image" src="https://github.com/user-attachments/assets/026bdaab-516a-45b9-89f0-471f5bf90378" />
<img width="850" height="827" alt="image" src="https://github.com/user-attachments/assets/9564f0ce-8435-4eb2-8143-de712bcc95d3" />
<img width="846" height="831" alt="image" src="https://github.com/user-attachments/assets/8b930da8-60b5-4b2d-b120-76d57a628d6b" />
<img width="847" height="827" alt="image" src="https://github.com/user-attachments/assets/823e7b64-d25f-4a18-9246-ee8da15404b2" />
<img width="847" height="833" alt="image" src="https://github.com/user-attachments/assets/59fc7f2e-562c-4e44-907a-8ce181a7b8fc" />
<img width="848" height="830" alt="image" src="https://github.com/user-attachments/assets/feed8778-b02a-4792-8dfb-d2dc0ff77eef" />
<img width="842" height="595" alt="image" src="https://github.com/user-attachments/assets/f22cfeff-0116-4785-8f3e-b078b5d32384" />
<img width="1915" height="973" alt="image" src="https://github.com/user-attachments/assets/482fb8f6-2cad-4418-a513-5768c3ea80fd" />
<img width="1915" height="965" alt="image" src="https://github.com/user-attachments/assets/ba106a2b-276a-4785-a65b-7f01e7269482" />
<img width="1912" height="958" alt="image" src="https://github.com/user-attachments/assets/1f774ae3-9062-4554-baf6-87ae5263e5e3" />
<img width="1915" height="963" alt="image" src="https://github.com/user-attachments/assets/6cfb9709-4365-4715-9cdd-6cd93ef8d99b" />
<img width="1913" height="970" alt="image" src="https://github.com/user-attachments/assets/fc2f2c2a-fc87-462e-a12e-40d3e612a00b" />

```
---
```

## 📝 คำถามท้ายใบงาน

**ตอบคำถามต่อไปนี้:**

1. `LayoutBuilder` ต่างกับ `MediaQuery` อย่างไร? มีหลักการเลือกใช้แต่ละแบบในสถานการณ์ใด?
```text
LayoutBuilder ใช้ดูขนาดพื้นที่ที่ Widget นั้นได้รับจริง ๆเหมาะกับการปรับ Layout ของ Widget เช่น จำนวน Column ของ Gridหรือการเปลี่ยนรูปแบบ Card ตามพื้นที่ที่มี

ส่วน MediaQuery ใช้ดูข้อมูลของหน้าจอโดยรวม เช่น ความกว้าง ความสูงหรือการหมุนหน้าจอ

ถ้าต้องการรู้ว่า Widget มีพื้นที่ให้ใช้เท่าไร ให้ใช้ LayoutBuilderแต่ถ้าต้องการรู้ข้อมูลของหน้าจอโดยรวม ให้ใช้ MediaQuery
```
2. ทำไม Go Router ถึงใช้ `StatefulShellRoute` แทน `ShellRoute` ธรรมดา? ผลต่างเรื่อง State Management คืออะไร?
```text
เพราะแอปมีหลายหน้าหลัก เช่น Explore, Saved และหน้าอื่น ๆ StatefulShellRoute สามารถแยก Navigation Stack ของแต่ละหน้าไว้ได้ เช่น ถ้าเราอยู่หน้า Explore แล้วกดไปหน้าอื่น
พอกลับมาที่ Explore ก็ยังอยู่ตำแหน่งเดิม และ State ของหน้านั้นยังอยู่ แต่ ShellRoute ธรรมดาจะไม่ได้จัดการ State ของแต่ละ Branch แบบแยกกัน ทำให้เมื่อเปลี่ยนหน้าอาจต้องสร้างหน้าใหม่อีกครั้ง
```
3. ในโค้ด `DestinationCard` เหตุใดจึงใช้ `Expanded` ครอบ `Text` ชื่อ Destination ? จะเกิดอะไรขึ้นถ้าลบออก?
```text
ใช้ Expanded เพื่อให้ Text ชื่อ Destination สามารถใช้พื้นที่ที่เหลือ ภายใน Row ได้ และช่วยป้องกันข้อความไปชนกับ Widget อื่น เช่น ปุ่มหัวใจ ถ้าลบ Expanded ออก แล้วชื่อสถานที่ยาวเกินพื้นที่ Text อาจล้นออกนอกพื้นที่ หรือเกิดปัญหา RenderFlex overflow ทำให้หน้าจอมีแถบเหลืองดำแจ้งเตือน
```
4. การส่งข้อมูลผ่าน `extra` ของ Go Router มีข้อจำกัดอะไรกรณี Deep Link / Web Refresh? และแก้ปัญหานี้ได้อย่างไร?
```text
extra เป็นการส่ง Object ไปพร้อมกับการ Navigate ภายในแอป แต่ข้อมูลใน extra ไม่ได้อยู่ใน URL ดังนั้นถ้าเปิดหน้าแบบ Deep Link หรือกด Refresh บน Web ข้อมูลที่อยู่ใน extra อาจหายไป ทำให้หน้า Detail ไม่มีข้อมูลที่ต้องใช้ วิธีแก้คือส่ง ID ของ Destination ไปใน URL เช่น /destination/123 แล้วให้หน้า Detail ใช้ ID นี้ไปดึงข้อมูลจาก Database หรือ API อีกครั้ง ส่วน extra สามารถใช้เพื่อส่งข้อมูลที่มีอยู่แล้วเพื่อให้เปิดหน้าได้เร็วขึ้น แต่ไม่ควรพึ่ง extra อย่างเดียวถ้าต้องรองรับ Deep Link หรือ Web Refresh
```
5. วาด Navigation Hierarchy ของแอปนี้ (สามารถวาดบนกระดาษแล้วถ่ายรูปส่งได้)
```text
GoRouter (Root Navigation)
└── StatefulShellRoute.indexedStack
    │   └── Bottom Navigation
    │
    ├── Branch 0 : Home
    │   └── '/' → HomeScreen
    │
    ├── Branch 1 : Explore
    │   └── '/explore' → ExploreScreen
    │       └── 'destinations/:id'
    │           └── DestinationDetailScreen
    │               ├── กดหัวใจ → บันทึก
    │               └── กดจองเลย
    │                   └── Booking Dialog
    │                       └── กลับหน้า Home
    │
    ├── Branch 2 : Saved
    │   └── '/saved' → SavedScreen
    │       └── Saved Destination
    │           └── DestinationDetailScreen
    │
    └── Branch 3 : Profile
        └── '/profile' → ProfileScreen
```
---

## 📤 การส่งงาน

1. Push โค้ดขึ้น GitHub Repository ส่วนตัว (Branch: `week04-layout-navigation`) 
2. สร้าง Pull Request พร้อมเขียน Description ว่าทำอะไรไปบ้าง (รวมถึงสรุปสั้น ๆ ว่าการทดลองที่ 8 ทำอะไรสำเร็จบ้าง)


**กำหนดส่ง:** ก่อนเรียนในสัปดาห์ถัดไป

---

## 🔗 เอกสารอ้างอิง

- [Go Router Documentation](https://pub.dev/packages/go_router)
- [Flutter Layout Guide](https://docs.flutter.dev/ui/layout)
- [Material Design 3 — Navigation](https://m3.material.io/components/navigation-bar/overview)
- [Flutter Cookbook — Navigation](https://docs.flutter.dev/cookbook/navigation)
