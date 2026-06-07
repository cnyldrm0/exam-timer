import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/widget_provider.dart';
import '../../providers/exam_provider.dart';
import '../../providers/timer_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../main.dart';
import '../widgets/glass_container.dart';
import '../../l10n/app_localizations.dart';

class WidgetStudioScreen extends ConsumerWidget {
  const WidgetStudioScreen({super.key});

  void _showTutorial(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.howToAddWidget(context), 
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _tutorialItem(context, '1', AppLocalizations.of(context)!.tutorialStep1),
                  const SizedBox(height: 16),
                  _tutorialItem(context, '2', AppLocalizations.of(context)!.tutorialStep2),
                  const SizedBox(height: 16),
                  _tutorialItem(context, '3', AppLocalizations.of(context)!.tutorialStep3),
                  const SizedBox(height: 16),
                  _tutorialItem(context, '4', AppLocalizations.of(context)!.tutorialStep4),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.black),
                      child: Text(AppStrings.understood(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tutorialItem(BuildContext context, String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
          child: Center(child: Text(number, style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4))),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(widgetProvider);
    final notifier = ref.read(widgetProvider.notifier);
    final selectedExams = ref.watch(examProvider);
    final currentTime = ref.watch(currentTimeProvider);

    final currentExam = selectedExams.firstWhere(
      (e) => e.id == config.selectedExamId,
      orElse: () => selectedExams.isNotEmpty ? selectedExams.first : null!,
    );

    final diff = currentExam != null 
        ? currentExam.date.difference(currentTime) 
        : Duration.zero;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2564&auto=format&fit=crop'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Centered Title
                      SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            AppStrings.widgetStudio(context),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      // Button on the right
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showTutorial(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(Icons.help_outline_rounded, color: Colors.white70, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Center(
                    child: Hero(
                      tag: 'widget_preview',
                      child: Material(
                        color: Colors.transparent,
                        child: _WidgetPreview(
                          config: config,
                          examTitle: currentExam?.shortTitle ?? "Sınav",
                          diff: diff,
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: GlassContainer(
                    borderRadius: 32,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    opacity: 0.15,
                    child: Column(
                      children: [
                        DefaultTabController(
                          length: 3,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TabBar(
                                indicatorColor: AppTheme.primary,
                                labelColor: AppTheme.primary,
                                unselectedLabelColor: Colors.white54,
                                dividerColor: Colors.transparent,
                                tabs: [
                                  Tab(text: AppLocalizations.of(context)!.exam),
                                  Tab(text: AppLocalizations.of(context)!.appearance),
                                  Tab(text: AppLocalizations.of(context)!.style),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 180,
                                child: TabBarView(
                                  children: [
                                    ListView(
                                      padding: EdgeInsets.zero,
                                      children: [
                                        Text(AppLocalizations.of(context)!.whichExamToShow, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                        const SizedBox(height: 4),
                                        ...selectedExams.map((exam) => RadioListTile(
                                          title: Text(exam.shortTitle, style: const TextStyle(color: Colors.white, fontSize: 13)),
                                          value: exam.id,
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          groupValue: config.selectedExamId ?? (selectedExams.isNotEmpty ? selectedExams.first.id : null),
                                          activeColor: AppTheme.primary,
                                          onChanged: (v) => notifier.updateExam(v!),
                                        )),
                                      ],
                                    ),
                                    ListView(
                                      padding: EdgeInsets.zero,
                                      children: [
                                        _SliderRow(
                                          label: AppLocalizations.of(context)!.opacity,
                                          value: config.opacity,
                                          onChanged: notifier.updateOpacity,
                                        ),
                                        _SliderRow(
                                          label: AppLocalizations.of(context)!.blur,
                                          value: config.blurRadius / 30,
                                          onChanged: (v) => notifier.updateBlur(v * 30),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Text(
                                            AppLocalizations.of(context)!.widgetOptimizedInfo,
                                            style: const TextStyle(color: Colors.white38, fontSize: 10, fontStyle: FontStyle.italic),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(AppLocalizations.of(context)!.colorTheme, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 65,
                                          child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            padding: EdgeInsets.zero,
                                            children: [
                                              _ThemeButton(label: 'Frost', color: Colors.white, isSelected: config.bgColor == Colors.white, onTap: () => notifier.updateTheme(Colors.white, Colors.black)),
                                              _ThemeButton(label: 'Obsidian', color: Colors.black, isSelected: config.bgColor == Colors.black, onTap: () => notifier.updateTheme(Colors.black, Colors.white)),
                                              _ThemeButton(label: 'Lavender', color: const Color(0xFFD0BCFF), isSelected: config.bgColor == const Color(0xFFD0BCFF), onTap: () => notifier.updateTheme(const Color(0xFFD0BCFF), const Color(0xFF3C0091))),
                                              _ThemeButton(label: 'Ocean', color: const Color(0xFFADC6FF), isSelected: config.bgColor == const Color(0xFFADC6FF), onTap: () => notifier.updateTheme(const Color(0xFFADC6FF), const Color(0xFF002E6A))),
                                              _ThemeButton(label: 'Rose', color: const Color(0xFFFFAFD3), isSelected: config.bgColor == const Color(0xFFFFAFD3), onTap: () => notifier.updateTheme(const Color(0xFFFFAFD3), const Color(0xFF620040))),
                                              _ThemeButton(label: 'Emerald', color: const Color(0xFFA8E6CF), isSelected: config.bgColor == const Color(0xFFA8E6CF), onTap: () => notifier.updateTheme(const Color(0xFFA8E6CF), const Color(0xFF1B4332))),
                                              _ThemeButton(label: 'Amber', color: const Color(0xFFFFD8B1), isSelected: config.bgColor == const Color(0xFFFFD8B1), onTap: () => notifier.updateTheme(const Color(0xFFFFD8B1), const Color(0xFF432818))),
                                              _ThemeButton(label: 'Crimson', color: const Color(0xFFFFB7B2), isSelected: config.bgColor == const Color(0xFFFFB7B2), onTap: () => notifier.updateTheme(const Color(0xFFFFB7B2), const Color(0xFF780000))),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(AppLocalizations.of(context)!.fontFamily, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 40,
                                          child: ListView(
                                            scrollDirection: Axis.horizontal,
                                            padding: EdgeInsets.zero,
                                            children: [
                                              _FontChip(label: 'Inter', family: 'Inter', isSelected: config.fontFamily == 'Inter', onTap: () => notifier.updateFont('Inter')),
                                              _FontChip(label: 'Poppins', family: 'Poppins', isSelected: config.fontFamily == 'Poppins', onTap: () => notifier.updateFont('Poppins')),
                                              _FontChip(label: 'Montserrat', family: 'Montserrat', isSelected: config.fontFamily == 'Montserrat', onTap: () => notifier.updateFont('Montserrat')),
                                              _FontChip(label: 'Roboto', family: 'Roboto', isSelected: config.fontFamily == 'Roboto', onTap: () => notifier.updateFont('Roboto')),
                                              _FontChip(label: 'Jakarta', family: 'Plus Jakarta Sans', isSelected: config.fontFamily == 'Plus Jakarta Sans', onTap: () => notifier.updateFont('Plus Jakarta Sans')),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                            await notifier.applyToWidget();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 52),
                          ),
                          child: Text(AppStrings.applyAndAdd(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WidgetPreview extends StatelessWidget {
  final dynamic config;
  final String examTitle;
  final Duration diff;
  const _WidgetPreview({required this.config, required this.examTitle, required this.diff});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: 300,
      height: 160,
      borderRadius: 24,
      opacity: config.opacity,
      blur: config.blurRadius,
      color: config.bgColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              examTitle,
              style: _getPreviewStyle(config, 16, bold: true),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimePreviewColumn(value: '${diff.inDays}', label: AppStrings.days(context), config: config),
                _TimePreviewColumn(value: '${diff.inHours % 24}', label: AppStrings.hours(context), config: config),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _getPreviewStyle(dynamic config, double size, {bool bold = false}) {
    return GoogleFonts.getFont(
      config.fontFamily,
      color: config.textColor,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: size,
    );
  }
}

class _TimePreviewColumn extends StatelessWidget {
  final String value;
  final String label;
  final dynamic config;

  const _TimePreviewColumn({required this.value, required this.label, required this.config});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.getFont(
              config.fontFamily,
              color: config.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.getFont(
              config.fontFamily,
              color: config.textColor.withOpacity(0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _SliderRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11))),
        Expanded(
          child: Slider(
            value: value,
            activeColor: AppTheme.primary,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ThemeButton({required this.label, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppTheme.primary : Colors.white24, width: 2),
                boxShadow: isSelected ? [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 8)] : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

class _FontChip extends StatelessWidget {
  final String label;
  final String family;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontChip({
    required this.label,
    required this.family,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white10,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.getFont(
              family,
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
