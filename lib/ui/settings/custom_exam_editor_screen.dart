import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/exam_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/slot_provider.dart';
import '../dashboard/widgets/monetization_modal.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/glass_container.dart';

class CustomExamEditorScreen extends ConsumerStatefulWidget {
  const CustomExamEditorScreen({super.key});

  @override
  ConsumerState<CustomExamEditorScreen> createState() =>
      _CustomExamEditorScreenState();
}

class _CustomExamEditorScreenState
    extends ConsumerState<CustomExamEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _codeController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final activeTheme = ref.read(themeProvider);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(2030, 12, 31),
      helpText: l10n.selectDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: activeTheme.primary,
              onPrimary: Colors.black,
              surface: activeTheme.surface,
              onSurface: activeTheme.onSurface,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: activeTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? now),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: activeTheme.primary,
              onPrimary: Colors.black,
              surface: activeTheme.surface,
              onSurface: activeTheme.onSurface,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: activeTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    setState(() {
      _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        pickedTime?.hour ?? 10,
        pickedTime?.minute ?? 0,
      );
    });
  }

  void _saveExam() {
    if (!_formKey.currentState!.validate()) return;
    
    final l10n = AppLocalizations.of(context)!;

    final activeCount = ref.read(examProvider).length;
    final slotState = ref.read(slotProvider);

    if (activeCount >= slotState.unlockedSlots) {
      MonetizationModal.show(context);
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.examDateRequired),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(examProvider.notifier).addCustomExam(
          title: _titleController.text.trim(),
          date: _selectedDate!,
          code: _codeController.text.trim(),
        );

    final activeTheme = ref.read(themeProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.examAdded),
        backgroundColor: activeTheme.primary.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = ref.watch(themeProvider);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      backgroundColor: activeTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.addCustomExam.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: activeTheme.onSurface,
              ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: activeTheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.addCustomExamSubtitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: activeTheme.onSurface,
                    ),
              ),
              const SizedBox(height: 32),
              
              // Exam Title
              GlassContainer(
                child: TextFormField(
                  controller: _titleController,
                  style: TextStyle(color: activeTheme.onSurface),
                  decoration: InputDecoration(
                    labelText: l10n.examName,
                    labelStyle: TextStyle(color: activeTheme.outline),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.examNameRequired;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Exam Code
              GlassContainer(
                child: TextFormField(
                  controller: _codeController,
                  style: TextStyle(color: activeTheme.onSurface),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: l10n.examCode,
                    labelStyle: TextStyle(color: activeTheme.outline),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date Picker
              GlassContainer(
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? l10n.selectDate
                              : dateFormat.format(_selectedDate!),
                          style: TextStyle(
                            color: _selectedDate == null
                                ? activeTheme.outline
                                : activeTheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                        Icon(Icons.calendar_month, color: activeTheme.primary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Save Button
              ElevatedButton(
                onPressed: _saveExam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeTheme.primary.withOpacity(0.15),
                  foregroundColor: activeTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: activeTheme.primary.withOpacity(0.5)),
                  ),
                ),
                child: Text(
                  l10n.applyAndAdd,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
