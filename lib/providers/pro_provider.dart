import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/foundation.dart';
import '../services/revenuecat_service.dart';

class ProAccessNotifier extends StateNotifier<bool> {
  ProAccessNotifier() : super(false) {
    _init();
  }

  Future<void> _init() async {
    // Check initial state
    final hasPro = await RevenueCatService.hasProAccess();
    if (mounted) {
      state = hasPro;
    }

    // Listen to updates (e.g. background purchase, cancellation)
    if (!kIsWeb) {
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        final hasProNow = customerInfo.entitlements.all[RevenueCatService.entitlementId]?.isActive == true;
        if (mounted) {
          state = hasProNow;
        }
      });
    }
  }

  /// Manually refresh the state (useful after a purchase or restore)
  Future<void> refresh() async {
    final hasPro = await RevenueCatService.hasProAccess();
    if (mounted) {
      state = hasPro;
    }
  }
}

final proAccessProvider = StateNotifierProvider<ProAccessNotifier, bool>((ref) {
  return ProAccessNotifier();
});
