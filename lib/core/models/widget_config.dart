import 'dart:convert';
import 'package:flutter/material.dart';

class WidgetConfig {
  final String themeId;
  final Color bgColor;
  final double opacity;
  final double blurRadius;
  final String fontFamily;
  final Color textColor;
  final String? selectedExamId;

  WidgetConfig({
    this.themeId = 'custom_glass',
    this.bgColor = Colors.white,
    this.opacity = 0.4,
    this.blurRadius = 15.0,
    this.fontFamily = 'Inter',
    this.textColor = Colors.black,
    this.selectedExamId,
  });

  WidgetConfig copyWith({
    String? themeId,
    Color? bgColor,
    double? opacity,
    double? blurRadius,
    String? fontFamily,
    Color? textColor,
    String? selectedExamId,
  }) {
    return WidgetConfig(
      themeId: themeId ?? this.themeId,
      bgColor: bgColor ?? this.bgColor,
      opacity: opacity ?? this.opacity,
      blurRadius: blurRadius ?? this.blurRadius,
      fontFamily: fontFamily ?? this.fontFamily,
      textColor: textColor ?? this.textColor,
      selectedExamId: selectedExamId ?? this.selectedExamId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme_id': themeId,
      'bg_color': '#${bgColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      'opacity': opacity,
      'blur_radius': blurRadius,
      'font_family': fontFamily,
      'text_color': '#${textColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      'selected_exam_id': selectedExamId,
    };
  }

  String toJson() => json.encode(toMap());

  factory WidgetConfig.fromMap(Map<String, dynamic> map) {
    return WidgetConfig(
      themeId: map['theme_id'] ?? 'custom_glass',
      bgColor: _parseColor(map['bg_color'] ?? '#FFFFFF'),
      opacity: (map['opacity'] ?? 0.4).toDouble(),
      blurRadius: (map['blur_radius'] ?? 15.0).toDouble(),
      fontFamily: map['font_family'] ?? 'Inter',
      textColor: _parseColor(map['text_color'] ?? '#000000'),
      selectedExamId: map['selected_exam_id'],
    );
  }

  static Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
