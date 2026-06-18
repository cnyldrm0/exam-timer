import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/data/app_themes.dart';
import '../core/models/app_theme_model.dart';
import '../services/storage_service.dart';
import '../services/ad_manager.dart';
import 'exam_provider.dart'; // for storageServiceProvider
import 'pro_provider.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ACTIVE THEME PROVIDER
// ──────────────────────────────────────────────────────────────────────────────

class ThemeNotifier extends StateNotifier<AppThemeModel> {
  final StorageService _storageService;

  ThemeNotifier(this._storageService)
      : super(_loadInitialTheme(_storageService));

  static AppThemeModel _loadInitialTheme(StorageService storage) {
    final savedId = storage.getThemeId();
    if (savedId == null) return AppThemeCatalog.defaultTheme;
    return AppThemeCatalog.findById(savedId);
  }

  /// Applies [model] as the active app theme.
  /// Only succeeds if the theme is unlocked (built-in or user-earned).
  Future<void> selectTheme(AppThemeModel model) async {
    state = model;
    await _storageService.saveThemeId(model.id);
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, AppThemeModel>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeNotifier(storage);
});

// ──────────────────────────────────────────────────────────────────────────────
// UNLOCKED THEMES PROVIDER
// Holds the Set of permanently unlocked premium theme IDs.
// ──────────────────────────────────────────────────────────────────────────────

class UnlockedThemesNotifier extends StateNotifier<Set<String>> {
  final StorageService _storageService;
  final bool _isPro;

  UnlockedThemesNotifier(this._storageService, this._isPro)
      : super(_load(_storageService));

  static Set<String> _load(StorageService storage) {
    // The default theme is always considered unlocked.
    final saved = storage.getUnlockedThemeIds().toSet();
    saved.add(AppThemeCatalog.defaultTheme.id);
    return saved;
  }

  /// Returns true if a theme is accessible (either catalog-unlocked or
  /// permanently earned via rewarded ad).
  bool isUnlocked(AppThemeModel model) {
    // Pro users get everything
    if (_isPro) return true;
    
    // Catalog-level unlock (e.g. the default free theme)
    if (model.isUnlocked) return true;
    // Earned unlock from storage
    return state.contains(model.id);
  }

  /// Permanently unlocks [themeId] and persists it.
  Future<void> unlockTheme(String themeId) async {
    await _storageService.addUnlockedTheme(themeId);
    state = {...state, themeId};
  }
}

final unlockedThemesProvider =
    StateNotifierProvider<UnlockedThemesNotifier, Set<String>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final isPro = ref.watch(proAccessProvider);
  return UnlockedThemesNotifier(storage, isPro);
});

// ──────────────────────────────────────────────────────────────────────────────
// AD MANAGER PROVIDER
// A single AdManager instance, scoped to the provider tree.
// ──────────────────────────────────────────────────────────────────────────────

final adManagerProvider = ChangeNotifierProvider<AdManager>((ref) {
  final manager = AdManager();
  // Pre-load immediately when the provider is first read.
  manager.loadAd();
  manager.loadInterstitialAd();
  ref.onDispose(manager.dispose);
  return manager;
});
