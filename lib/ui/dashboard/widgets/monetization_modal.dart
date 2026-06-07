import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/slot_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';

class MonetizationModal extends ConsumerWidget {
  const MonetizationModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const MonetizationModal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(Icons.lock_outline_rounded, size: 48, color: Colors.orangeAccent),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.unlockNewSlotTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.unlockNewSlotDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            _buildOptionCard(
              title: AppLocalizations.of(context)!.watchAdEarnSlot,
              icon: Icons.play_circle_fill_rounded,
              color: Colors.blueAccent,
              onTap: () => _handleWatchAd(context, ref),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  void _handleWatchAd(BuildContext context, WidgetRef ref) {
    final adManager = ref.read(adManagerProvider);
    
    adManager.showAd(
      context: context,
      themeId: 'slot_unlock', 
      onRewardEarned: (_) async {
        await ref.read(slotProvider.notifier).incrementSlot();
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.slotEarnedSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      onAdNotReady: () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.adNotReadyWait),
              backgroundColor: const Color(0xFF2D1A1A),
            ),
          );
        }
      },
      onUserClosedEarly: () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.watchAdFullyForSlot),
              backgroundColor: const Color(0xFF2D1A1A),
            ),
          );
        }
      },
    );
  }
}
