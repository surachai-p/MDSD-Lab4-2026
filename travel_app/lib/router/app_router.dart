import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../screens/home_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/destination_detail_screen.dart';
import '../screens/saved_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/about_screen.dart';
import '../screens/destination_not_found_screen.dart';

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
                  // pageBuilder (การทดลองที่ 7.2) แทน builder ธรรมดา เพื่อกำหนด Transition Animation เอง
                  pageBuilder: (context, state) {
                    final id = state.pathParameters['id'];
                    // Fallback ดึงข้อมูลจาก ID กรณี extra เป็น null (เช่น กด Refresh บน Web)
                    // Checkpoint 5.1.2: ค้นหาแบบ manual loop แทน firstWhere+orElse เดิม
                    // เพราะเดิม orElse: () => sampleDestinations.first จะเงียบ ๆ โชว์ข้อมูล
                    // สถานที่แรกในลิสต์แทนเมื่อหา id ไม่เจอ (เช่น พิมพ์ /destinations/999)
                    // ทำให้ผู้ใช้เข้าใจผิดว่านี่คือข้อมูลที่ถูกต้อง ทั้งที่จริงคือ id ผิด
                    Destination? destination = state.extra as Destination?;
                    if (destination == null) {
                      for (final d in sampleDestinations) {
                        if (d.id == id) {
                          destination = d;
                          break;
                        }
                      }
                    }

                    final child = destination == null
                        ? const DestinationNotFoundScreen()
                        : DestinationDetailScreen(destination: destination);

                    return CustomTransitionPage(
                      child: child,
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
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
        // ── Branch 4: About (Checkpoint 5.1.1) ──────────────────
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
  // errorBuilder ทำงานเมื่อ URL ที่ไปไม่ตรงกับ Route ใดเลยในระบบ (เช่นพิมพ์ Path ผิด)
  // ควรใช้แสดงหน้า "ไม่พบหน้า" แทนที่จะปล่อยให้แอป Crash
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('ไม่พบหน้าที่ต้องการ: ${state.error}'),
    ),
  ),
);
