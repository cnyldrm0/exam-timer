import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _selectedExamsKey = 'selected_exams';
  static const String _motivationIndexKey = 'motivation_index';
  static const String _motivationDateKey = 'motivation_date';
  static const String _isFirstRunKey = 'is_first_run';
  static const String _themeIdKey = 'app_theme_id';

  /// Key for the list of permanently unlocked premium theme IDs.
  static const String _unlockedThemesKey = 'unlocked_premium_themes';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> saveSelectedExams(List<String> examIds) async {
    await _prefs.setStringList(_selectedExamsKey, examIds);
    await setFirstRunCompleted();
  }

  List<String> getSelectedExams() {
    return _prefs.getStringList(_selectedExamsKey) ?? [];
  }

  bool get hasSelectedExams => getSelectedExams().isNotEmpty;

  bool get isFirstRun => _prefs.getBool(_isFirstRunKey) ?? true;

  Future<void> setFirstRunCompleted() async {
    await _prefs.setBool(_isFirstRunKey, false);
  }

  // Motivation related storage
  int? getMotivationIndex() => _prefs.getInt(_motivationIndexKey);
  String? getMotivationDate() => _prefs.getString(_motivationDateKey);

  Future<void> saveMotivationData(int index, String date) async {
    await _prefs.setInt(_motivationIndexKey, index);
    await _prefs.setString(_motivationDateKey, date);
  }

  Future<void> saveMotivationIndex(int index) async {
    await _prefs.setInt(_motivationIndexKey, index);
  }

  // Theme related storage
  String? getThemeId() => _prefs.getString(_themeIdKey);

  Future<void> saveThemeId(String themeId) async {
    await _prefs.setString(_themeIdKey, themeId);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // PERMANENT THEME UNLOCK STORAGE
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns all permanently unlocked premium theme IDs.
  List<String> getUnlockedThemeIds() {
    return _prefs.getStringList(_unlockedThemesKey) ?? [];
  }

  /// Returns true if the given theme ID has been permanently unlocked.
  bool isThemeUnlocked(String themeId) {
    return getUnlockedThemeIds().contains(themeId);
  }

  /// Permanently unlocks a theme by adding its ID to the stored list.
  /// Idempotent — safe to call multiple times with the same ID.
  Future<void> addUnlockedTheme(String themeId) async {
    final current = getUnlockedThemeIds();
    if (current.contains(themeId)) return;
    await _prefs.setStringList(_unlockedThemesKey, [...current, themeId]);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // MONETIZATION (SLOTS & PRO) STORAGE
  // ──────────────────────────────────────────────────────────────────────────

  static const String _unlockedSlotsKey = 'unlocked_slots';

  int getUnlockedSlots() {
    return _prefs.getInt(_unlockedSlotsKey) ?? 1; // Default to 1 for all users
  }

  Future<void> setUnlockedSlots(int count) async {
    await _prefs.setInt(_unlockedSlotsKey, count);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // EXAM DATE OVERRIDES
  // ──────────────────────────────────────────────────────────────────────────

  static const String _examDateOverridesKey = 'exam_date_overrides';

  /// Returns all user-customized exam date overrides as {examId: isoDateString}.
  Map<String, String> getExamDateOverrides() {
    final raw = _prefs.getString(_examDateOverridesKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = Map<String, dynamic>.from(
        const JsonDecoder().convert(raw) as Map,
      );
      return decoded.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      return {};
    }
  }

  /// Saves a single exam date override. Merges with existing overrides.
  Future<void> saveExamDateOverride(String examId, String isoDate) async {
    final current = getExamDateOverrides();
    current[examId] = isoDate;
    await _prefs.setString(
      _examDateOverridesKey,
      const JsonEncoder().convert(current),
    );
  }

  /// Removes the override for a single exam.
  Future<void> clearSingleExamDateOverride(String examId) async {
    final current = getExamDateOverrides();
    current.remove(examId);
    await _prefs.setString(
      _examDateOverridesKey,
      const JsonEncoder().convert(current),
    );
  }

  /// Clears ALL exam date overrides (reset to defaults).
  Future<void> clearExamDateOverrides() async {
    await _prefs.remove(_examDateOverridesKey);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // CUSTOM EXAMS
  // ──────────────────────────────────────────────────────────────────────────

  static const String _customExamsKey = 'custom_exams';

  /// Returns all user-created custom exams as a list of JSON maps.
  List<Map<String, dynamic>> getCustomExams() {
    final raw = _prefs.getString(_customExamsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Saves a new custom exam. Appends to the existing list.
  Future<void> saveCustomExam(Map<String, dynamic> examData) async {
    final current = getCustomExams();
    current.add(examData);
    await _prefs.setString(_customExamsKey, json.encode(current));
  }

  /// Deletes a custom exam by its ID.
  Future<void> deleteCustomExam(String examId) async {
    final current = getCustomExams();
    current.removeWhere((e) => e['id'] == examId);
    await _prefs.setString(_customExamsKey, json.encode(current));
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

