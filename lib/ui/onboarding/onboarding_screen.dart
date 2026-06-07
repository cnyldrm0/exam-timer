import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../core/data/mock_exams.dart';
import '../../core/models/exam_model.dart';
import '../../providers/exam_provider.dart';
import '../../providers/slot_provider.dart';
import '../../core/theme/app_theme.dart';
import 'widgets/exam_selection_card.dart';
import '../dashboard/widgets/monetization_modal.dart';
import '../main_navigation_screen.dart';
import '../../l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedExams = ref.watch(examProvider);
    final examNotifier = ref.read(examProvider.notifier);
    final slotState = ref.watch(slotProvider);
    final groupedExams = MockExams.groupedExams;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundMesh(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildHeader(context),
                const SizedBox(height: 32),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      for (var category in ExamCategory.values)
                        if (groupedExams[category]!.isNotEmpty) ...[
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _CategoryHeaderDelegate(category.displayName),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final exam = groupedExams[category]![index];
                                final isSelected = selectedExams.contains(exam);
                                
                                return ExamSelectionCard(
                                  exam: exam,
                                  isSelected: isSelected,
                                  isPopular: category == ExamCategory.popular,
                                  onTap: () {
                                    if (!isSelected && selectedExams.length >= slotState.unlockedSlots) {
                                      MonetizationModal.show(context);
                                    } else {
                                      examNotifier.toggleExam(exam);
                                    }
                                  },
                                ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05);
                              },
                              childCount: groupedExams[category]!.length,
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        ],
                    ],
                  ),
                ),
                _buildBottomButton(context, selectedExams, examNotifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundMesh() {
    return Container(color: AppTheme.surface);
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.auto_awesome,
          size: 40,
          color: AppTheme.primary,
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.selectExam,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppTheme.onSurface,
          ),
        ).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            AppLocalizations.of(context)!.selectExamSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context, List<ExamModel> selectedExams, dynamic examNotifier) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: selectedExams.isNotEmpty 
              ? () async {
                  await examNotifier.saveSelection();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                    );
                  }
                }
              : null,
          child: Text(AppLocalizations.of(context)!.continueButton),
        ),
      ),
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;

  _CategoryHeaderDelegate(this.title);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: AppTheme.surface.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          alignment: Alignment.centerLeft,
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 48;
  @override
  double get minExtent => 48;
  @override
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) => oldDelegate.title != title;
}
