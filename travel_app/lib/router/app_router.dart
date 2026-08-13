import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../screens/home_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/destination_detail_screen.dart';
import '../screens/saved_screen.dart';
import '../screens/profile_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เกี่ยวกับ')),
      body: const Center(
        child: Text('แอปพลิเคชันท่องเที่ยวเวอร์ชัน 1.0.0'),
      ),
    );
  }
}

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell, 
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'หน้าหลัก'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'สำรวจ'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'บันทึก'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'โปรไฟล์'),
          NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'เกี่ยวกับ'),
        ],
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(routes: [GoRoute(path: '/', name: 'home', builder: (context, state) => const HomeScreen())]),
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
                  // 🎯 แก้จาก builder เป็น pageBuilder เพื่อทำ Animation Slide (ตามข้อ 7.2)
                  pageBuilder: (context, state) {
                    final id = state.pathParameters['id'];
                    final destination = state.extra as Destination? ??
                        sampleDestinations.where((d) => d.id == id).firstOrNull;

                    Widget pageContent;
                    // ยังคงรักษาระบบ Fallback จาก Checkpoint 5.1 ไว้
                    if (destination == null) {
                      pageContent = Scaffold(
                        appBar: AppBar(title: const Text('Error')),
                        body: const Center(child: Text('ไม่พบข้อมูลที่ต้องการ')),
                      );
                    } else {
                      pageContent = DestinationDetailScreen(destination: destination);
                    }

                    // 🎯 คืนค่า CustomTransitionPage สำหรับทำแอนิเมชันเลื่อนจากขวามาซ้าย
                    return CustomTransitionPage(
                      child: pageContent,
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0), // เลื่อนจากแกน X ที่ 1.0 (ขวา) มาที่ 0 (ตรงกลาง)
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
        StatefulShellBranch(routes: [GoRoute(path: '/saved', name: 'saved', builder: (context, state) => const SavedScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/profile', name: 'profile', builder: (context, state) => const ProfileScreen())]),
        StatefulShellBranch(routes: [GoRoute(path: '/about', name: 'about', builder: (context, state) => const AboutScreen())]),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(body: Center(child: Text('ไม่พบหน้าที่ต้องการ: ${state.error}'))),
);