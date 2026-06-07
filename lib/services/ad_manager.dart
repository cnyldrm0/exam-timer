import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages loading and displaying AdMob Rewarded & Banner Ads.
///
/// Usage (Rewarded):
///   final adManager = AdManager();
///   await adManager.loadAd();
///   adManager.showAd(
///     context: context,
///     themeId: 'kizil_safak',
///     onRewardEarned: (themeId) { /* unlock theme */ },
///   );
///
/// Usage (Banner):
///   await adManager.loadBannerAd(context);
///   // Then use adManager.getBannerAdWidget() in your widget tree.
class AdManager {
  // ──────────────────────────────────────────────────────────────────────────
  // AD UNIT IDs
  // ──────────────────────────────────────────────────────────────────────────
  /// TEST Rewarded Ad Unit ID (Google official test ID — safe for development).
  /// PRODUCTION: Replace this string with your real Ad Unit ID from
  ///             AdMob console → Ad Units → Rewarded before publishing.
  static const String _rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917'; // ← REPLACE FOR PRODUCTION

  /// TEST Banner Ad Unit ID (Google official test ID — safe for development).
  /// PRODUCTION: Replace this string with your real Ad Unit ID from
  ///             AdMob console → Ad Units → Banner before publishing.
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/9214589741'; // ← REPLACE FOR PRODUCTION

  // ──────────────────────────────────────────────────────────────────────────

  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  bool _isBannerLoading = false;

  /// Returns `true` if a rewarded ad is loaded and ready to show.
  bool get isReady => _rewardedAd != null;

  /// Returns `true` if the banner ad is loaded and ready to display.
  bool get isBannerReady => _isBannerLoaded;

  // ════════════════════════════════════════════════════════════════════════════
  // BANNER AD
  // ════════════════════════════════════════════════════════════════════════════

  /// Loads an adaptive banner ad sized to [context]'s screen width.
  /// Safe to call multiple times — will no-op if already loading or loaded.
  Future<void> loadBannerAd(BuildContext context) async {
    if (_isBannerLoading || _isBannerLoaded) return;
    _isBannerLoading = true;

    final width = MediaQuery.of(context).size.width.truncate();
    final adSize = AdSize(width: width, height: 60);

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerLoaded = true;
          _isBannerLoading = false;
          debugPrint('[AdManager] Banner ad loaded successfully.');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          _isBannerLoaded = false;
          _isBannerLoading = false;
          debugPrint('[AdManager] Failed to load banner ad: $error');
        },
      ),
    );

    await _bannerAd!.load();
  }

  /// Returns a widget displaying the loaded banner ad, or an empty
  /// `SizedBox` if the ad is not yet ready.
  Widget getBannerAdWidget() {
    if (!_isBannerLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // REWARDED AD
  // ════════════════════════════════════════════════════════════════════════════

  /// Loads the rewarded ad. Safe to call multiple times — will no-op if
  /// already loading or already loaded.
  Future<void> loadAd() async {
    if (_isLoading || _rewardedAd != null) return;
    _isLoading = true;

    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          debugPrint('[AdManager] Rewarded ad loaded successfully.');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoading = false;
          debugPrint('[AdManager] Failed to load rewarded ad: $error');
        },
      ),
    );
  }

  /// Shows the loaded rewarded ad.
  ///
  /// [themeId]        — the ID of the theme to unlock on reward.
  /// [onRewardEarned] — called with [themeId] when user earns the reward.
  /// [onAdNotReady]   — called when no ad is available yet.
  /// [onUserClosedEarly] — called when user dismissed the ad before reward.
  void showAd({
    required BuildContext context,
    required String themeId,
    required void Function(String themeId) onRewardEarned,
    required VoidCallback onAdNotReady,
    required VoidCallback onUserClosedEarly,
  }) {
    if (_rewardedAd == null) {
      onAdNotReady();
      // Kick off a fresh load for next attempt.
      loadAd();
      return;
    }

    bool _rewardGranted = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        // Reload immediately for the next use.
        loadAd();

        if (!_rewardGranted) {
          // User closed before the video ended — no reward.
          onUserClosedEarly();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadAd();
        debugPrint('[AdManager] Failed to show rewarded ad: $error');
        onAdNotReady();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        _rewardGranted = true;
        debugPrint('[AdManager] User earned reward for theme: $themeId');
        onRewardEarned(themeId);
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }
}
