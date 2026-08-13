import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../screens/home_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/destination_detail_screen.dart';
import '../screens/saved_screen.dart';
import '../screens/profile_screen.dart';

// ── หน้า AboutScreen (สร้างเพิ่มเติมสำหรับ Branch ใหม่) ────────────────
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เกี่ยวกับ')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'แอปพลิเคชันแนะนำสถานที่ท่องเที่ยว v1.0',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'พัฒนาด้วย Flutter และ GoRouter',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scaffold Shell Wrapper ─────────────────────────────────────────
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell, // แสดง Content ของ active branch
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
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
          // ── 1. เพิ่มเมนู Bottom Navigation สำหรับ Branch ที่ 4 ──
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'เกี่ยวกับ',
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
                  path: 'destinations/:id',
                  name: 'destination-detail',
                  builder: (context, state) {
                    final id = state.pathParameters['id'];

                    // ── 2. แก้ไข Fallback Logic ให้ค้นหาแบบ Safe ──
                    // ค้นหาโดยใช้ firstWhereOrNull เพื่อไม่ให้โปรแกรมพังเมื่อไม่เจอ id
                    final Destination? destination;
                    if (state.extra != null) {
                      destination = state.extra as Destination;
                    } else {
                      // วนลูปหาใน list ถ้าไม่เจอให้คืนค่ากลับมาเป็น null
                      final found = sampleDestinations.where((d) => d.id == id);
                      destination = found.isNotEmpty ? found.first : null;
                    }

                    // ── 3. ถ้าหา ID ไม่เจอ (เช่น Refresh หน้าเว็บ /explore/destinations/999) ──
                    // ให้เด้งไปหน้า "ไม่พบข้อมูลที่ต้องการ" ทันที แทนที่จะโชว์ข้อมูลผิดอัน
                    if (destination == null) {
                      return Scaffold(
                        appBar: AppBar(title: const Text('ไม่พบข้อมูล')),
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'ไม่พบข้อมูลที่ต้องการ (ID: $id)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

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
        // ── 4. เพิ่ม StatefulShellBranch ใหม่ สำหรับหน้า "เกี่ยวกับ" ──
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/about',
              name: 'about',
              builder: (context, state) => const AboutScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('ไม่พบหน้าที่ต้องการ: ${state.error}')),
  ),
);
