import 'package:flutter/material.dart';

class AppThemeModel {
  final String id;
  final String name;
  final String description;
  final bool isUnlocked;

  // Core palette
  final Color surface;
  final Color surfaceBright;
  final Color onSurface;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color outline;

  // Gradient for preview card
  final List<Color> previewGradient;

  const AppThemeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isUnlocked,
    required this.surface,
    required this.surfaceBright,
    required this.onSurface,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.outline,
    required this.previewGradient,
  });
}
