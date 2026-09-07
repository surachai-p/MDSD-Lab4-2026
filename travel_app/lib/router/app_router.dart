import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../screens/about_screen.dart';
import '../screens/destination_detail_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/saved_screen.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ScaffoldWithNavBar({super.key, required this.navigationShell});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
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

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('ไม่พบหน้าที่ต้องการ'))),
  routes: [
    GoRoute(
      path: '/explore/destinations/:id',
      name: 'destination-detail',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        final destination = state.extra as Destination?;
        if (destination != null) {
          return DestinationDetailScreen(destination: destination);
        }
        final matches = sampleDestinations.where((item) => item.id == id);
        if (matches.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('ไม่พบข้อมูลที่ต้องการ')),
          );
        }
        return DestinationDetailScreen(destination: matches.first);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) =>
          ScaffoldWithNavBar(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (_, __) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              name: 'explore',
              builder: (_, __) => const ExploreScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saved',
              name: 'saved',
              builder: (_, __) => const SavedScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (_, __) => const ProfileScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/about',
              name: 'about',
              builder: (_, __) => const AboutScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
