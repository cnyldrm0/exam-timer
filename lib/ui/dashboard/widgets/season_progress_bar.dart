import 'package:flutter/material.dart';

class SeasonProgressBar extends StatelessWidget {
  final DateTime seasonStart;
  final DateTime examDate;
  final DateTime currentDate;

  const SeasonProgressBar({
    super.key,
    required this.seasonStart,
    required this.examDate,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    final totalDuration = examDate.difference(seasonStart).inSeconds;
    final passedDuration = currentDate.difference(seasonStart).inSeconds;
    
    double progress = passedDuration / totalDuration;
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HAZIRLIK BAŞLANGICI',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 10,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '%${(progress * 100).toInt()} TAMAMLANDI',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 10,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.white12 : Colors.black12,
            borderRadius: BorderRadius.circular(3),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.5),
                        Theme.of(context).primaryColor,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
