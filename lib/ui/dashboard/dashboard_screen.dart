import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/exam_provider.dart';
import '../../providers/slot_provider.dart';
import '../onboarding/onboarding_screen.dart';
import 'widgets/countdown_card.dart';
import 'widgets/motivation_card.dart';
import 'widgets/monetization_modal.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/app_theme_model.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedExams = ref.watch(examProvider);
    final slotState = ref.watch(slotProvider);
    final activeTheme = ref.watch(themeProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Mesh
          _buildBackgroundMesh(activeTheme),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: activeTheme.surface.withOpacity(0.8),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: Text(
                  AppLocalizations.of(context)!.appTitle.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: activeTheme.onSurface,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => _onAddNewExamTapped(context, ref, selectedExams.length, slotState),
                    icon: Icon(Icons.add_circle_outline_rounded, color: activeTheme.primary),
                    tooltip: AppLocalizations.of(context)!.addExam,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              
              if (selectedExams.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(context, ref, slotState, activeTheme),
                )
              else ...[
                // Welcome and Motivation Section
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                        child: Text(
                          AppLocalizations.of(context)!.welcome,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: activeTheme.primary,
                          ),
                        ).animate().fadeIn().slideY(begin: 0.2),
                      ),
                      const MotivationCard(),
                    ],
                  ),
                ),

                // Section Title: "Sınavlara Kalan Süre"
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      AppLocalizations.of(context)!.timeLeftToExams,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                  ),
                ),

                // Countdown Cards List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return CountdownCard(exam: selectedExams[index])
                          .animate()
                          .fadeIn(delay: (200 + index * 100).ms)
                          .slideY(begin: 0.1);
                    },
                    childCount: selectedExams.length,
                  ),
                ),
                
                // Add New Button at the bottom
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                    child: OutlinedButton.icon(
                      onPressed: () => _onAddNewExamTapped(context, ref, selectedExams.length, slotState),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(AppLocalizations.of(context)!.addExam),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: activeTheme.primary,
                        side: BorderSide(color: activeTheme.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _onAddNewExamTapped(BuildContext context, WidgetRef ref, int activeCount, SlotState slotState) {
    if (activeCount >= slotState.unlockedSlots) {
      MonetizationModal.show(context);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  Widget _buildBackgroundMesh(AppThemeModel activeTheme) {
    return Stack(
      children: [
        Container(color: activeTheme.surface),
        Positioned(
          top: -100,
          right: -50,
          child: _MeshGradientCircle(
            color: activeTheme.primary.withOpacity(0.15),
            size: 400,
          ),
        ),
        Positioned(
          bottom: 100,
          left: -150,
          child: _MeshGradientCircle(
            color: activeTheme.secondary.withOpacity(0.1),
            size: 500,
          ),
        ),
        Positioned(
          top: 300,
          left: 50,
          child: _MeshGradientCircle(
            color: activeTheme.tertiary.withOpacity(0.08),
            size: 300,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, SlotState slotState, AppThemeModel activeTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.blur_on_rounded,
            size: 80,
            color: activeTheme.primary.withOpacity(0.3),
          ).animate().scale(duration: 400.ms),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.noExamSelected,
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _onAddNewExamTapped(context, ref, 0, slotState),
            child: Text(AppLocalizations.of(context)!.addExam),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _MeshGradientCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _MeshGradientCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}
