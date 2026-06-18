import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/models/mock_exam_template.dart';
import '../services/storage_service.dart';
import 'exam_provider.dart'; // for storageServiceProvider
import 'pro_provider.dart';

// ─── Exam Templates Provider ────────────────────────────────────────────────

/// Loads and caches the exam templates from the bundled JSON asset.
final examTemplatesProvider = FutureProvider<List<ExamTemplate>>((ref) async {
  return ExamTemplate.loadTemplates();
});

// ─── Selected Filter Provider ───────────────────────────────────────────────

/// Holds the currently selected chip filter on the Denemelerim screen.
/// 'all' means show everything; otherwise matches a template exam_id.
final selectedFilterProvider = StateProvider<String>((ref) => 'all');

// ─── Mock Exam Records Notifier ─────────────────────────────────────────────

class MockExamNotifier extends StateNotifier<List<MockExamRecord>> {
  final StorageService _storageService;

  MockExamNotifier(this._storageService) : super([]) {
    _loadRecords();
  }

  void _loadRecords() {
    final rawList = _storageService.getMockExamRecords();
    final records = <MockExamRecord>[];
    for (final raw in rawList) {
      try {
        records.add(MockExamRecord.fromJson(raw));
      } catch (_) {}
    }
    // Sort by date ascending (oldest first for chart trajectory).
    records.sort((a, b) => a.date.compareTo(b.date));
    state = records;
  }

  Future<void> addRecord(MockExamRecord record) async {
    state = [...state, record]..sort((a, b) => a.date.compareTo(b.date));
    await _persist();
  }

  Future<void> deleteRecord(String recordId) async {
    state = state.where((r) => r.id != recordId).toList();
    await _persist();
  }

  Future<void> _persist() async {
    final jsonList = state.map((r) => r.toJson()).toList();
    await _storageService.saveMockExamRecords(jsonList);
  }
}

final mockExamProvider =
    StateNotifierProvider<MockExamNotifier, List<MockExamRecord>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return MockExamNotifier(storage);
});

// ─── Filtered Records Provider ──────────────────────────────────────────────

/// Derives a filtered list of mock exam records based on the selected chip.
final filteredMockExamsProvider = Provider<List<MockExamRecord>>((ref) {
  final filter = ref.watch(selectedFilterProvider);
  final records = ref.watch(mockExamProvider);

  if (filter == 'all') return records;
  return records.where((r) => r.templateId == filter).toList();
});

// ─── Mock Exam Slots Provider ───────────────────────────────────────────────

class MockExamSlotsNotifier extends StateNotifier<int> {
  final StorageService _storageService;
  final bool _isPro;

  MockExamSlotsNotifier(this._storageService, this._isPro)
      : super(_isPro ? 9999 : _storageService.getMockExamAllowedSlots());

  /// Adds +5 slots after rewarded ad.
  Future<void> addSlots([int count = 5]) async {
    final realTotal = _storageService.getMockExamAllowedSlots() + count;
    await _storageService.setMockExamAllowedSlots(realTotal);
    if (!_isPro) {
      state = realTotal;
    }
  }
}

final mockExamSlotsProvider =
    StateNotifierProvider<MockExamSlotsNotifier, int>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final isPro = ref.watch(proAccessProvider);
  return MockExamSlotsNotifier(storage, isPro);
});
