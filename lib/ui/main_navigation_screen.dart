import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard/dashboard_screen.dart';
import 'settings/settings_screen.dart';
import 'customize/customization_hub_screen.dart';
import 'mock_exams/mock_exams_screen.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/pro_provider.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _selectedIndex = 0;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isPro = ref.read(proAccessProvider);
    if (!isPro) {
      // Attempt to load the banner ad (will no-op if already loading or loaded)
      ref.read(adManagerProvider).loadBannerAd(context);
    }
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> screens = [
      const DashboardScreen(),
      const CustomizationHubScreen(),
      const MockExamsScreen(),
      SettingsScreen(onBackToHome: _backToHome),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!ref.watch(proAccessProvider)) ref.watch(adManagerProvider).getBannerAdWidget(),
          BottomNavigationBar(
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
                icon: const Icon(Icons.dashboard_customize_outlined),
                activeIcon: const Icon(Icons.dashboard_customize),
                label: AppLocalizations.of(context)!.customize,
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
        ],
      ),
    );
  }
}

