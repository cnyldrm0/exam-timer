import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/motivation_provider.dart';
import '../../widgets/glass_container.dart';

class MotivationCard extends ConsumerWidget {
  const MotivationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(motivationProvider);

    return quoteAsync.when(
      data: (quote) => _buildCard(context, ref, quote),
      loading: () => const GlassContainer(
        margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        padding: EdgeInsets.all(44),
        opacity: 0.05,
        blur: 20,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, String quote) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(24),
      opacity: 0.05,
      blur: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    size: 16,
                    color: AppTheme.secondary.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'GÜNÜN MOTİVASYON SÖZÜ',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      color: AppTheme.secondary.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  ref.read(motivationProvider.notifier).nextQuote();
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: AppTheme.onSurface.withOpacity(0.5),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                tooltip: 'Sözü Değiştir',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"$quote"',
            key: ValueKey(quote),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: AppTheme.onSurface.withOpacity(0.9),
            ),
          ).animate(key: ValueKey(quote)).fadeIn(duration: 400.ms).slideX(begin: 0.05),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1);
  }
}
