import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/exam_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/timer_provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../main.dart'; // Import for AppStrings
import '../../../l10n/app_localizations.dart';
import 'dart:ui';
import '../../widgets/glass_container.dart';
import 'season_progress_bar.dart';

class CountdownCard extends ConsumerWidget {
  final ExamModel exam;

  const CountdownCard({super.key, required this.exam});

  void _showMenu(BuildContext context, WidgetRef ref) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(button.size.width, 0), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      color: AppTheme.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        PopupMenuItem(
          onTap: () {
            Future.delayed(const Duration(milliseconds: 300), () {
              ref.read(examProvider.notifier).toggleExamSelection(exam.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.trackingStoppedMessage(context)),
                    backgroundColor: AppTheme.surface,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    action: SnackBarAction(
                      label: AppStrings.ok(context),
                      onPressed: () {},
                      textColor: AppTheme.primary,
                    ),
                  ),
                );
              }
            });
          },
          child: Row(
            children: [
              const Icon(Icons.bookmark_remove_outlined, color: Colors.orangeAccent, size: 18),
              const SizedBox(width: 12),
              Text(AppStrings.stopTracking(context), style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
        if (exam.isCustom)
          PopupMenuItem(
            onTap: () {
              Future.delayed(const Duration(milliseconds: 300), () {
                _showDeleteCustomExamDialog(context, ref);
              });
            },
            child: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.deleteExam, style: const TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
      ],
    );
  }

  void _showDeleteCustomExamDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(AppLocalizations.of(context)!.deleteExam, style: const TextStyle(color: Colors.white)),
        content: Text(AppLocalizations.of(context)!.deleteExamConfirm, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              ref.read(examProvider.notifier).deleteCustomExam(exam.id);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTime = ref.watch(currentTimeProvider);
    final isCompleted = CountdownEngine.isCompleted(exam.date, currentTime);
    final diff = CountdownEngine.calculateDifference(exam.date, currentTime);

    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(24),
      opacity: 0.08,
      blur: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                exam.isCustom && exam.id.startsWith('CUSTOM-')
                    ? AppLocalizations.of(context)!.customExamLabel
                    : exam.id.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.primary.withOpacity(0.8),
                ),
              ),
              Builder(
                builder: (menuContext) => IconButton(
                  icon: const Icon(Icons.more_horiz, color: AppTheme.onSurface, size: 20),
                  onPressed: () => _showMenu(menuContext, ref),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            exam.shortTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          
          if (isCompleted)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  AppStrings.examCompleted(context),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primary,
                  ),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn(context, diff.inDays.toString().padLeft(2, '0'), AppStrings.days(context)),
                _buildSeparator(context),
                _buildTimeColumn(context, (diff.inHours % 24).toString().padLeft(2, '0'), AppStrings.hours(context)),
                _buildSeparator(context),
                _buildTimeColumn(context, (diff.inMinutes % 60).toString().padLeft(2, '0'), AppStrings.mins(context)),
                _buildSeparator(context),
                _buildTimeColumn(context, (diff.inSeconds % 60).toString().padLeft(2, '0'), AppStrings.secs(context), isAccent: true),
              ],
            ),
          
          const SizedBox(height: 32),
          SeasonProgressBar(
            seasonStart: exam.typicalSeasonStart,
            examDate: exam.date,
            currentDate: currentTime,
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24), // Offset slightly to align with the numbers, since labels add height
      child: Text(
        ':',
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          fontSize: 48,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(BuildContext context, String value, String label, {bool isAccent = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 48,
            color: isAccent ? colorScheme.primary : colorScheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isAccent ? colorScheme.primary.withOpacity(0.8) : colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
