import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import '../core/models/exam_model.dart';
import '../core/data/mock_exams.dart';
import '../services/storage_service.dart';
import '../services/rating_service.dart';

const _channel = MethodChannel('com.ucydigital.sinavsayac/exam_sync');

// Changed to regular Provider because we initialize in main()
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

final ratingServiceProvider = Provider<RatingService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return RatingService(prefs);
});

class ExamNotifier extends StateNotifier<List<ExamModel>> {
  final StorageService _storageService;
  final RatingService _ratingService;

  ExamNotifier(this._storageService, this._ratingService) : super([]) {
    _loadSelectedExams();
  }

  void _loadSelectedExams() {
    final selectedIds = _storageService.getSelectedExams();
    if (selectedIds.isEmpty) return;

    final loadedExams = MockExams.allExams.where((exam) => selectedIds.contains(exam.id)).toList();
    state = loadedExams;
  }

  /// Reloads MockExams with current overrides + custom exams and refreshes selected exam state.
  Future<void> _reloadExamsWithOverrides() async {
    final overrides = _storageService.getExamDateOverrides();
    final customExams = _storageService.getCustomExams();
    await MockExams.loadExams(dateOverrides: overrides, customExams: customExams);
    _loadSelectedExams();
  }

  /// Updates a single exam's date, persists the override, and syncs widgets.
  Future<void> updateExamDate(String examId, DateTime newDate) async {
    await _storageService.saveExamDateOverride(examId, newDate.toIso8601String());
    await _reloadExamsWithOverrides();
    await saveSelection();
  }

  /// Resets ALL exam date overrides to defaults and syncs widgets.
  Future<void> resetAllDates() async {
    await _storageService.clearExamDateOverrides();
    await _reloadExamsWithOverrides();
    await saveSelection();
  }

  /// Adds a user-created custom exam, persists it, and auto-selects it.
  Future<void> addCustomExam({
    required String title,
    required DateTime date,
    String? code,
  }) async {
    final exam = ExamModel.custom(title: title, date: date, code: code);
    await _storageService.saveCustomExam({
      'id': exam.id,
      'title': exam.title,
      'date': exam.date.toIso8601String(),
    });
    await _reloadExamsWithOverrides();
    // Auto-select the new exam
    if (!state.any((e) => e.id == exam.id)) {
      final loaded = MockExams.allExams.firstWhere((e) => e.id == exam.id);
      state = [loaded, ...state];
      _ratingService.requestReviewIfAppropriate();
    }
    await saveSelection();
  }

  /// Deletes a custom exam from storage and removes it from tracked list.
  Future<void> deleteCustomExam(String examId) async {
    await _storageService.deleteCustomExam(examId);
    state = state.where((e) => e.id != examId).toList();
    await _reloadExamsWithOverrides();
    await saveSelection();
  }

  Future<void> toggleExamSelection(String examId) async {
    final exam = MockExams.allExams.firstWhere((e) => e.id == examId);
    
    if (state.any((e) => e.id == examId)) {
      state = state.where((e) => e.id != examId).toList();
    } else {
      state = [...state, exam];
      _ratingService.requestReviewIfAppropriate();
    }
    
    await saveSelection();
  }

  void toggleExam(ExamModel exam) {
    if (state.any((e) => e.id == exam.id)) {
      state = state.where((e) => e.id != exam.id).toList();
    } else {
      state = [...state, exam];
      _ratingService.requestReviewIfAppropriate();
    }
  }

  Future<void> saveSelection() async {
    final ids = state.map((e) => e.id).toList();
    await _storageService.saveSelectedExams(ids);

    try {
      final examsJson = jsonEncode(state.map((e) => e.toJson()).toList());
      
      await HomeWidget.saveWidgetData<String>('selected_exams_json', examsJson);
      await HomeWidget.updateWidget(
        name: 'ExamWidgetReceiver',
        androidName: 'ExamWidgetReceiver',
      );

      await _channel.invokeMethod('syncExams', {'examsJson': examsJson});
    } catch (e) {
      print("Native sync error: $e");
    }
  }
}

final examProvider = StateNotifierProvider<ExamNotifier, List<ExamModel>>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  final ratingService = ref.watch(ratingServiceProvider);
  return ExamNotifier(storageService, ratingService);
});

