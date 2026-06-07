import 'dart:convert';
import 'package:flutter/services.dart';

// ─── Subject Template (from JSON) ───────────────────────────────────────────

class SubjectTemplate {
  final String subjectName;
  final int maxQuestions;

  const SubjectTemplate({
    required this.subjectName,
    required this.maxQuestions,
  });

  factory SubjectTemplate.fromJson(Map<String, dynamic> json) {
    return SubjectTemplate(
      subjectName: json['subject_name'] as String,
      maxQuestions: (json['max_questions'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'subject_name': subjectName,
        'max_questions': maxQuestions,
      };
}

// ─── Exam Template (from JSON) ──────────────────────────────────────────────

class ExamTemplate {
  final String examId;
  final String displayName;
  final String category; // "OSYM" or "MANUAL"
  final String formulaType; // "osym_4_wrong_1_right" or "simple_net"
  final double maxNet;
  final List<SubjectTemplate> subjects;

  const ExamTemplate({
    required this.examId,
    required this.displayName,
    required this.category,
    required this.formulaType,
    required this.maxNet,
    required this.subjects,
  });

  bool get isManual => category == 'MANUAL';
  bool get isOsym => category == 'OSYM';

  /// Calculates net score from correct/incorrect using the formula_type.
  double calculateNet(int correct, int incorrect) {
    switch (formulaType) {
      case 'osym_4_wrong_1_right':
        return correct - (incorrect / 4.0);
      case 'simple_net':
        return (correct - incorrect).toDouble();
      default:
        return correct - (incorrect / 4.0);
    }
  }

  factory ExamTemplate.fromJson(Map<String, dynamic> json) {
    return ExamTemplate(
      examId: json['exam_id'] as String,
      displayName: json['display_name'] as String,
      category: json['category'] as String,
      formulaType: json['formula_type'] as String,
      maxNet: (json['max_net'] as num).toDouble(),
      subjects: (json['subjects'] as List<dynamic>)
          .map((s) => SubjectTemplate.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'exam_id': examId,
        'display_name': displayName,
        'category': category,
        'formula_type': formulaType,
        'max_net': maxNet,
        'subjects': subjects.map((s) => s.toJson()).toList(),
      };

  /// Loads all templates from the bundled asset.
  static Future<List<ExamTemplate>> loadTemplates() async {
    final raw = await rootBundle.loadString('lib/assets/exam_templates.json');
    final List<dynamic> data = json.decode(raw);
    return data
        .map((e) => ExamTemplate.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

// ─── Subject Entry (runtime input for a single subject) ─────────────────────

class SubjectEntry {
  final String subjectName;
  final int maxQuestions;
  int correct;
  int incorrect;

  SubjectEntry({
    required this.subjectName,
    required this.maxQuestions,
    this.correct = 0,
    this.incorrect = 0,
  });

  /// Returns true if user input exceeds the allowed question count.
  bool get isOverLimit => (correct + incorrect) > maxQuestions;

  /// Remaining blank answers.
  int get blank => maxQuestions - correct - incorrect;

  /// Net for this subject using ÖSYM formula: correct - (incorrect / 4).
  double get netOsym => correct - (incorrect / 4.0);

  /// Net for this subject using simple formula: correct - incorrect.
  double get netSimple => (correct - incorrect).toDouble();

  Map<String, dynamic> toJson() => {
        'subject_name': subjectName,
        'max_questions': maxQuestions,
        'correct': correct,
        'incorrect': incorrect,
      };

  factory SubjectEntry.fromJson(Map<String, dynamic> json) {
    return SubjectEntry(
      subjectName: json['subject_name'] as String,
      maxQuestions: (json['max_questions'] as num).toInt(),
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      incorrect: (json['incorrect'] as num?)?.toInt() ?? 0,
    );
  }
}

// ─── Mock Exam Record (a single logged exam result) ─────────────────────────

class MockExamRecord {
  final String id;
  final String templateId;
  final String examDisplayName;
  final DateTime date;
  final double totalNet;
  final List<SubjectEntry> subjects;
  final String formulaType;

  const MockExamRecord({
    required this.id,
    required this.templateId,
    required this.examDisplayName,
    required this.date,
    required this.totalNet,
    required this.subjects,
    required this.formulaType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'template_id': templateId,
        'exam_display_name': examDisplayName,
        'date': date.toIso8601String(),
        'total_net': totalNet,
        'subjects': subjects.map((s) => s.toJson()).toList(),
        'formula_type': formulaType,
      };

  factory MockExamRecord.fromJson(Map<String, dynamic> json) {
    return MockExamRecord(
      id: json['id'] as String,
      templateId: json['template_id'] as String,
      examDisplayName: json['exam_display_name'] as String,
      date: DateTime.parse(json['date'] as String),
      totalNet: (json['total_net'] as num).toDouble(),
      subjects: (json['subjects'] as List<dynamic>)
          .map((s) => SubjectEntry.fromJson(s as Map<String, dynamic>))
          .toList(),
      formulaType: json['formula_type'] as String,
    );
  }
}
