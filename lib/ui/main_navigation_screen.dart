import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'settings/settings_screen.dart';
import 'studio/widget_studio_screen.dart';
import 'mock_exams/mock_exams_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/ad_manager.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final AdManager _adManager = AdManager();

  @override
  void initState() {
    super.initState();
    // Load the banner ad after the first frame so that context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adManager.loadBannerAd(context).then((_) {
        // Refresh UI once the banner is ready.
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _adManager.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _backToHome() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const DashboardScreen(),
      const WidgetStudioScreen(),
      const MockExamsScreen(),
      SettingsScreen(onBackToHome: _backToHome),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: screens,
              ),
            ),
            // AdMob Banner Ad
            _adManager.getBannerAdWidget(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.mainMenu,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.palette_outlined),
            activeIcon: const Icon(Icons.palette),
            label: AppLocalizations.of(context)!.widget,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_outlined),
            activeIcon: const Icon(Icons.assignment),
            label: AppLocalizations.of(context)!.mockExams,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }
}

