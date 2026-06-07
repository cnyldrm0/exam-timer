import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exam_provider.dart'; // contains sharedPreferencesProvider

const String _localeKey = 'app_locale';

class LocaleNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(_prefs.getString(_localeKey) ?? 'system');

  Future<void> setLocale(String languageCode) async {
    await _prefs.setString(_localeKey, languageCode);
    state = languageCode;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});
