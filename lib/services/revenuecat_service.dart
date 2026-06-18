import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  // Android RevenueCat API key
  static const String _googleApiKey = 'goog_plDAyxPylIYtrgJrPzVTTWHGsiE';

  static const String entitlementId = 'pro_access';

  static Future<void> initialize() async {
    if (kIsWeb) return; // RevenueCat does not support Flutter Web out of the box yet

    await Purchases.setLogLevel(LogLevel.info);

    PurchasesConfiguration? configuration;

    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_googleApiKey);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
    }
  }

  /// Check if the user currently has the Pro entitlement.
  static Future<bool> hasProAccess() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive == true;
    } catch (e) {
      debugPrint('Failed to check Pro access: $e');
      return false;
    }
  }

  /// Get the current offerings (paywalls) configured in RevenueCat.
  static Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get offerings: $e');
      return null;
    }
  }

  /// Purchase a specific package.
  static Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.all[entitlementId]?.isActive == true;
    } catch (e) {
      debugPrint('Failed to purchase package: $e');
      return false;
    }
  }

  /// Restore previous purchases.
  static Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[entitlementId]?.isActive == true;
    } catch (e) {
      debugPrint('Failed to restore purchases: $e');
      return false;
    }
  }
}
