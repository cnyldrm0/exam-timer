import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/data/app_themes.dart';
import '../../core/models/app_theme_model.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';

class CustomizeScreen extends ConsumerWidget {
  const CustomizeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTheme = ref.watch(themeProvider);
    final unlockedIds = ref.watch(unlockedThemesProvider);
    final themes = AppThemeCatalog.themes;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundMesh(activeTheme),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: activeTheme.surface.withOpacity(0.85),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: Text(
                  AppLocalizations.of(context)!.customize.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: activeTheme.onSurface,
                  ),
                ),
              ),

              // Header info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.appTheme,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: activeTheme.onSurface,
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.themeSubtitle,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: activeTheme.onSurface.withOpacity(0.6),
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ).animate().fadeIn(delay: 80.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),

              // Theme cards grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final theme = themes[index];
                      final isActive = theme.id == activeTheme.id;
                      // A theme is accessible if: built-in unlocked OR user earned it.
                      final isAccessible =
                          theme.isUnlocked || unlockedIds.contains(theme.id);

                      return _ThemeCard(
                        theme: theme,
                        isActive: isActive,
                        isAccessible: isAccessible,
                        onTap: () =>
                            ref.read(themeProvider.notifier).selectTheme(theme),
                        onWatchAd: () => _watchAdForTheme(context, ref, theme),
                      ).animate()
                          .fadeIn(delay: (index * 60).ms)
                          .slideY(begin: 0.15);
                    },
                    childCount: themes.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.82,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _watchAdForTheme(
      BuildContext context, WidgetRef ref, AppThemeModel theme) {
    final adManager = ref.read(adManagerProvider);

    adManager.showAd(
      context: context,
      themeId: theme.id,
      onRewardEarned: (themeId) async {
        // 1. Persist unlock permanently.
        await ref.read(unlockedThemesProvider.notifier).unlockTheme(themeId);
        // 2. Immediately apply the newly unlocked theme.
        await ref.read(themeProvider.notifier).selectTheme(theme);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.lock_open_rounded,
                      color: theme.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.themeUnlocked(theme.name),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF1A2640),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      onAdNotReady: () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.adNotReady,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF1A2640),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          );
        }
      },
      onUserClosedEarly: () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.watchAdFully,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF2D1A1A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          );
        }
      },
    );
  }

  Widget _buildBackgroundMesh(AppThemeModel theme) {
    return Stack(
      children: [
        Container(color: theme.surface),
        Positioned(
          top: -80,
          right: -60,
          child: _MeshCircle(color: theme.primary.withOpacity(0.12), size: 380),
        ),
        Positioned(
          bottom: 120,
          left: -100,
          child:
              _MeshCircle(color: theme.secondary.withOpacity(0.10), size: 450),
        ),
        Positioned(
          top: 280,
          left: 40,
          child:
              _MeshCircle(color: theme.tertiary.withOpacity(0.07), size: 280),
        ),
      ],
    );
  }
}

class _MeshCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _MeshCircle({required this.color, required this.size});

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

// ─── Theme Card ────────────────────────────────────────────────────────────────

class _ThemeCard extends StatelessWidget {
  final AppThemeModel theme;
  final bool isActive;

  /// True if the user can freely apply this theme (built-in free OR earned).
  final bool isAccessible;

  final VoidCallback onTap;

  /// Called when user taps "Reklam İzle" on a locked card.
  final VoidCallback onWatchAd;

  const _ThemeCard({
    required this.theme,
    required this.isActive,
    required this.isAccessible,
    required this.onTap,
    required this.onWatchAd,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !isAccessible;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive
                ? theme.primary
                : Colors.white.withOpacity(0.12),
            width: isActive ? 2.5 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: theme.primary.withOpacity(0.35),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            children: [
              // Gradient preview background
              _PreviewBackground(theme: theme),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MiniCountdownPreview(theme: theme),
                    const Spacer(),
                    Text(
                      theme.name,
                      style: TextStyle(
                        color: theme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: theme.onSurface.withOpacity(0.55),
                        fontSize: 9.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Active checkmark ──
              if (isActive)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                        color: theme.surface, size: 16),
                  ),
                ),

              // ── Locked overlay ──
              if (isLocked)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                      child: Container(
                        color: Colors.black.withOpacity(0.50),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Lock icon
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.locked,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // ── "Watch Ad" button ──
                            GestureDetector(
                              onTap: onWatchAd,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.primary.withOpacity(0.85),
                                      theme.secondary.withOpacity(0.85),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.play_circle_outline_rounded,
                                        color: Colors.white, size: 13),
                                    const SizedBox(width: 5),
                                    Text(
                                      AppLocalizations.of(context)!.watchAd,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

// ─── Preview Background ────────────────────────────────────────────────────────

class _PreviewBackground extends StatelessWidget {
  final AppThemeModel theme;
  const _PreviewBackground({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.previewGradient.length >= 2
                    ? theme.previewGradient
                    : [theme.surface, theme.surfaceBright],
              ),
            ),
          ),
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.primary.withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.secondary.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mini Countdown Preview ────────────────────────────────────────────────────

class _MiniCountdownPreview extends StatelessWidget {
  final AppThemeModel theme;
  const _MiniCountdownPreview({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YKS',
            style: TextStyle(
              color: theme.primary.withOpacity(0.9),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MiniTimeUnit(value: '42', label: 'GÜN', theme: theme),
              _MiniTimeUnit(value: '08', label: 'SAAT', theme: theme),
              _MiniTimeUnit(
                  value: '17', label: 'DAK', theme: theme, isAccent: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniTimeUnit extends StatelessWidget {
  final String value;
  final String label;
  final AppThemeModel theme;
  final bool isAccent;

  const _MiniTimeUnit({
    required this.value,
    required this.label,
    required this.theme,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: isAccent ? theme.primary : theme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: theme.onSurface.withOpacity(0.5),
            fontSize: 7,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
