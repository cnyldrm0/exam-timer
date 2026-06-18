import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/foundation.dart';

class RatingService {
  static const String _hasShownRatingKey = 'has_shown_rating';
  final SharedPreferences _prefs;
  final InAppReview _inAppReview = InAppReview.instance;

  RatingService(this._prefs);

  /// Requests the app review dialog to be shown if it hasn't been shown before.
  /// Intended to be called after a meaningful user action, like adding an exam.
  Future<void> requestReviewIfAppropriate() async {
    try {
      final hasShown = _prefs.getBool(_hasShownRatingKey) ?? false;
      
      if (!hasShown) {
        if (await _inAppReview.isAvailable()) {
          // Add a small delay so it doesn't interrupt the immediate UI flow abruptly
          await Future.delayed(const Duration(seconds: 1));
          
          await _inAppReview.requestReview();
          await _prefs.setBool(_hasShownRatingKey, true);
          debugPrint('[RatingService] Review requested and flag saved.');
        } else {
          debugPrint('[RatingService] In-app review is not available.');
        }
      } else {
        debugPrint('[RatingService] Review already shown previously, skipping.');
      }
    } catch (e) {
      debugPrint('[RatingService] Error requesting review: $e');
    }
  }
}
