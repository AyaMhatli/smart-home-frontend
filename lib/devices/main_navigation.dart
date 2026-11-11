import 'package:flutter/material.dart';
import '../themes/app_themes.dart';
import '../widgets/bottom_nav_bar.dart';
import 'device_control_screen.dart';
import 'dashboard_screen.dart';
import 'monitoring_screen.dart';
import 'profile_screen.dart';

/// Écran conteneur avec navigation mobile (bottom nav bar).
/// C'est ici que tu passes après le Sign In réussi.
///
/// Remplace les placeholders (_PlaceholderScreen) par tes vrais écrans
/// (DashboardScreen, MonitoringScreen, AutomationScreen...) au fur et à mesure
/// que tu les crées.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    DeviceControlScreen(),
    MonitoringScreen(),
    // _PlaceholderScreen(title: 'Automatisations', icon: Icons.auto_awesome_rounded),
    ProfileScreen(),
  ];

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home_rounded, label: 'Accueil'),
    NavItem(icon: Icons.tune_rounded, label: 'Contrôle'),
    NavItem(icon: Icons.thermostat_rounded, label: 'Monitoring'),
    // NavItem(icon: Icons.auto_awesome_rounded, label: 'Auto'),
    NavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

/// Placeholder temporaire — à remplacer par tes vrais écrans
/// (DashboardScreen, MonitoringScreen, etc.) une fois créés.
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Écran à venir',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
