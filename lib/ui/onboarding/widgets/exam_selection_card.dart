import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/models/exam_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/glass_container.dart';

class ExamSelectionCard extends StatelessWidget {
  final ExamModel exam;
  final bool isSelected;
  final bool isPopular;
  final VoidCallback onTap;

  const ExamSelectionCard({
    super.key,
    required this.exam,
    required this.isSelected,
    this.isPopular = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: GlassContainer(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: EdgeInsets.all(isPopular ? 22 : 20),
        opacity: isSelected ? 0.2 : 0.08,
        borderRadius: 20,
        border: Border.all(
          color: isSelected 
              ? AppTheme.primary 
              : (isPopular ? AppTheme.primary.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
          width: isSelected ? 2 : 1,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPopular ? Icons.star_rounded : Icons.menu_book_rounded,
                color: isSelected ? AppTheme.primary : (isPopular ? AppTheme.primary.withOpacity(0.7) : AppTheme.onSurface.withOpacity(0.5)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.shortTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: isPopular ? 20 : 18,
                      fontWeight: isPopular ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exam.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.onSurface.withOpacity(0.3),
                  width: 2,
                ),
                color: isSelected ? AppTheme.primary : Colors.transparent,
              ),
              child: isSelected 
                  ? const Icon(Icons.check, size: 18, color: AppTheme.surface)
                      .animate()
                      .scale(duration: 200.ms, curve: Curves.easeOutBack)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
