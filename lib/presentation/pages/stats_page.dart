import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../application/stats_bloc/stats_bloc.dart';
import '../../application/stats_bloc/stats_event.dart';
import '../../application/stats_bloc/stats_state.dart';
import '../../application/category_bloc/category_bloc.dart';
import '../../application/category_bloc/category_state.dart';

/// صفحة الإحصائيات
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    context.read<StatsBloc>().add(LoadStats());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, stats) {
        if (stats.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإحصائيات',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),

                // الرسم البياني الدائري
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pie Chart
                    Expanded(
                      child: _glassCard(
                        child: Column(
                          children: [
                            Text(
                              'توزيع المهام',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 180,
                              child: stats.totalTasks == 0
                                  ? Center(
                                      child: Text(
                                        'لا توجد بيانات',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                    )
                                  : PieChart(
                                      PieChartData(
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 36,
                                        sections: [
                                          PieChartSectionData(
                                            value: stats.todoTasks.toDouble(),
                                            color: const Color(0xFF78909C),
                                            title: '${stats.todoTasks}',
                                            radius: 32,
                                            titleStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          PieChartSectionData(
                                            value: stats.inProgressTasks
                                                .toDouble(),
                                            color: const Color(0xFFFF9800),
                                            title: '${stats.inProgressTasks}',
                                            radius: 32,
                                            titleStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          PieChartSectionData(
                                            value: stats.completedTasks
                                                .toDouble(),
                                            color: const Color(0xFF4CAF50),
                                            title: '${stats.completedTasks}',
                                            radius: 32,
                                            titleStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            // مفتاح تفسير الألوان
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _legend('للتنفيذ', const Color(0xFF78909C)),
                                const SizedBox(width: 16),
                                _legend('جاري', const Color(0xFFFF9800)),
                                const SizedBox(width: 16),
                                _legend('مكتمل', const Color(0xFF4CAF50)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Bar Chart (Priority)
                    Expanded(
                      child: _glassCard(
                        child: Column(
                          children: [
                            Text(
                              'حسب الأولوية',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 180,
                              child: stats.tasksByPriority.isEmpty
                                  ? Center(
                                      child: Text(
                                        'لا توجد بيانات',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                    )
                                  : BarChart(
                                      BarChartData(
                                        alignment:
                                            BarChartAlignment.spaceEvenly,
                                        maxY:
                                            (stats.tasksByPriority.values
                                                        .fold<int>(
                                                          0,
                                                          (a, b) =>
                                                              a > b ? a : b,
                                                        ) +
                                                    2)
                                                .toDouble(),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          topTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 28,
                                              getTitlesWidget: (v, _) => Text(
                                                '${v.toInt()}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (v, _) {
                                                final labels = [
                                                  'عاجل',
                                                  'مرتفع',
                                                  'متوسط',
                                                  'منخفض',
                                                ];
                                                if (v.toInt() >= 0 &&
                                                    v.toInt() < labels.length) {
                                                  return Text(
                                                    labels[v.toInt()],
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white
                                                          .withOpacity(0.4),
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                          getDrawingHorizontalLine: (_) =>
                                              FlLine(
                                                color: Colors.white.withOpacity(
                                                  0.04,
                                                ),
                                                strokeWidth: 1,
                                              ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        barGroups: _buildPriorityBars(stats),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // التصنيفات
                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حسب التصنيف',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, catState) {
                          if (catState is! CategoryLoaded) {
                            return const SizedBox();
                          }
                          return Column(
                            children: stats.tasksByCategory.entries.map((e) {
                              final cat = catState.categories
                                  .where((c) => c.id == e.key)
                                  .firstOrNull;
                              final name = cat?.name ?? 'بدون تصنيف';
                              final color = cat != null
                                  ? Color(cat.colorValue)
                                  : Colors.grey;
                              final percent = stats.totalTasks > 0
                                  ? e.value / stats.totalTasks
                                  : 0.0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${e.value}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 80,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: percent,
                                          backgroundColor: Colors.white
                                              .withOpacity(0.06),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                color,
                                              ),
                                          minHeight: 4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _buildPriorityBars(StatsState stats) {
    final priorities = ['urgent', 'high', 'medium', 'low'];
    final colors = [
      const Color(0xFFFF4444),
      const Color(0xFFFF9800),
      const Color(0xFF42A5F5),
      const Color(0xFF78909C),
    ];

    return List.generate(priorities.length, (i) {
      final count = (stats.tasksByPriority[priorities[i]] ?? 0).toDouble();
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: count,
            color: colors[i],
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              color: colors[i].withOpacity(0.06),
            ),
          ),
        ],
      );
    });
  }

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
        ),
      ],
    );
  }
}
