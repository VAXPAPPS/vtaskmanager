import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/task_bloc/task_bloc.dart';

import '../../application/task_bloc/task_state.dart';
import '../../application/category_bloc/category_bloc.dart';

import '../../application/stats_bloc/stats_bloc.dart';
import '../../application/stats_bloc/stats_event.dart';
import '../../application/stats_bloc/stats_state.dart';

import '../widgets/task_card.dart';
import '../widgets/add_task_dialog.dart';

/// الصفحة الرئيسية (Dashboard)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<StatsBloc>().add(LoadStats());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الترحيب
          Text(
            'مرحبًا 👋',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'إليك ملخص مهامك',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),

          // بطاقات الإحصائيات
          BlocBuilder<StatsBloc, StatsState>(
            builder: (context, stats) {
              return Row(
                children: [
                  _statCard(
                    'إجمالي المهام',
                    '${stats.totalTasks}',
                    Icons.list_alt_rounded,
                    const Color(0xFF42A5F5),
                  ),
                  const SizedBox(width: 12),
                  _statCard(
                    'مكتملة',
                    '${stats.completedTasks}',
                    Icons.check_circle_rounded,
                    const Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 12),
                  _statCard(
                    'قيد التنفيذ',
                    '${stats.inProgressTasks}',
                    Icons.pending_rounded,
                    const Color(0xFFFF9800),
                  ),
                  const SizedBox(width: 12),
                  _statCard(
                    'متأخرة',
                    '${stats.overdueTasks}',
                    Icons.warning_rounded,
                    const Color(0xFFFF4444),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // نسبة الإنجاز
          BlocBuilder<StatsBloc, StatsState>(
            builder: (context, stats) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      children: [
                        // الدائرة
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: stats.completionRate,
                                strokeWidth: 5,
                                backgroundColor: Colors.white.withOpacity(0.06),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF42A5F5),
                                ),
                              ),
                              Text(
                                '${(stats.completionRate * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF42A5F5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نسبة الإنجاز',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${stats.completedTasks} من ${stats.totalTasks} مهمة مكتملة',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // المهام الحديثة/المتأخرة
          Row(
            children: [
              Text(
                'المهام الأخيرة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<TaskBloc>(),
                      child: BlocProvider.value(
                        value: context.read<CategoryBloc>(),
                        child: const AddTaskDialog(),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF42A5F5).withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: Color(0xFF42A5F5)),
                      SizedBox(width: 4),
                      Text(
                        'مهمة جديدة',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF42A5F5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // قائمة المهام الأخيرة
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TaskLoaded) {
                  final recentTasks = state.allTasks.take(6).toList();
                  if (recentTasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 48,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'لا توجد مهام بعد',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: recentTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return TaskCard(
                        task: recentTasks[index],
                        showStatus: true,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => BlocProvider.value(
                              value: context.read<TaskBloc>(),
                              child: BlocProvider.value(
                                value: context.read<CategoryBloc>(),
                                child: AddTaskDialog(
                                  existingTask: recentTasks[index],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
