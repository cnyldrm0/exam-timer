import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import '../core/models/widget_config.dart';
import 'exam_provider.dart';

class WidgetConfigNotifier extends StateNotifier<WidgetConfig> {
  final Ref ref;

  WidgetConfigNotifier(this.ref) : super(WidgetConfig());

  void updateOpacity(double value) => state = state.copyWith(opacity: value);
  void updateBlur(double value) => state = state.copyWith(blurRadius: value);
  void updateFont(String family) => state = state.copyWith(fontFamily: family);
  void updateExam(String examId) => state = state.copyWith(selectedExamId: examId);
  
  void updateTheme(Color bgColor, Color textColor) {
    state = state.copyWith(
      bgColor: bgColor,
      textColor: textColor,
    );
  }

  Future<void> applyToWidget() async {
    // 1. Save Style Configuration
    await HomeWidget.saveWidgetData<String>('widget_config', state.toJson());
    
    // 2. Save Exam Data (Crucial for the native side to see the dates)
    final selectedExams = ref.read(examProvider);
    final examsJson = jsonEncode(selectedExams.map((e) => e.toJson()).toList());
    await HomeWidget.saveWidgetData<String>('selected_exams_json', examsJson);

    // 3. Update Widget
    await HomeWidget.updateWidget(
      name: 'ExamWidgetReceiver',
      androidName: 'ExamWidgetReceiver',
    );
  }
}

final widgetProvider = StateNotifierProvider<WidgetConfigNotifier, WidgetConfig>((ref) {
  return WidgetConfigNotifier(ref);
});
