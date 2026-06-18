import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/theme/app_theme.dart';
import 'core/data/mock_exams.dart';
import 'providers/exam_provider.dart';
import 'providers/theme_provider.dart';
import 'ui/main_navigation_screen.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'services/storage_service.dart';
import 'services/revenuecat_service.dart';

// Manual L10n replacement since generator is failing in this environment
class AppStrings {
  static String welcome(BuildContext context) => AppLocalizations.of(context)!.welcome;
  static String motivationTitle(BuildContext context) => AppLocalizations.of(context)!.motivationTitle;
  static String timeLeftToExams(BuildContext context) => AppLocalizations.of(context)!.timeLeftToExams;
  static String trackingStoppedMessage(BuildContext context) => AppLocalizations.of(context)!.trackingStoppedMessage;
  static String stopTracking(BuildContext context) => AppLocalizations.of(context)!.stopTracking;
  static String ok(BuildContext context) => AppLocalizations.of(context)!.ok;
  static String days(BuildContext context) => AppLocalizations.of(context)!.days;
  static String hours(BuildContext context) => AppLocalizations.of(context)!.hours;
  static String mins(BuildContext context) => AppLocalizations.of(context)!.mins;
  static String secs(BuildContext context) => AppLocalizations.of(context)!.secs;
  static String examCompleted(BuildContext context) => AppLocalizations.of(context)!.examCompleted;
  static String widgetStudio(BuildContext context) => AppLocalizations.of(context)!.widgetStudio;
  static String applyAndAdd(BuildContext context) => AppLocalizations.of(context)!.applyAndAdd;
  static String howToAddWidget(BuildContext context) => AppLocalizations.of(context)!.howToAddWidget;
  static String understood(BuildContext context) => AppLocalizations.of(context)!.understood;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob SDK as early as possible.
  await MobileAds.instance.initialize();

  // Initialize RevenueCat SDK
  await RevenueCatService.initialize();

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  final dateOverrides = storageService.getExamDateOverrides();
  final customExams = storageService.getCustomExams();
  await MockExams.loadExams(dateOverrides: dateOverrides, customExams: customExams);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) => prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeThemeModel = ref.watch(themeProvider);
    final localeCode = ref.watch(localeProvider);
    
    Locale? appLocale;
    if (localeCode != 'system') {
      appLocale = Locale(localeCode);
    }
    
    return MaterialApp(
      title: 'Sınav Sayacı',
      debugShowCheckedModeBanner: false,
      locale: appLocale,
      theme: AppTheme.fromModel(activeThemeModel),
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MainNavigationScreen(),
    );
  }
}
