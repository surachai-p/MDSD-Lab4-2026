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
│   │   └── destination.dart         ← Data Model & Sample Data + findDestinationById()
│   ├── services/
│   │   └── saved_store.dart         ← [การทดลองที่ 8] State ที่ใช้ร่วมกันข้ามหน้า
│   ├── screens/
│   │   ├── home_screen.dart         ← หน้าหลัก + Featured Items + รีวิวยอดนิยม
│   │   ├── explore_screen.dart      ← รายการ Destination (Responsive Grid + Filter)
│   │   ├── destination_detail_screen.dart ← รายละเอียดสถานที่
│   │   ├── destination_not_found_screen.dart ← [Checkpoint 5.1] หน้า "ไม่พบข้อมูลที่ต้องการ"
│   │   ├── saved_screen.dart        ← [การทดลองที่ 8] รายการที่บันทึก (ใช้งานได้จริง)
│   │   ├── profile_screen.dart      ← Profile
│   │   └── about_screen.dart        ← [Checkpoint 5.1] Branch ที่ 5
│   └── widgets/
│       └── destination_card.dart    ← Reusable Card Widget
├── test/
│   └── widget_test.dart             ← Widget Test 16 เคส ครอบคลุมทุก Checkpoint
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
```image
📸 ต้องแคป 3 รูป — วางแทนบรรทัดนี้

[รูป 1 | โค้ด] travel_app/lib/widgets/destination_card.dart  บรรทัด 43-95
   ต้องเห็น: Comment [Checkpoint 3 ข้อ 3] ที่อธิบายว่า Positioned เป็น
             ParentDataWidget ที่มีแต่ Stack เท่านั้นที่อ่านได้ (บรรทัด 45-56)
             + Positioned(bottom: 8, left: 8) ของ Rating Badge (บรรทัด 71-73)

[รูป 2 | โค้ด] travel_app/lib/widgets/destination_card.dart  บรรทัด 204-222
   ต้องเห็น: Row ใหม่ใต้ Tags = Icon(Icons.bed) + Expanded(Text('พร้อมเข้าพัก'))

[รูป 3 | ผลรัน] รันแอป (flutter run -d chrome) -> กด Tab "สำรวจ"
   ซูมการ์ด 1 ใบให้ชัด ต้องเห็นครบ 2 จุด:
     (ก) ป้าย ⭐ 4.7 ย้ายมาอยู่ "มุมซ้ายล่าง" ของรูปแล้ว (เดิมอยู่ขวาบน)
     (ข) บรรทัด 🛏 พร้อมเข้าพัก อยู่ใต้แถว Tags
   * มุมขวาบนของรูปจะมีปุ่มหัวใจแทน ซึ่งเป็นของการทดลองที่ 8
```
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
```image
📸 ต้องแคป 3 รูป — วางแทนบรรทัดนี้

[รูป 1 | โค้ด] travel_app/lib/screens/explore_screen.dart  บรรทัด 113-157
   ต้องเห็นครบ 3 อย่าง:
     (ก) บรรทัด 129-130 = Breakpoint ระดับที่ 4 -> crossAxisCount = 5
     (ข) บรรทัด 117-119 = final screenWidth = MediaQuery.of(context).size.width;
     (ค) บรรทัด 140-156 = Comment สรุปความต่างของ MediaQuery กับ LayoutBuilder

[รูป 2 | ผลรัน จอแคบ] flutter run -d chrome -> Tab "สำรวจ" -> ย่อหน้าต่างให้แคบ (< 600 dp)
   ต้องเห็น: กรอบสีเหลืองด้านบนโชว์ค่าทั้ง 3 บรรทัด + Grid เป็น 2 คอลัมน์

[รูป 3 | ผลรัน จอกว้าง] ขยายหน้าต่างเต็มจอ (>= 1200 dp)
   ต้องเห็น: ค่าในกรอบสีเหลืองเปลี่ยนไป + Grid กลายเป็น 5 คอลัมน์

[ทางเลือก | Debug Console] แคป Debug Console ตอนย่อ-ขยายหน้าต่าง จะเห็นบรรทัด
   [Checkpoint 4.1] MediaQuery.width = ... | LayoutBuilder.maxWidth = ... | crossAxisCount = ...
   วิ่งออกมาเรื่อย ๆ (ใช้ประกอบคำตอบข้อ 15 ในตารางทดสอบ)
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
```image
📸 ต้องแคป 3 รูป — วางแทนบรรทัดนี้

[รูป 1 | โค้ด] travel_app/lib/screens/home_screen.dart  บรรทัด 12-22
   ต้องเห็น: final featured = sampleDestinations;  (เดิมคือ .take(3))
             + Logic Sort หา 3 อันดับ rating สูงสุด พร้อม Comment ว่าทำไมต้อง copy List ก่อน sort

[รูป 2 | โค้ด] travel_app/lib/screens/home_screen.dart  บรรทัด 158-190
   ต้องเห็น: Section "รีวิวยอดนิยม" + Comment [Checkpoint 4.3 ข้อ 3]
             ที่อธิบาย shrinkWrap: true และ NeverScrollableScrollPhysics()

[รูป 3 | ผลรัน] หน้า "หน้าหลัก" เลื่อนลงจนเห็น Section "รีวิวยอดนิยม"
   ต้องเห็น: อันดับ 1 โตเกียว 4.9 / อันดับ 2-3 เชียงใหม่ 4.8, สิงคโปร์ 4.8
   และเลื่อน Featured List แนวนอนไปจนสุด ให้เห็นว่ามีครบ 6 แห่ง (ใช้ตอบตารางข้อ 12 ได้ด้วย)
```

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
```image
📸 ต้องแคป 4 รูป — วางแทนบรรทัดนี้

[รูป 1 | โค้ด] travel_app/lib/router/app_router.dart  บรรทัด 56-63 และ 165-176
   ต้องเห็น: NavigationDestination "เกี่ยวกับ" ที่เพิ่มใน ScaffoldWithNavBar
             + StatefulShellBranch ตัวที่ 5 (path: '/about') ที่เพิ่มใน appRouter

[รูป 2 | โค้ด] travel_app/lib/router/app_router.dart  บรรทัด 100-125
   ต้องเห็น: Fallback Logic แบบใหม่ที่คืน DestinationNotFoundScreen เมื่อหา id ไม่เจอ
             (แทน orElse: () => sampleDestinations.first ของเดิม)

[รูป 3 | ผลรัน Tab ใหม่] กด Tab "เกี่ยวกับ" ใน Bottom Navigation
   ต้องเห็น: หน้า AboutScreen + แถบเมนูล่างมี 5 Tab และ Tab "เกี่ยวกับ" ถูกไฮไลต์อยู่

[รูป 4 | ผลรัน Deep Link] flutter run -d chrome แล้วพิมพ์ใน Address Bar:
   http://localhost:<port>/explore/destinations/999
   ต้องเห็น: หน้า "ไม่พบข้อมูลที่ต้องการ" พร้อมข้อความว่าไม่มีรหัส "999"
             และปุ่ม "กลับไปหน้าสำรวจ" — ต้องไม่ใช่จอแดงหรือข้อมูลของกรุงเทพฯ
   * แคปให้ติด Address Bar ด้วย จะได้เห็น URL ที่พิมพ์เข้าไป
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
| 1 | เปิดแอป | เห็น Home Screen + Bottom Navigation Bar | ✅ เห็น Home Screen และแถบเมนูล่าง 5 Tab |
| 2 | กด Tab "สำรวจ" | เปลี่ยนไป Explore Screen แสดง Grid | ✅ เปลี่ยนหน้าได้ Grid แสดงครบ 6 แห่ง |
| 3 | พิมพ์ค้นหา "โตเกียว" | ผลการค้นหาเหลือเฉพาะโตเกียว | ✅ เหลือการ์ดเดียว การ์ดอื่นหายหมด |
| 4 | กดที่ Card ใด ๆ | เปิด Detail Screen พร้อมข้อมูลถูกต้อง | ✅ เปิดได้ ข้อมูลตรงกับการ์ดที่กด (มี Slide Transition จากขวาตามการทดลอง 7.2) |
| 5 | กด Back บน Detail | กลับมา Explore Screen | ✅ กลับมาที่ Explore พร้อมคำค้นหาเดิม |
| 6 | กด Tab "หน้าหลัก" | กลับหน้าหลัก โดยที่ Stack ใน Explore ยังไม่หาย | ✅ สลับกลับมาแล้วยังค้างอยู่หน้า Detail เดิม (indexedStack เก็บ Stack ไว้จริง) |
| 7 | กดหัวใจบน Detail | Snackbar แจ้งบันทึกสำเร็จ | ✅ ขึ้น SnackBar "บันทึก ... แล้ว!" และไอคอนเปลี่ยนเป็นหัวใจชมพู |
| 8 | กด "จองเลย" บน Detail | Dialog แสดงการจองสำเร็จ | ✅ ขึ้น AlertDialog "จองสำเร็จ! 🎉" |
| 9 | กด "กลับหน้าหลัก" ใน Dialog | Navigate กลับ Home | ✅ กลับ Home ได้ **หลังแก้บั๊ก** — ดูหมายเหตุ ⚠️ ใต้ตาราง |
| 10 | ปรับความกว้างหน้าจอ (ดูวิธีตาม Device ด้านล่าง) | Grid ปรับ Column Count ตาม M3 Breakpoint | ✅ 2 → 3 → 4 → 5 คอลัมน์ ที่ 600 / 840 / 1200 dp |
| 11 | Refresh หน้า Detail บน Chrome (กด `F5` ขณะอยู่ที่หน้ารายละเอียด) | ข้อมูล Destination ยังแสดงถูกต้อง ไม่ใช่ null/Error (Fallback ทำงาน) | ✅ `extra` กลายเป็น null จริง แต่ Fallback ค้นจาก `pathParameters['id']` ได้ข้อมูลเดิมกลับมา |
| 12 | เลื่อนดู Featured List แนวนอนบนหน้า Home (หลังทำ Checkpoint 4.3) | เห็นครบทุก Destination เลื่อนซ้าย-ขวาได้ลื่นไหล | ✅ เลื่อนเห็นครบ 6 แห่ง (เดิม take(3) เห็นแค่ 3) |
| 13 | พิมพ์ URL `/explore/destinations/999` ตรง ๆ (หลังทำ Checkpoint 5.1) | แสดงหน้า "ไม่พบข้อมูลที่ต้องการ" ไม่ใช่ Error สีแดง | ✅ ขึ้นหน้า "ไม่พบข้อมูลที่ต้องการ" + บอกว่าไม่มีรหัส "999" + ปุ่มกลับไปหน้าสำรวจ |
| 14 | กด Tab "เกี่ยวกับ" ที่เพิ่มใหม่ (หลังทำ Checkpoint 5.1) | เปลี่ยนไปหน้า AboutScreen ได้ | ✅ เข้า AboutScreen ได้ Tab ถูกไฮไลต์ถูกต้อง |
| 15 | เทียบค่า `MediaQuery.size.width` กับ `constraints.maxWidth` (ตาม Checkpoint 4.1) | บันทึกค่าที่สังเกตได้และสรุปความแตกต่าง | ✅ ค่าที่วัดได้จริง — ดูตารางค่าใต้ตารางนี้ |


#### 🔢 ค่าที่วัดได้จริงในข้อ 15

| ความกว้างหน้าต่าง | `MediaQuery.size.width` | `LayoutBuilder.maxWidth` (ตัว Grid) | กล่องที่ซ้อนใน `Padding(16)` | `crossAxisCount` |
|---|---|---|---|---|
| 420 dp | 420.0 | 420.0 | 334.0 | 2 (Compact) |
| 700 dp | 700.0 | 700.0 | 614.0 | 3 (Medium) |
| 1000 dp | 1000.0 | 1000.0 | 914.0 | 4 (Expanded) |
| 1400 dp | 1400.0 | 1400.0 | 1314.0 | 5 (Large) |

**สรุป:** สองค่าแรก **เท่ากันเสมอ** ในหน้านี้ เพราะ `GridView` กินเต็มความกว้างของ `Scaffold body` พอดี
ไม่มีอะไรมาหักพื้นที่ระหว่างทาง — **ไม่ได้แปลว่าสองตัวนี้เหมือนกัน** แต่เป็นเพราะตำแหน่งใน Widget Tree บังเอิญไม่มี Padding คั่น
พอลองเอา `LayoutBuilder` อีกตัวไปวางซ้อนใน `Padding(horizontal: 16)` ที่อยู่ในกล่องแถบ Debug (คอลัมน์ที่ 4)
ค่าจะหายไป **86 dp ทันทีทุกขนาดจอ** ซึ่งเป็นผลรวมของทุกอย่างที่คั่นอยู่ระหว่างทาง:
margin 16×2 + padding 10×2 + border 1×2 + padding 16×2 = 86
ขณะที่ `MediaQuery` ยังเท่าเดิมไม่ขยับเลย → พิสูจน์ว่า `MediaQuery` ผูกกับ **หน้าจอ**
ส่วน `LayoutBuilder` ผูกกับ **พื้นที่ที่ Parent ยอมให้ ณ ตำแหน่งนั้นใน Widget Tree**

> ⚠️ **หมายเหตุข้อ 9 — บั๊กที่เจอระหว่างทดสอบ (สำคัญ):**
> โค้ดตัวอย่างใน `showDialog` เขียนว่า `Navigator.pop(context)` โดยใช้ `context` ของ `DestinationDetailScreen`
> แต่ `showDialog` วาง Dialog ไว้บน **root Navigator** ส่วนหน้า Detail อยู่ใน **Navigator ของ Shell Branch**
> เมื่อ `Navigator.of(context)` ไล่หา Navigator ที่ใกล้ที่สุด จึงไปเจอ Navigator ของ Branch ก่อน →
> ผลคือ **ปิดหน้า Detail ทิ้ง ส่วน Dialog ยังค้างบนจอ**
> วิธีแก้: รับ `context` ของ Dialog เองมาใช้ — `builder: (dialogContext) => ...` แล้วเรียก `Navigator.pop(dialogContext)`
> (แก้ไว้แล้วใน `lib/screens/destination_detail_screen.dart` พร้อม Comment อธิบาย)

> ✅ **วิธียืนยันผลในตารางนี้:** นอกจากกดทดสอบด้วยมือแล้ว ยังเขียน Widget Test ครอบไว้ 16 เคสที่
> `travel_app/test/widget_test.dart` ครอบคลุมข้อ 1-15 ทั้งหมด รันด้วย `flutter test` (ผ่านทั้ง 16 เคส)
> และ `flutter analyze` ไม่มี Error/Warning เหลือ

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
```image
📸 ต้องแคป 5 รูป — วางแทนบรรทัดนี้

[รูป 1 | โค้ด] travel_app/lib/services/saved_store.dart (ทั้งไฟล์)
   ต้องเห็น: Class SavedStore extends ChangeNotifier + Comment #1/#2/#3
             (นี่คือ 3 จุดที่ซับซ้อนที่สุดตามข้อ 5 ของโจทย์)

[รูป 2 | โค้ด] travel_app/lib/screens/saved_screen.dart  บรรทัด 7-62
   ต้องเห็น: ListenableBuilder ที่ครอบทั้งหน้า + LayoutBuilder ที่สลับ
             ListView (จอแคบ) / GridView (จอกว้าง) + Comment จุดซับซ้อนที่ 1-3

[รูป 3 | ผลรัน ก่อนบันทึก] Tab "บันทึก" ตอนยังไม่ได้กดหัวใจอะไรเลย
   ต้องเห็น: Empty State "ยังไม่มีรายการที่บันทึก"

[รูป 4 | ผลรัน หลังกดหัวใจ] ไป Tab "สำรวจ" กดหัวใจ 2-3 การ์ด (ไอคอนต้องเปลี่ยน
   จาก favorite_border ขาว เป็น favorite ชมพู) แล้วกลับมา Tab "บันทึก"
   ต้องเห็น: รายการที่กดไว้โผล่ครบ + ตัวเลข Saved บนหน้าหลักเปลี่ยนตาม

[รูป 5 | ผลรัน Responsive] ขยายหน้าต่างให้กว้าง >= 600 dp ขณะอยู่หน้า "บันทึก"
   ต้องเห็น: Layout สลับจาก List แนวตั้ง เป็น Grid หลายคอลัมน์
```
---

## 📝 คำถามท้ายใบงาน

**ตอบคำถามต่อไปนี้:**

1. `LayoutBuilder` ต่างกับ `MediaQuery` อย่างไร? มีหลักการเลือกใช้แต่ละแบบในสถานการณ์ใด?
```text
ทั้งคู่ใช้ดูขนาดเหมือนกัน แต่ "ดูคนละอย่าง"

MediaQuery.of(context).size.width
  - คือขนาดของทั้งหน้าต่าง/หน้าจอ (Window) ที่แอปรันอยู่
  - เรียกจาก Widget ตัวไหนในแอปก็ได้ค่าเดียวกันหมด ไม่สนว่าตัวเองอยู่ตรงไหนของ Widget Tree
  - ได้ค่าตั้งแต่ตอน build ไม่ต้องรอรอบ Layout
  - ให้ข้อมูลระดับอุปกรณ์อย่างอื่นมาด้วย เช่น orientation, textScaler,
    padding ของ Safe Area (รอยบาก/แถบสถานะ), viewInsets (คีย์บอร์ดที่เด้งขึ้นมา)

LayoutBuilder -> constraints.maxWidth
  - คือความกว้างที่ "Parent ยอมให้ Widget ตัวนี้ใช้" ณ ตำแหน่งนั้นใน Widget Tree
  - ถูกหักด้วย Padding / Margin / Border / Navigation Rail / Drawer ที่คั่นอยู่ก่อนหน้า
  - ต้องรอรอบ Layout ก่อนถึงจะรู้ค่า และ builder จะถูกเรียกใหม่ทุกครั้งที่ Constraint เปลี่ยน

หลักการเลือกใช้
  - ตัดสินใจ Layout "ภายใน Widget ตัวใดตัวหนึ่ง" เช่นจำนวนคอลัมน์ของ Grid
    หรือจะยุบ Card เป็นแนวตั้งไหม -> ใช้ LayoutBuilder เพราะสะท้อนพื้นที่จริงที่ได้รับ
  - ตัดสินใจ "ระดับทั้งแอป/ทั้งหน้า" เช่นจะใช้ Bottom Navigation หรือ Navigation Rail
    หรือจะเปิด Master-Detail 2 ฝั่งไหม -> ใช้ MediaQuery
  - ต้องการข้อมูลอุปกรณ์ที่ Constraint บอกไม่ได้ (orientation, คีย์บอร์ด,
    ขนาดตัวอักษรที่ผู้ใช้ตั้งไว้, Safe Area) -> มีแต่ MediaQuery เท่านั้นที่ให้ได้

ข้อควรระวังที่เจอจริงในใบงานนี้
  ในหน้า Explore ค่าทั้งสองตัวออกมาเท่ากันเป๊ะทุกขนาดจอ (420/700/1000/1400 dp)
  เพราะ GridView กินเต็มความกว้างของ Scaffold body พอดี ไม่มีอะไรมาคั่น
  ซึ่ง "ไม่ได้แปลว่าใช้แทนกันได้" — พอเอา LayoutBuilder อีกตัวไปวางซ้อนใน Padding
  อีกชั้น ค่าหายไป 86 dp ทันที ขณะที่ MediaQuery ยังเท่าเดิมไม่ขยับ
  ถ้าเผลอใช้ MediaQuery ตัดสินใจ Layout ของ Widget ที่อยู่ลึก ๆ จะคำนวณผิด
  เช่น การ์ดที่อยู่ในกล่องแคบ ๆ แต่คิดว่าตัวเองมีพื้นที่เท่าทั้งจอ
```
2. ทำไม Go Router ถึงใช้ `StatefulShellRoute` แทน `ShellRoute` ธรรมดา? ผลต่างเรื่อง State Management คืออะไร?
```text
ต่างกันที่ "ชะตากรรมของ State ตอนสลับ Tab"

ShellRoute (ธรรมดา)
  - มี Navigator ตัวเดียวสำหรับทุก Tab
  - พอสลับ Tab หน้าเดิมจะถูก Dispose ทิ้ง แล้วสร้างหน้าใหม่ขึ้นมาแทน
  - ผลคือ ตำแหน่ง Scroll หาย, คำที่พิมพ์ค้างใน TextField หาย,
    State ใน StatefulWidget ถูกรีเซ็ตกลับค่าเริ่มต้น
  - ที่หนักกว่านั้นคือ Navigation Stack ของ Tab นั้นหายไปด้วย
    (กดเข้า Detail ไว้ พอสลับ Tab ไปแล้วกลับมา จะเด้งกลับหน้าแรกของ Tab)

StatefulShellRoute.indexedStack
  - แต่ละ Branch มี Navigator เป็นของตัวเอง บริหารผ่าน StatefulNavigationShell
  - ใช้ IndexedStack ครอบไว้ = ทุก Branch ยังอยู่ใน Widget Tree ตลอดเวลา
    แค่ถูกซ่อน (offstage) ไม่ได้ถูกทำลาย -> State และ Element Tree อยู่ครบ (Keep-Alive)
  - สลับ Tab ด้วย navigationShell.goBranch(index) ซึ่งแค่เปลี่ยน index ที่แสดงผล

ผลต่างเรื่อง State Management ที่ทดสอบได้จริงในแอปนี้
  1. พิมพ์คำค้นหาใน Explore -> สลับไป Home -> กลับมา: คำค้นหายังอยู่
     (ถ้าเป็น ShellRoute จะหาย เพราะ _ExploreScreenState ถูกสร้างใหม่)
  2. กดการ์ดเข้าหน้า Detail -> สลับไป Tab หน้าหลัก -> กลับมา Tab สำรวจ:
     ยังค้างอยู่หน้า Detail เดิม เพราะ Stack ของ Branch ถูกเก็บไว้
     (ตรงกับข้อ 6 ในตารางทดสอบ และยืนยันด้วย Widget Test แล้ว)
  3. กด Tab เดิมซ้ำ -> ส่ง initialLocation: true เพื่อสั่งรีเซ็ต Branch นั้น
     กลับไปหน้าแรกโดยเจตนา เหมือนพฤติกรรมของแอปทั่วไป

ข้อแลกเปลี่ยน (Trade-off)
  ทุก Branch ถูก build ค้างไว้ในหน่วยความจำพร้อมกัน จึงกิน RAM มากกว่า
  และถ้า Tab ไหนมีงานหนัก (Timer / Stream / Animation) มันจะยังทำงานอยู่แม้ถูกซ่อน
  ต้องจัดการ pause/resume เองถ้าไม่อยากให้เปลืองทรัพยากร
```
3. ในโค้ด `DestinationCard` เหตุใดจึงใช้ `Expanded` ครอบ `Text` ชื่อ Destination ? จะเกิดอะไรขึ้นถ้าลบออก?
```text
เหตุผลที่ต้องใช้ Expanded ครอบ Text ชื่อ Destination

Row ตัวนั้นมีลูก 2 ตัวคือ [ชื่อสถานที่] กับ [ราคา/คืน] และตั้ง
mainAxisAlignment: MainAxisAlignment.spaceBetween ไว้

Row จะส่ง Constraint แบบ "กว้างได้ไม่จำกัด (unbounded)" ให้ลูกที่ไม่ใช่ Flex
ลูกจึงขอขนาดตามเนื้อหาจริงของตัวเอง (intrinsic width) ได้เต็มที่
ถ้าชื่อยาว Text จะขอความกว้างเกินที่ Row มีอยู่ -> ผลรวมของลูกเกินความกว้าง Row

Expanded (flex: 1) เปลี่ยนกติกาเป็น
  1. ให้ Row วัดลูกที่ไม่ใช่ Flex ก่อน (ในที่นี้คือ Text ราคา)
  2. พื้นที่ "ที่เหลือ" ทั้งหมดถูกบังคับยัดให้ Text ชื่อ เป็น tight constraint
  3. Text จึงรู้ขอบเขตของตัวเองแน่นอน และทำงานร่วมกับ
     overflow: TextOverflow.ellipsis ได้ คือตัดท้ายเป็น "..." เมื่อยาวเกิน

ถ้าลบ Expanded ออกจะเกิดอะไรขึ้น
  - ชื่อสั้น (เช่น "ภูเก็ต") -> ยังดูปกติ มองไม่ออกว่ามีปัญหา
  - ชื่อยาว (เช่น "กรุงเทพมหานคร อมรรัตนโกสินทร์") -> Row ล้น
    ขึ้นแถบลายทางเหลือง-ดำ "RenderFlex overflowed by N pixels on the right"
    พร้อม Error ใน Debug Console
  - overflow: ellipsis จะไม่ทำงาน เพราะ Text ไม่มีขอบเขตให้ตัด
    (มันคิดว่าตัวเองมีที่ไม่จำกัด เลยไม่เห็นความจำเป็นต้องตัด)
  - ข้อความราคาจะถูกดันหลุดออกนอกการ์ด หรือถูกบังจนอ่านไม่ได้

จุดที่ใช้หลักการเดียวกันในใบงานนี้
  แถว "พร้อมเข้าพัก" ที่เพิ่มตาม Checkpoint 3 ข้อ 2 ก็ใช้ Expanded ด้วยเหตุผลเดียวกัน
  และหัวข้อ Section ในหน้า Home เปลี่ยนมาใช้ Flexible เพื่อกัน Row ล้นบนจอแคบ
  ความต่าง: Expanded = ต้องกินพื้นที่ที่เหลือให้หมด, Flexible = กินได้แต่ไม่บังคับ
```
4. การส่งข้อมูลผ่าน `extra` ของ Go Router มีข้อจำกัดอะไรกรณี Deep Link / Web Refresh? และแก้ปัญหานี้ได้อย่างไร?
```text
ข้อจำกัดของการส่งข้อมูลผ่าน extra

extra เป็น Object ที่อยู่ใน "หน่วยความจำของแอปที่กำลังรันอยู่" เท่านั้น
มันไม่ได้ถูกเข้ารหัสลงไปใน URL และโดย default ก็ไม่ได้ถูก Serialize เก็บไว้ที่ไหน
ดังนั้นทุกกรณีที่ Route ถูกสร้างขึ้นใหม่โดยไม่ผ่านการกดในแอป extra จะเป็น null

  1. กด F5 / Refresh หน้าเว็บ -> แอปทั้งตัวถูกโหลดใหม่ ข้อมูลใน Memory หายหมด
  2. เปิด Deep Link จากลิงก์ภายนอก (แชท อีเมล QR Code)
  3. Copy URL ไปเปิดในแท็บใหม่ หรือกด Bookmark ที่เก็บไว้
  4. กดปุ่ม Back/Forward ของ Browser ข้ามไปยัง Entry ที่ extra ไม่ได้ถูกเก็บไว้
  5. แอปถูกระบบ Kill ตอนอยู่เบื้องหลัง แล้วผู้ใช้เปิดกลับมา (Process Death)

ถ้าเขียน  final d = state.extra as Destination;  ตรง ๆ -> จะ Crash ทันที
เพราะ null ไม่สามารถ cast เป็น Destination ได้

วิธีแก้ที่ใช้ในใบงานนี้ (3 ชั้น)
  ชั้นที่ 1: ใส่ข้อมูลที่ "จำเป็นต่อการหาข้อมูลกลับมา" ไว้ใน URL เสมอ
            -> path: 'destinations/:id' ทำให้ id ติดไปกับ URL ตลอด
  ชั้นที่ 2: ใช้ extra เป็นแค่ "ทางลัดเพื่อความเร็ว" ไม่ใช่แหล่งข้อมูลหลัก
            final extra = state.extra;
            final destination = extra is Destination      // ใช้ is ปลอดภัยกว่า as
                ? extra                                   // มี extra -> ใช้เลย ไม่ต้องค้น
                : findDestinationById(id);                // ไม่มี -> ค้นจาก id
  ชั้นที่ 3: จัดการกรณี "ค้นแล้วไม่เจอ" ให้ชัดเจน
            ถ้า findDestinationById คืน null -> แสดงหน้า "ไม่พบข้อมูลที่ต้องการ"
            (ตาม Checkpoint 5.1 ข้อ 2) แทน orElse: () => sampleDestinations.first
            ซึ่งจะเด้งไปโชว์ข้อมูลผิดตัวแบบเงียบ ๆ โดยผู้ใช้ไม่รู้ตัว

หมายเหตุเพิ่มเติม
  - ในระบบจริง ชั้นที่ 2 ควรเป็นการเรียก API หรืออ่านจาก Local Database
    ซึ่งเป็น async จึงควรใช้ FutureBuilder ครอบ พร้อมสถานะ Loading / Error
  - ห้ามใส่ข้อมูลที่ "หาคืนมาไม่ได้" ลงไปใน extra เด็ดขาด เพราะพอ Refresh แล้วหายถาวร
  - ถ้าจำเป็นต้องส่งข้อมูลยาวมากและไม่อยากโชว์ใน URL ให้เก็บลง State Management
    หรือ Local Storage แล้วส่งแค่ key ผ่าน path parameter แทน
```
5. วาด Navigation Hierarchy ของแอปนี้ (สามารถวาดบนกระดาษแล้วถ่ายรูปส่งได้)
```text
Navigation Hierarchy ของ Travel App (หลังทำครบทุก Checkpoint)

MaterialApp.router
  └── GoRouter  (initialLocation: '/')
       │
       ├── StatefulShellRoute.indexedStack
       │     └── builder -> ScaffoldWithNavBar   (Scaffold + NavigationBar 5 ปุ่ม)
       │          │        body = navigationShell (IndexedStack เก็บทุก Branch ไว้)
       │          │
       │          ├── Branch 0  [Tab: หน้าหลัก]
       │          │     └── GoRoute  '/'                name: 'home'
       │          │           └── HomeScreen
       │          │                 ├── Featured ListView แนวนอน (6 แห่ง)
       │          │                 ├── Quick Stats (Saved ผูกกับ savedStore)
       │          │                 └── รีวิวยอดนิยม (Top 3 by rating)
       │          │
       │          ├── Branch 1  [Tab: สำรวจ]
       │          │     └── GoRoute  '/explore'         name: 'explore'
       │          │           └── ExploreScreen (Search + FilterChip + Responsive Grid)
       │          │                 │
       │          │                 └── GoRoute  'destinations/:id'
       │          │                       name: 'destination-detail'
       │          │                       pageBuilder -> CustomTransitionPage (Slide จากขวา)
       │          │                       ├── พบข้อมูล    -> DestinationDetailScreen
       │          │                       └── ไม่พบข้อมูล -> DestinationNotFoundScreen
       │          │
       │          ├── Branch 2  [Tab: บันทึก]
       │          │     └── GoRoute  '/saved'           name: 'saved'
       │          │           └── SavedScreen
       │          │                 ├── ว่าง     -> Empty State
       │          │                 ├── จอแคบ   -> ListView 1 คอลัมน์
       │          │                 └── จอกว้าง -> GridView 3/4/5 คอลัมน์
       │          │
       │          ├── Branch 3  [Tab: โปรไฟล์]
       │          │     └── GoRoute  '/profile'         name: 'profile'
       │          │           └── ProfileScreen
       │          │
       │          └── Branch 4  [Tab: เกี่ยวกับ]   << เพิ่มใหม่ตาม Checkpoint 5.1
       │                └── GoRoute  '/about'           name: 'about'
       │                      └── AboutScreen
       │
       └── errorBuilder -> หน้า "ไม่พบหน้าที่ต้องการ"  (URL ที่ไม่ตรงกับ Route ใดเลย)


เส้นทางการนำทางระหว่างหน้า (Navigation Flow)

  [Tab ใด ๆ] --goBranch(index)--> [Tab อื่น]            สลับ Tab, Stack เดิมไม่หาย
  HomeScreen --context.go('/explore')--> ExploreScreen   ปุ่ม "ดูทั้งหมด" (เปลี่ยน Branch)
  ExploreScreen --context.pushNamed('destination-detail')--> Detail  (Push ซ้อน มีปุ่ม Back)
  HomeScreen    --context.pushNamed('destination-detail')--> Detail
  SavedScreen   --context.pushNamed('destination-detail')--> Detail
  Detail --context.pop()--> หน้าก่อนหน้า        (ถ้า pop ไม่ได้ -> go('/explore'))
  Detail --Dialog "กลับหน้าหลัก"--> Navigator.pop(dialogContext) แล้ว context.go('/')
  NotFound --context.go('/explore')--> ExploreScreen


ระดับของหน้าจอ (Navigation Depth)

  ระดับ 1 (Tab)     หน้าหลัก | สำรวจ | บันทึก | โปรไฟล์ | เกี่ยวกับ
                    สลับแนวนอน ไม่มีปุ่ม Back เห็น Bottom Navigation ตลอด
  ระดับ 2 (Detail)  DestinationDetailScreen / DestinationNotFoundScreen
                    Push ซ้อนขึ้นมา มีปุ่ม Back เป็นลูกของ Branch "สำรวจ"
  ระดับ 3 (Modal)   AlertDialog "จองสำเร็จ"
                    อยู่บน root Navigator ไม่ใช่ Navigator ของ Branch
                    (เหตุผลที่ต้อง pop ด้วย dialogContext — ดูหมายเหตุท้ายตารางทดสอบ)

หมายเหตุ: ข้อนี้โจทย์อนุญาตให้วาดบนกระดาษแล้วถ่ายรูปส่งได้
          ถ้าจะวาดมือ ให้ลอกโครงสร้างด้านบนลงกระดาษแล้วแคปรูปมาแปะเพิ่มได้เลย
```
---

## 📤 การส่งงาน

1. Push โค้ดขึ้น GitHub Repository ส่วนตัว (Branch: `week04-layout-navigation`) 
2. สร้าง Pull Request พร้อมเขียน Description ว่าทำอะไรไปบ้าง (รวมถึงสรุปสั้น ๆ ว่าการทดลองที่ 8 ทำอะไรสำเร็จบ้าง)


**กำหนดส่ง:** ก่อนเรียนในสัปดาห์ถัดไป

---

### ✅ Checklist ก่อนส่ง

- [ ] แคปรูปครบทุกช่อง `image` (Checkpoint 3 / 4.1 / 4.3 / 5.1 และการทดลองที่ 8) — รวม 18 รูป
- [ ] `flutter analyze` ไม่มี Error/Warning
- [ ] `flutter test` ผ่านครบ 16 เคส
- [ ] สร้าง Branch: `git checkout -b week04-layout-navigation`
- [ ] Push ขึ้น GitHub แล้วเปิด Pull Request พร้อม Description ด้านล่าง

### 📄 ร่าง Pull Request Description (คัดลอกไปวางได้เลย)

```markdown
## Week 04 — Flutter Layout & Navigation (Travel App)

สร้าง Multi-screen Travel App ด้วย Flutter + Go Router 14 ตามใบงานการทดลองที่ 4
ทำครบทุกการทดลอง (1-8) รวมถึงทุก Checkpoint และการทดลองเพิ่มเติม

### การทดลองที่ 1-2 — Setup & Data Model
- สร้างโปรเจกต์ travel_app + เพิ่ม go_router ^14.0.0
- สร้าง `Destination` model แบบ Immutable พร้อมข้อมูลตัวอย่าง 6 แห่ง
- เพิ่ม `findDestinationById()` ที่คืน `null` เมื่อไม่พบ (ใช้กับ Fallback ของ Router)

### การทดลองที่ 3 + Checkpoint 3 — DestinationCard
- ย้าย Rating Badge จากมุมขวาบนไปมุมซ้ายล่าง (`Positioned(bottom: 8, left: 8)`)
- เพิ่มแถว `Icons.bed` + `Expanded(Text('พร้อมเข้าพัก'))` ใต้ Tags
- เขียน Comment อธิบายว่า `Positioned` เป็น ParentDataWidget ที่มีแต่ `Stack`
  เท่านั้นที่อ่านได้ ถ้าเอาไปวางนอก Stack จะพังด้วย "Incorrect use of ParentDataWidget"

### การทดลองที่ 4 + Checkpoint 4.1 / 4.3 — Screens
- **Explore:** เพิ่ม Breakpoint ระดับที่ 4 (Large >= 1200 dp -> 5 คอลัมน์)
  ครบเป็น 2/3/4/5 คอลัมน์ และเพิ่มแถบ Debug เทียบ `MediaQuery.size.width`
  กับ `LayoutBuilder constraints.maxWidth` พร้อมสรุปความต่างเป็น Comment
- **Home:** เปลี่ยน Featured จาก `.take(3)` เป็นแสดงทั้งหมด
  และเพิ่ม Section "รีวิวยอดนิยม" (Top 3 by rating, เขียน Logic Sort เอง)
  ใน `ListView` แบบ `shrinkWrap: true` + `NeverScrollableScrollPhysics()`
  พร้อม Comment อธิบายว่าถ้าไม่ใส่จะเจอ "Vertical viewport was given unbounded height"

### การทดลองที่ 5 + Checkpoint 5.1 — Go Router
- เพิ่ม Branch ที่ 5 "เกี่ยวกับ" (`/about` -> `AboutScreen`)
  ทั้ง `NavigationDestination` และ `StatefulShellBranch`
- เปลี่ยน Fallback ของ `destination-detail` จาก
  `orElse: () => sampleDestinations.first` (โชว์ข้อมูลผิดตัวแบบเงียบ ๆ)
  เป็นแสดงหน้า `DestinationNotFoundScreen` เมื่อหา id ไม่เจอจริง ๆ
- ทดสอบด้วย URL `/explore/destinations/999` บน Chrome -> ขึ้นหน้า "ไม่พบข้อมูลที่ต้องการ"

### การทดลองที่ 7 — ทดลองเพิ่มเติม
- 7.1 เพิ่มแถบ `FilterChip` กรองตาม Tag ใน Explore (ทำงานร่วมกับช่องค้นหา)
- 7.2 เปลี่ยน `builder` เป็น `pageBuilder` + `CustomTransitionPage`
  ให้หน้า Detail เลื่อนเข้าจากทางขวา

### การทดลองที่ 8 — Saved Screen ใช้งานได้จริง (Independent Challenge)
- สร้าง `SavedStore extends ChangeNotifier` เก็บ `Set<String> savedIds` เป็น Global
  instance เดียว ทุกหน้าที่ต้องการก็ครอบด้วย `ListenableBuilder`
  (แก้ปัญหา `setState` ของหน้าหนึ่งสั่งอีกหน้า rebuild ไม่ได้)
- เพิ่มปุ่มหัวใจทั้งบน `DestinationCard` (มุมขวาบน) และ `DestinationDetailScreen`
  กดแล้วสลับสถานะ ไอคอนเปลี่ยน `favorite_border` <-> `favorite` และ sync กันทุกหน้า
- `SavedScreen` แสดงรายการที่บันทึกจริง ใช้ `LayoutBuilder` สลับ Layout:
  จอ Compact -> `ListView` 1 คอลัมน์ / จอกว้างขึ้น -> `GridView` 3/4/5 คอลัมน์
  ถ้ายังไม่มีรายการก็แสดง Empty State พร้อมปุ่มลัดไปหน้าสำรวจ
- กดการ์ดใน Saved ไปหน้า Detail ได้ด้วย `context.pushNamed('destination-detail', ...)`
  เหมือนหน้าอื่นทั้งแอป
- ตัวเลข "Saved" ใน Quick Stats หน้า Home ผูกกับ `savedStore.count` จริง

### บั๊กที่เจอและแก้
1. **Dialog ปิดผิดตัว** — `Navigator.pop(context)` ใน `showDialog` ใช้ context ของหน้า Detail
   ซึ่งไล่ไปเจอ Navigator ของ Shell Branch ก่อน -> ปิดหน้า Detail ทิ้ง ส่วน Dialog ค้างบนจอ
   แก้โดยรับ `dialogContext` มาใช้แทน
2. **Card ล้นในแนวตั้ง** — แถว "พร้อมเข้าพัก" ที่เพิ่มตาม Checkpoint 3 ทำให้การ์ดสูงเกิน
   ปรับ `childAspectRatio` 0.72 -> 0.62 และความสูง Featured List 280 -> 320
3. **Row หัวข้อล้นแนวนอนบนจอแคบ** — ครอบด้วย `Flexible` + `TextOverflow.ellipsis`
4. **กด Back จาก Deep Link ไม่ได้** — เพิ่ม `context.canPop()` เช็คก่อน
   ถ้า Stack ว่างให้ `context.go('/explore')` แทน

### การตรวจสอบ
- `flutter analyze` -> No issues found
- `flutter test` -> ผ่านครบ 16 เคส (ครอบคลุมตารางทดสอบข้อ 1-15 ทั้งหมด)
- `flutter build web` -> สำเร็จ
```

---

## 🔗 เอกสารอ้างอิง

- [Go Router Documentation](https://pub.dev/packages/go_router)
- [Flutter Layout Guide](https://docs.flutter.dev/ui/layout)
- [Material Design 3 — Navigation](https://m3.material.io/components/navigation-bar/overview)
- [Flutter Cookbook — Navigation](https://docs.flutter.dev/cookbook/navigation)
