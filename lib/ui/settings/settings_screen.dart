import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../onboarding/onboarding_screen.dart';
import '../studio/widget_studio_screen.dart';
import '../../core/models/app_theme_model.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import 'exam_date_editor_screen.dart';
import 'custom_exam_editor_screen.dart';

class SettingsScreen extends ConsumerWidget {
  final VoidCallback? onBackToHome;
  
  const SettingsScreen({super.key, this.onBackToHome});

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://www.google.com');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTheme = ref.watch(themeProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Mesh
          _buildBackgroundMesh(activeTheme),
          
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: activeTheme.surface.withOpacity(0.8),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: Text(
                  AppLocalizations.of(context)!.settings.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: activeTheme.onSurface,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Widget Studio Section
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(Icons.auto_fix_high_outlined, color: activeTheme.primary),
                          title: Text(AppLocalizations.of(context)!.widgetStudio, style: Theme.of(context).textTheme.bodyMedium),
                          subtitle: Text(AppLocalizations.of(context)!.widgetStudioSubtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
                          trailing: Icon(Icons.chevron_right, color: activeTheme.outline),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const WidgetStudioScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Language Section
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(Icons.language_outlined, color: activeTheme.primary),
                          title: Text(AppLocalizations.of(context)!.language, style: Theme.of(context).textTheme.bodyMedium),
                          trailing: PopupMenuButton<String>(
                            initialValue: ref.watch(localeProvider),
                            onSelected: (String value) {
                              ref.read(localeProvider.notifier).setLocale(value);
                            },
                            color: activeTheme.surface,
                            icon: Icon(Icons.arrow_drop_down, color: activeTheme.outline),
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'system',
                                child: Text(AppLocalizations.of(context)!.systemDefault, style: TextStyle(color: activeTheme.onSurface)),
                              ),
                              PopupMenuItem<String>(
                                value: 'tr',
                                child: Text(AppLocalizations.of(context)!.turkish, style: TextStyle(color: activeTheme.onSurface)),
                              ),
                              PopupMenuItem<String>(
                                value: 'en',
                                child: Text(AppLocalizations.of(context)!.english, style: TextStyle(color: activeTheme.onSurface)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Exam Selection Section
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(Icons.edit_calendar_outlined, color: activeTheme.primary),
                          title: Text(AppLocalizations.of(context)!.editExamPreferences, style: Theme.of(context).textTheme.bodyMedium),
                          subtitle: Text(AppLocalizations.of(context)!.changeTrackedExams, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
                          trailing: Icon(Icons.chevron_right, color: activeTheme.outline),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Exam Date Editor Section
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(Icons.date_range_outlined, color: activeTheme.primary),
                          title: Text(AppLocalizations.of(context)!.editExamDates, style: Theme.of(context).textTheme.bodyMedium),
                          subtitle: Text(AppLocalizations.of(context)!.editExamDatesSubtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
                          trailing: Icon(Icons.chevron_right, color: activeTheme.outline),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ExamDateEditorScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Custom Exam Section
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(Icons.add_task_rounded, color: activeTheme.primary),
                          title: Text(AppLocalizations.of(context)!.addCustomExam, style: Theme.of(context).textTheme.bodyMedium),
                          subtitle: Text(AppLocalizations.of(context)!.addCustomExamSubtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
                          trailing: Icon(Icons.chevron_right, color: activeTheme.outline),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CustomExamEditorScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Privacy & Terms Section
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.privacy_tip_outlined, color: activeTheme.primary),
                              title: Text(AppLocalizations.of(context)!.privacyPolicy, style: Theme.of(context).textTheme.bodyMedium),
                              trailing: Icon(Icons.open_in_new, size: 18, color: activeTheme.outline),
                              onTap: _launchUrl,
                            ),
                            const Divider(height: 1, indent: 56, endIndent: 24, color: AppTheme.glassBorder),
                            ListTile(
                              leading: Icon(Icons.description_outlined, color: activeTheme.primary),
                              title: Text(AppLocalizations.of(context)!.termsOfUse, style: Theme.of(context).textTheme.bodyMedium),
                              trailing: Icon(Icons.open_in_new, size: 18, color: activeTheme.outline),
                              onTap: _launchUrl,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                colors: [activeTheme.primary.withOpacity(0.1), activeTheme.primary.withOpacity(0)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
