import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/mock_exam_template.dart';
import '../../providers/mock_exam_provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class MockExamInputSheet extends ConsumerStatefulWidget {
  final List<ExamTemplate> templates;
  final String? initialTemplateId;

  const MockExamInputSheet({
    super.key,
    required this.templates,
    this.initialTemplateId,
  });

  static void show(BuildContext context, List<ExamTemplate> templates, {String? initialTemplateId}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MockExamInputSheet(
        templates: templates,
        initialTemplateId: initialTemplateId,
      ),
    );
  }

  @override
  ConsumerState<MockExamInputSheet> createState() =>
      _MockExamInputSheetState();
}

class _MockExamInputSheetState extends ConsumerState<MockExamInputSheet> {
  late ExamTemplate _selectedTemplate;
  List<SubjectEntry> _entries = [];

  // For MANUAL exams
  final _manualCorrectCtrl = TextEditingController();
  final _manualIncorrectCtrl = TextEditingController();
  final _manualTotalCtrl = TextEditingController(text: '100');

  // Controllers for OSYM subjects (dynamically created)
  List<TextEditingController> _correctControllers = [];
  List<TextEditingController> _incorrectControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialTemplateId != null && widget.initialTemplateId != 'all') {
      _selectedTemplate = widget.templates.firstWhere(
        (t) => t.examId == widget.initialTemplateId,
        orElse: () => widget.templates.first,
      );
    } else {
      _selectedTemplate = widget.templates.first;
    }
    _rebuildEntries();
  }

  void _rebuildEntries() {
    // Dispose old controllers
    for (final c in _correctControllers) {
      c.dispose();
    }
    for (final c in _incorrectControllers) {
      c.dispose();
    }

    if (_selectedTemplate.isManual) {
      _entries = [];
      _correctControllers = [];
      _incorrectControllers = [];
    } else {
      _entries = _selectedTemplate.subjects
          .map((s) => SubjectEntry(
                subjectName: s.subjectName,
                maxQuestions: s.maxQuestions,
              ))
          .toList();
      _correctControllers =
          List.generate(_entries.length, (_) => TextEditingController());
      _incorrectControllers =
          List.generate(_entries.length, (_) => TextEditingController());
    }
  }

  double get _computedNet {
    if (_selectedTemplate.isManual) {
      final c = int.tryParse(_manualCorrectCtrl.text) ?? 0;
      final w = int.tryParse(_manualIncorrectCtrl.text) ?? 0;
      return _selectedTemplate.calculateNet(c, w);
    }
    double total = 0;
    for (final entry in _entries) {
      total += _selectedTemplate.calculateNet(entry.correct, entry.incorrect);
    }
    return total;
  }

  bool get _hasValidationError {
    if (_selectedTemplate.isManual) {
      final c = int.tryParse(_manualCorrectCtrl.text) ?? 0;
      final w = int.tryParse(_manualIncorrectCtrl.text) ?? 0;
      final max = int.tryParse(_manualTotalCtrl.text) ?? 100;
      return (c + w) > max;
    }
    return _entries.any((e) => e.isOverLimit);
  }

  @override
  void dispose() {
    _manualCorrectCtrl.dispose();
    _manualIncorrectCtrl.dispose();
    _manualTotalCtrl.dispose();
    for (final c in _correctControllers) {
      c.dispose();
    }
    for (final c in _incorrectControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Title ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(Icons.assignment_add,
                    color: theme.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  l10n.addMockExam,
                  style: TextStyle(
                    color: theme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Exam Type Dropdown ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTemplate.examId,
                  isExpanded: true,
                  dropdownColor: theme.surface,
                  style: TextStyle(color: theme.onSurface, fontSize: 14),
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: theme.onSurface.withOpacity(0.5)),
                  items: widget.templates.map((t) {
                    return DropdownMenuItem<String>(
                      value: t.examId,
                      child: Text(t.displayName),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    setState(() {
                      _selectedTemplate =
                          widget.templates.firstWhere((t) => t.examId == id);
                      _rebuildEntries();
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Dynamic Form ──
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _selectedTemplate.isManual
                  ? _buildManualForm(theme, l10n)
                  : _buildOsymForm(theme, l10n),
            ),
          ),

          // ── Bottom Bar: Net + Save ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(
                  top:
                      BorderSide(color: Colors.white.withOpacity(0.06))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Net display
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(colors: [
                        theme.primary.withOpacity(0.15),
                        theme.secondary.withOpacity(0.08),
                      ]),
                      border:
                          Border.all(color: theme.primary.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.totalNet,
                          style: TextStyle(
                            color: theme.onSurface.withOpacity(0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _computedNet.toStringAsFixed(2),
                          style: TextStyle(
                            color: theme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Save button
                  GestureDetector(
                    onTap:
                        _hasValidationError ? null : () => _saveRecord(l10n),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: _hasValidationError
                            ? null
                            : LinearGradient(colors: [
                                theme.primary,
                                theme.secondary,
                              ]),
                        color: _hasValidationError
                            ? Colors.white.withOpacity(0.05)
                            : null,
                      ),
                      child: Text(
                        l10n.save,
                        style: TextStyle(
                          color: _hasValidationError
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── OSYM Form: Dynamic subject rows ──

  Widget _buildOsymForm(dynamic theme, AppLocalizations l10n) {
    return Column(
      children: List.generate(_entries.length, (i) {
        final entry = _entries[i];
        final hasError = entry.isOverLimit;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: hasError
                ? Colors.redAccent.withOpacity(0.06)
                : Colors.white.withOpacity(0.04),
            border: Border.all(
              color: hasError
                  ? Colors.redAccent.withOpacity(0.3)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.subjectName,
                      style: TextStyle(
                        color: theme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.correct + entry.incorrect}/${entry.maxQuestions}',
                    style: TextStyle(
                      color: hasError
                          ? Colors.redAccent
                          : theme.onSurface.withOpacity(0.35),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Input row
              Row(
                children: [
                  Expanded(
                    child: _NumericField(
                      controller: _correctControllers[i],
                      label: l10n.correct,
                      color: Colors.green,
                      theme: theme,
                      onChanged: (val) {
                        setState(() {
                          entry.correct = int.tryParse(val) ?? 0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _NumericField(
                      controller: _incorrectControllers[i],
                      label: l10n.incorrect,
                      color: Colors.redAccent,
                      theme: theme,
                      onChanged: (val) {
                        setState(() {
                          entry.incorrect = int.tryParse(val) ?? 0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Net for this subject
                  SizedBox(
                    width: 50,
                    child: Column(
                      children: [
                        Text(
                          l10n.netScore,
                          style: TextStyle(
                            color: theme.onSurface.withOpacity(0.35),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.netOsym.toStringAsFixed(1),
                          style: TextStyle(
                            color: theme.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Error message
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l10n.validationExceeded,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ── Manual Form: Simplified single-row ──

  Widget _buildManualForm(dynamic theme, AppLocalizations l10n) {
    final c = int.tryParse(_manualCorrectCtrl.text) ?? 0;
    final w = int.tryParse(_manualIncorrectCtrl.text) ?? 0;
    final max = int.tryParse(_manualTotalCtrl.text) ?? 100;
    final hasError = (c + w) > max;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: hasError
            ? Colors.redAccent.withOpacity(0.06)
            : Colors.white.withOpacity(0.04),
        border: Border.all(
          color: hasError
              ? Colors.redAccent.withOpacity(0.3)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: [
          _NumericField(
            controller: _manualTotalCtrl,
            label: '${l10n.totalCorrect} + ${l10n.totalIncorrect} Max',
            color: theme.onSurface,
            theme: theme,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _NumericField(
                  controller: _manualCorrectCtrl,
                  label: l10n.totalCorrect,
                  color: Colors.green,
                  theme: theme,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumericField(
                  controller: _manualIncorrectCtrl,
                  label: l10n.totalIncorrect,
                  color: Colors.redAccent,
                  theme: theme,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.validationExceeded,
                style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  void _saveRecord(AppLocalizations l10n) {
    final uuid = const Uuid().v4();
    late MockExamRecord record;

    if (_selectedTemplate.isManual) {
      final c = int.tryParse(_manualCorrectCtrl.text) ?? 0;
      final w = int.tryParse(_manualIncorrectCtrl.text) ?? 0;
      final max = int.tryParse(_manualTotalCtrl.text) ?? 100;
      record = MockExamRecord(
        id: uuid,
        templateId: _selectedTemplate.examId,
        examDisplayName: _selectedTemplate.displayName,
        date: DateTime.now(),
        totalNet: _selectedTemplate.calculateNet(c, w),
        subjects: [
          SubjectEntry(
            subjectName: _selectedTemplate.displayName,
            maxQuestions: max,
            correct: c,
            incorrect: w,
          ),
        ],
        formulaType: _selectedTemplate.formulaType,
      );
    } else {
      record = MockExamRecord(
        id: uuid,
        templateId: _selectedTemplate.examId,
        examDisplayName: _selectedTemplate.displayName,
        date: DateTime.now(),
        totalNet: _computedNet,
        subjects: List.from(_entries),
        formulaType: _selectedTemplate.formulaType,
      );
    }

    ref.read(mockExamProvider.notifier).addRecord(record);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.mockExamSaved),
        backgroundColor: const Color(0xFF1A2640),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ─── Numeric Input Field ────────────────────────────────────────────────────

class _NumericField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color color;
  final dynamic theme;
  final ValueChanged<String> onChanged;

  const _NumericField({
    required this.controller,
    required this.label,
    required this.color,
    required this.theme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.6),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          style: TextStyle(
            color: theme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: color.withOpacity(0.5)),
            ),
            hintText: '0',
            hintStyle: TextStyle(
              color: theme.onSurface.withOpacity(0.2),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
