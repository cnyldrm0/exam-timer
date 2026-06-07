import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_theme_model.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/exam_provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/glass_container.dart';

class ExamDateEditorScreen extends ConsumerStatefulWidget {
  const ExamDateEditorScreen({super.key});

  @override
  ConsumerState<ExamDateEditorScreen> createState() =>
      _ExamDateEditorScreenState();
}

class _ExamDateEditorScreenState extends ConsumerState<ExamDateEditorScreen> {
  /// Tracks which exam IDs have been edited in this session for badge display.
  final Set<String> _editedInSession = {};

  Future<void> _pickDate(String examId, DateTime currentDate) async {
    final activeTheme = ref.read(themeProvider);
    final l10n = AppLocalizations.of(context)!;

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
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

    // Show time picker
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDate),
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

    final newDate = DateTime(
      picked.year,
      picked.month,
      picked.day,
      pickedTime?.hour ?? currentDate.hour,
      pickedTime?.minute ?? currentDate.minute,
    );

    await ref.read(examProvider.notifier).updateExamDate(examId, newDate);

    setState(() {
      _editedInSession.add(examId);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dateUpdated),
          backgroundColor: activeTheme.primary.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _resetAllDates() async {
    final activeTheme = ref.read(themeProvider);
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: activeTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.glassBorder),
        ),
        title: Text(
          l10n.resetAllDates,
          style: TextStyle(color: activeTheme.onSurface),
        ),
        content: Text(
          l10n.resetDatesConfirm,
          style: TextStyle(color: activeTheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel, style: TextStyle(color: activeTheme.outline)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.reset, style: TextStyle(color: activeTheme.primary)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(examProvider.notifier).resetAllDates();

    setState(() {
      _editedInSession.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.datesResetSuccess),
          backgroundColor: activeTheme.primary.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = ref.watch(themeProvider);
    final selectedExams = ref.watch(examProvider);
    final l10n = AppLocalizations.of(context)!;
    final overrides = ref.watch(storageServiceProvider).getExamDateOverrides();
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      body: Stack(
        children: [
          // Background
          _buildBackgroundMesh(activeTheme),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: activeTheme.surface.withOpacity(0.8),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded,
                      color: activeTheme.onSurface, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  l10n.editExamDates.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: activeTheme.onSurface,
                      ),
                ),
                actions: [
                  if (overrides.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.restore_rounded,
                          color: activeTheme.primary),
                      tooltip: l10n.resetAllDates,
                      onPressed: _resetAllDates,
                    ),
                  const SizedBox(width: 8),
                ],
              ),

              // Exam list
              if (selectedExams.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      l10n.noExamSelected,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Text(
                      l10n.editExamDatesSubtitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: activeTheme.onSurface.withOpacity(0.5),
                          ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final exam = selectedExams[index];
                      final isOverridden = overrides.containsKey(exam.id);
                      final wasEditedNow = _editedInSession.contains(exam.id);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 6),
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    exam.shortTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                if (isOverridden || wasEditedNow)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: activeTheme.primary
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      l10n.edited,
                                      style: TextStyle(
                                        color: activeTheme.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                dateFormat.format(exam.date),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      fontSize: 13,
                                      color: isOverridden
                                          ? activeTheme.primary
                                          : activeTheme.onSurface
                                              .withOpacity(0.6),
                                    ),
                              ),
                            ),
                            trailing: Icon(
                              Icons.edit_calendar_outlined,
                              color: activeTheme.primary,
                              size: 22,
                            ),
                            onTap: () => _pickDate(exam.id, exam.date),
                          ),
                        ),
                      );
                    },
                    childCount: selectedExams.length,
                  ),
                ),

                // Reset button at bottom
                if (overrides.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 24),
                      child: OutlinedButton.icon(
                        onPressed: _resetAllDates,
                        icon: const Icon(Icons.restore_rounded, size: 18),
                        label: Text(l10n.resetAllDates),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(
                              color: Colors.redAccent, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundMesh(AppThemeModel activeTheme) {
    return Stack(
      children: [
        Container(color: activeTheme.surface),
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  activeTheme.primary.withOpacity(0.1),
                  activeTheme.primary.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
