import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/task_bloc/task_bloc.dart';
import '../../application/task_bloc/task_event.dart';
import '../../application/category_bloc/category_bloc.dart';
import '../../application/category_bloc/category_state.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/priority_enum.dart';
import 'priority_badge.dart';
import '../utils/date_formatter.dart';

/// بطاقة مهمة (للـ Kanban والقائمة)
class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onTap;
  final bool showStatus;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: task.isOverdue
                  ? const Color(0xFFFF4444).withOpacity(0.06)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: task.isOverdue
                    ? const Color(0xFFFF4444).withOpacity(0.2)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // العنوان + الأولوية
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: task.status == TaskStatus.done
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.status == TaskStatus.done
                              ? Colors.white.withOpacity(0.4)
                              : Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PriorityBadge(priority: task.priority, compact: true),
                  ],
                ),

                // الوصف
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 10),

                // التصنيف + التاريخ
                Row(
                  children: [
                    // التصنيف
                    if (task.categoryId != null)
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoaded) {
                            final cat = state.categories
                                .where((c) => c.id == task.categoryId)
                                .firstOrNull;
                            if (cat != null) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(
                                    cat.colorValue,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(cat.colorValue),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                          }
                          return const SizedBox();
                        },
                      ),

                    const Spacer(),

                    // تاريخ الاستحقاق
                    if (task.dueDate != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: task.isOverdue
                                ? const Color(0xFFFF4444)
                                : Colors.white.withOpacity(0.35),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            DateFormatter.dueLabel(task.dueDate),
                            style: TextStyle(
                              fontSize: 10,
                              color: task.isOverdue
                                  ? const Color(0xFFFF4444)
                                  : Colors.white.withOpacity(0.35),
                              fontWeight: task.isOverdue
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // شريط المهام الفرعية
                if (task.subtasks.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: task.subtaskProgress,
                            backgroundColor: Colors.white.withOpacity(0.08),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              task.subtaskProgress == 1.0
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF42A5F5),
                            ),
                            minHeight: 3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${task.subtasks.where((s) => s.isCompleted).length}/${task.subtasks.length}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                    ],
                  ),
                ],

                // أزرار الحالة السريعة
                if (showStatus) ...[
                  const SizedBox(height: 8),
                  _buildStatusButtons(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButtons(BuildContext context) {
    return Row(
      children: TaskStatus.values.map((status) {
        final isActive = task.status == status;
        final label = switch (status) {
          TaskStatus.todo => 'للتنفيذ',
          TaskStatus.inProgress => 'جاري',
          TaskStatus.done => 'مكتمل',
        };
        final color = switch (status) {
          TaskStatus.todo => const Color(0xFF78909C),
          TaskStatus.inProgress => const Color(0xFFFF9800),
          TaskStatus.done => const Color(0xFF4CAF50),
        };
        return Expanded(
          child: GestureDetector(
            onTap: isActive
                ? null
                : () {
                    context.read<TaskBloc>().add(
                      ToggleTaskStatus(task.id, status),
                    );
                  },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? color.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isActive
                      ? color.withOpacity(0.4)
                      : Colors.white.withOpacity(0.06),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? color : Colors.white.withOpacity(0.35),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
