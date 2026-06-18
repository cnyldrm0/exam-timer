import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/models/app_theme_model.dart';
import '../../core/models/mock_exam_template.dart';
import '../../providers/mock_exam_provider.dart';
import '../../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import 'mock_exam_input_sheet.dart';
import 'mock_exam_monetization_sheet.dart';

class MockExamsScreen extends ConsumerWidget {
  const MockExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTheme = ref.watch(themeProvider);
    final templatesAsync = ref.watch(examTemplatesProvider);
    final filter = ref.watch(selectedFilterProvider);
    final filteredRecords = ref.watch(filteredMockExamsProvider);
    final allRecords = ref.watch(mockExamProvider);
    final allowedSlots = ref.watch(mockExamSlotsProvider);

    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundMesh(activeTheme),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App Bar ──
              SliverAppBar(
                backgroundColor: activeTheme.surface.withOpacity(0.85),
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                automaticallyImplyLeading: false,
                leading: const SizedBox(width: 48), // Keeps title perfectly centered
                title: Text(
                  AppLocalizations.of(context)!.mockExams.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: activeTheme.onSurface,
                      ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => ref.read(selectedFilterProvider.notifier).state = 'all',
                    icon: Icon(
                      Icons.history_rounded,
                      color: filter == 'all' ? activeTheme.primary : activeTheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // ── Chip Selector ──
              SliverToBoxAdapter(
                child: templatesAsync.when(
                  data: (templates) => _ChipSelector(
                    templates: templates,
                    selected: filter,
                    theme: activeTheme,
                    onSelected: (id) =>
                        ref.read(selectedFilterProvider.notifier).state = id,
                  ),
                  loading: () => const SizedBox(height: 56),
                  error: (_, __) => const SizedBox(height: 56),
                ),
              ),

              // ── Chart ──
              if (filter != 'all')
                SliverToBoxAdapter(
                  child: templatesAsync.when(
                    data: (templates) => _NetChart(
                      records: filteredRecords,
                      filter: filter,
                      templates: templates,
                      theme: activeTheme,
                    ),
                    loading: () => const SizedBox(height: 200),
                    error: (_, __) => const SizedBox(height: 200),
                  ),
                ),

              // ── Stats Summary ──
              if (filter != 'all' && filteredRecords.isNotEmpty)
                SliverToBoxAdapter(
                  child: _StatsSummary(
                    records: filteredRecords,
                    theme: activeTheme,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                ),

              // ── History Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded,
                          color: activeTheme.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${AppLocalizations.of(context)!.mockExams} (${filteredRecords.length})',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: activeTheme.onSurface.withOpacity(0.7),
                              letterSpacing: 1,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${allRecords.length}/$allowedSlots',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: activeTheme.onSurface.withOpacity(0.4),
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── History List or Empty State ──
              if (filteredRecords.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyState(theme: activeTheme)
                      .animate()
                      .fadeIn()
                      .slideY(begin: 0.2),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final record = filteredRecords.reversed
                            .toList()[index]; // newest first
                        return _RecordCard(
                          record: record,
                          theme: activeTheme,
                          onDelete: () => ref
                              .read(mockExamProvider.notifier)
                              .deleteRecord(record.id),
                        )
                            .animate(delay: (index * 60).ms)
                            .fadeIn()
                            .slideY(begin: 0.15);
                      },
                      childCount: filteredRecords.length,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: templatesAsync.when(
        data: (templates) => _buildFab(
            context, ref, templates, allRecords.length, allowedSlots, filter),
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget? _buildFab(BuildContext context, WidgetRef ref,
      List<ExamTemplate> templates, int loggedCount, int allowedSlots, String filter) {
    final theme = ref.read(themeProvider);
    return FloatingActionButton(
      onPressed: () {
        if (loggedCount >= allowedSlots) {
          MockExamMonetizationSheet.show(context);
        } else {
          MockExamInputSheet.show(context, templates, initialTemplateId: filter);
        }
      },
      backgroundColor: theme.primary,
      foregroundColor: theme.surface,
      elevation: 8,
      child: const Icon(Icons.add_rounded, size: 28),
    ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.elasticOut);
  }

  Widget _buildBackgroundMesh(AppThemeModel activeTheme) {
    return Stack(
      children: [
        Container(color: activeTheme.surface),
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 380,
            height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  activeTheme.primary.withOpacity(0.12),
                  activeTheme.primary.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -100,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  activeTheme.secondary.withOpacity(0.10),
                  activeTheme.secondary.withOpacity(0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Chip Selector ──────────────────────────────────────────────────────────

class _ChipSelector extends StatelessWidget {
  final List<ExamTemplate> templates;
  final String selected;
  final AppThemeModel theme;
  final ValueChanged<String> onSelected;

  const _ChipSelector({
    required this.templates,
    required this.selected,
    required this.theme,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final chips = templates.map((t) => _ChipData(t.examId, t.displayName)).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: chips.map((chip) {
          final isActive = chip.id == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(chip.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: isActive
                      ? LinearGradient(colors: [
                          theme.primary.withOpacity(0.9),
                          theme.secondary.withOpacity(0.7),
                        ])
                      : null,
                  color: isActive ? null : Colors.white.withOpacity(0.06),
                  border: Border.all(
                    color: isActive
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Text(
                  chip.label,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : theme.onSurface.withOpacity(0.65),
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChipData {
  final String id;
  final String label;
  const _ChipData(this.id, this.label);
}

// ─── Net Score Chart ────────────────────────────────────────────────────────

class _NetChart extends StatelessWidget {
  final List<MockExamRecord> records;
  final String filter;
  final List<ExamTemplate> templates;
  final AppThemeModel theme;

  const _NetChart({
    required this.records,
    required this.filter,
    required this.templates,
    required this.theme,
  });

  double get _maxY {
    if (filter == 'all') {
      // Use the highest maxNet among all templates.
      double m = 120;
      for (final t in templates) {
        if (t.maxNet > m) m = t.maxNet;
      }
      return m;
    }
    final t = templates.where((t) => t.examId == filter).firstOrNull;
    return t?.maxNet ?? 120;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: records.length < 2
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.show_chart_rounded,
                      color: theme.primary.withOpacity(0.3), size: 36),
                  const SizedBox(height: 8),
                  Text(
                    records.isEmpty
                        ? AppLocalizations.of(context)!.noMockExams
                        : '1 kayıt — grafik 2+ kayıtta çizilir',
                    style: TextStyle(
                      color: theme.onSurface.withOpacity(0.35),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            )
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: _maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.06),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= records.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('dd/MM')
                                .format(records[idx].date),
                            style: TextStyle(
                              color: theme.onSurface.withOpacity(0.4),
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: _maxY / 4,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: theme.onSurface.withOpacity(0.35),
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => theme.surface.withOpacity(0.9),
                    getTooltipItems: (spots) => spots
                        .map((s) => LineTooltipItem(
                              '${s.y.toStringAsFixed(1)} net',
                              TextStyle(
                                color: theme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ))
                        .toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      records.length,
                      (i) => FlSpot(i.toDouble(), records[i].totalNet),
                    ),
                    isCurved: true,
                    curveSmoothness: 0.25,
                    color: theme.primary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 3.5,
                        color: theme.primary,
                        strokeWidth: 1.5,
                        strokeColor: theme.surface,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.primary.withOpacity(0.25),
                          theme.primary.withOpacity(0.02),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            ),
    );
  }
}

// ─── Stats Summary ──────────────────────────────────────────────────────────

class _StatsSummary extends StatelessWidget {
  final List<MockExamRecord> records;
  final AppThemeModel theme;

  const _StatsSummary({required this.records, required this.theme});

  @override
  Widget build(BuildContext context) {
    final avg =
        records.fold<double>(0, (sum, r) => sum + r.totalNet) / records.length;
    final best = records
        .reduce((a, b) => a.totalNet > b.totalNet ? a : b)
        .totalNet;
    final latest = records.last.totalNet;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _StatPill(
              label: 'Ort',
              value: avg.toStringAsFixed(1),
              color: theme.secondary,
              theme: theme),
          const SizedBox(width: 8),
          _StatPill(
              label: 'En İyi',
              value: best.toStringAsFixed(1),
              color: theme.primary,
              theme: theme),
          const SizedBox(width: 8),
          _StatPill(
              label: 'Son',
              value: latest.toStringAsFixed(1),
              color: theme.tertiary,
              theme: theme),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final AppThemeModel theme;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: theme.onSurface.withOpacity(0.45),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Record Card ────────────────────────────────────────────────────────────

class _RecordCard extends StatelessWidget {
  final MockExamRecord record;
  final AppThemeModel theme;
  final VoidCallback onDelete;

  const _RecordCard({
    required this.record,
    required this.theme,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy', 'tr').format(record.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(colors: [
                theme.primary.withOpacity(0.2),
                theme.secondary.withOpacity(0.1),
              ]),
            ),
            child: Center(
              child: Text(
                record.totalNet.toStringAsFixed(1),
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          title: Text(
            record.examDisplayName,
            style: TextStyle(
              color: theme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            dateStr,
            style: TextStyle(
              color: theme.onSurface.withOpacity(0.4),
              fontSize: 11,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${record.totalNet.toStringAsFixed(1)} net',
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_more,
                  color: theme.onSurface.withOpacity(0.3), size: 20),
            ],
          ),
          children: [
            // Subject breakdown
            ...record.subjects.map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          s.subjectName,
                          style: TextStyle(
                            color: theme.onSurface.withOpacity(0.55),
                            fontSize: 11,
                          ),
                        ),
                      ),
                      _SubjectStat(
                          label: 'D', value: '${s.correct}', color: Colors.green),
                      const SizedBox(width: 8),
                      _SubjectStat(
                          label: 'Y', value: '${s.incorrect}', color: Colors.red),
                      const SizedBox(width: 8),
                      _SubjectStat(
                        label: 'N',
                        value: s.netOsym.toStringAsFixed(1),
                        color: theme.primary,
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
            // Delete button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: Icon(Icons.delete_outline,
                    size: 14, color: Colors.redAccent.withOpacity(0.7)),
                label: Text(
                  AppLocalizations.of(context)!.delete,
                  style: TextStyle(
                      color: Colors.redAccent.withOpacity(0.7), fontSize: 11),
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.mockExamDeleted,
            style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: Text(AppLocalizations.of(context)!.delete,
                style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _SubjectStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SubjectStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(color: color.withOpacity(0.5), fontSize: 9)),
        const SizedBox(width: 2),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─── Empty State ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final AppThemeModel theme;
  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primary.withOpacity(0.08),
              border: Border.all(color: theme.primary.withOpacity(0.15)),
            ),
            child: Icon(Icons.assignment_outlined,
                color: theme.primary.withOpacity(0.4), size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noMockExams,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.onSurface.withOpacity(0.4),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
