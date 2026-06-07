import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/exam_model.dart';

class MockExams {
  static List<ExamModel> allExams = [];

  /// Loads exams from the bundled JSON asset.
  ///
  /// If [dateOverrides] is provided, any exam whose ID appears as a key
  /// will have its date replaced with the ISO-8601 value from the map.
  ///
  /// If [customExams] is provided, these user-created exams are merged
  /// into the list (prepended so they appear first).
  static Future<void> loadExams({
    Map<String, String>? dateOverrides,
    List<Map<String, dynamic>>? customExams,
  }) async {
    try {
      final String response = await rootBundle.loadString('lib/assets/exam_calendar.json');
      final List<dynamic> data = json.decode(response);
      
      final now = DateTime.now();
      
      List<ExamModel> parsed = [];
      for (var jsonMap in data) {
        if (jsonMap['sinav_tarihi'] != null) {
          try {
            parsed.add(ExamModel.fromJson(jsonMap as Map<String, dynamic>));
          } catch (e) {
            print("Error parsing exam ${jsonMap['sinav_kodu']}: $e");
          }
        }
      }

      // Apply user overrides
      if (dateOverrides != null && dateOverrides.isNotEmpty) {
        parsed = parsed.map((exam) {
          final override = dateOverrides[exam.id];
          if (override != null) {
            final newDate = DateTime.tryParse(override);
            if (newDate != null) {
              return exam.copyWithDate(newDate);
            }
          }
          return exam;
        }).toList();
      }

      // Parse custom exams
      final List<ExamModel> customParsed = [];
      if (customExams != null) {
        for (final ce in customExams) {
          try {
            final date = DateTime.tryParse(ce['date'] as String? ?? '');
            if (date != null && date.isAfter(now)) {
              final seasonStart = DateTime(date.year - (date.month < 9 ? 1 : 0), 9, 1);
              customParsed.add(ExamModel(
                id: ce['id'] as String,
                title: ce['title'] as String,
                date: date,
                category: ExamCategory.custom,
                typicalSeasonStart: seasonStart,
                isCustom: true,
              ));
            }
          } catch (_) {}
        }
      }

      final bundled = parsed
          .where((exam) => exam.date.isAfter(now))
          .toList();

      // Sort each group chronologically
      customParsed.sort((a, b) => a.date.compareTo(b.date));
      bundled.sort((a, b) => a.date.compareTo(b.date));

      // Custom exams first, then bundled
      allExams = [...customParsed, ...bundled];
      
    } catch (e) {
      print("Error loading exams: $e");
    }
  }

  static Map<ExamCategory, List<ExamModel>> get groupedExams {
    final Map<ExamCategory, List<ExamModel>> groups = {
      for (var category in ExamCategory.values) category: []
    };

    for (var exam in allExams) {
      groups[exam.category]!.add(exam);
    }

    return groups;
  }
}


