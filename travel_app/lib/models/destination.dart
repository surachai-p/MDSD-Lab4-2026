class Destination {
  final String id;
  final String name;
  final String country;
  final String description;
  final String imageUrl;
  final double rating;
  final int price;
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

final List<Destination> sampleDestinations = [
  Destination(
    id: '1',
    name: 'กรุงเทพฯ',
    country: 'ไทย',
    description:
        'เมืองหลวงที่คึกคัก เต็มไปด้วยวัด อาหารริมทาง และชีวิตยามค่ำคืน',
    imageUrl: 'https://picsum.photos/seed/bangkok/600/400',
    rating: 4.7,
    price: 50,
    tags: ['วัด', 'อาหาร', 'ช้อปปิ้ง'],
  ),
  Destination(
    id: '2',
    name: 'เชียงใหม่',
    country: 'ไทย',
    description: 'เมืองทางเหนือที่ล้อมรอบด้วยภูเขา วัดโบราณ และวัฒนธรรมล้านนา',
    imageUrl: 'https://picsum.photos/seed/chiangmai/600/400',
    rating: 4.8,
    price: 35,
    tags: ['ธรรมชาติ', 'วัฒนธรรม', 'Trekking'],
  ),
  Destination(
    id: '3',
    name: 'ภูเก็ต',
    country: 'ไทย',
    description: 'เกาะสวยงามที่มีหาดทรายขาว น้ำทะเลใส และกิจกรรมดำน้ำ',
    imageUrl: 'https://picsum.photos/seed/phuket/600/400',
    rating: 4.6,
    price: 80,
    tags: ['ทะเล', 'ดำน้ำ', 'รีสอร์ท'],
  ),
  Destination(
    id: '4',
    name: 'โตเกียว',
    country: 'ญี่ปุ่น',
    description: 'มหานครที่ผสมผสานความทันสมัยและวัฒนธรรมดั้งเดิมได้อย่างลงตัว',
    imageUrl: 'https://picsum.photos/seed/tokyo/600/400',
    rating: 4.9,
    price: 120,
    tags: ['เทคโนโลยี', 'อาหาร', 'อนิเมะ'],
  ),
  Destination(
    id: '5',
    name: 'บาหลี',
    country: 'อินโดนีเซีย',
    description: 'เกาะแห่งพระเจ้าที่เต็มไปด้วยวัดและชายหาดสวยงาม',
    imageUrl: 'https://picsum.photos/seed/bali/600/400',
    rating: 4.7,
    price: 60,
    tags: ['วัฒนธรรม', 'ทะเล', 'Yoga'],
  ),
  Destination(
    id: '6',
    name: 'สิงคโปร์',
    country: 'สิงคโปร์',
    description: 'นครรัฐสะอาด ทันสมัย และปลอดภัย มีอาหารหลากหลายวัฒนธรรม',
    imageUrl: 'https://picsum.photos/seed/singapore/600/400',
    rating: 4.8,
    price: 150,
    tags: ['ช้อปปิ้ง', 'อาหาร', 'สวนสนุก'],
  ),
];
