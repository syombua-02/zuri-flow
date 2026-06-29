 import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'recommendations_screen.dart';
import 'diet_recommendation_screen.dart';
import 'progress_tracker_screen.dart';

/// Hosts the four main sections of the app (Home, Pilates, Diet, Progress)
/// behind a single persistent bottom navigation bar.
///
/// Using an [IndexedStack] keeps every tab's widget (and its scroll
/// position / in-memory state) alive when the user switches away and
/// back, instead of rebuilding the screen from scratch each time.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final GlobalKey<DashboardScreenState> _dashboardKey =
      GlobalKey<DashboardScreenState>();

  final GlobalKey<RecommendationsScreenState> _recommendationsKey =
      GlobalKey<RecommendationsScreenState>();

  static const Color blush = Color(0xFFFFF5F7);
  static const Color berry = Color(0xFFB85C7A);
  static const Color cream = Color(0xFFFFFBFC);

  void _onNavigateToTab(int index) {
    setState(() => _currentIndex = index);

    // Refresh the dashboard's data whenever the user lands back on Home,
    // since changes made on the Pilates/Diet/Progress tabs (like a new
    // progress check-in) won't otherwise be reflected until the next
    // full app load.
    if (index == 0) {
      _dashboardKey.currentState?.loadUserData();
    }
    if (index == 1) {
      _recommendationsKey.currentState?.loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      DashboardScreen(key: _dashboardKey, onNavigateToTab: _onNavigateToTab),
      RecommendationsScreen(key: _recommendationsKey),
      const DietRecommendationScreen(),
      const ProgressTrackerScreen(),
    ];

    return Scaffold(
      backgroundColor: blush,
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: cream,
          indicatorColor: berry.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? berry : Colors.black54,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(color: selected ? berry : Colors.black45);
          }),
        ),
        child: NavigationBar(
          height: 64,
          selectedIndex: _currentIndex,
          onDestinationSelected: _onNavigateToTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.self_improvement_outlined),
              selectedIcon: Icon(Icons.self_improvement_rounded),
              label: 'Movement',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu_rounded),
              label: 'Diet',
            ),
            NavigationDestination(
              icon: Icon(Icons.show_chart_outlined),
              selectedIcon: Icon(Icons.show_chart_rounded),
              label: 'Progress',
            ),
          ],
        ),
      ),
    );
  }
}