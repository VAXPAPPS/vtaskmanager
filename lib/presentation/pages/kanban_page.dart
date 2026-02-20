import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/task_bloc/task_bloc.dart';
import '../../application/task_bloc/task_event.dart';
import '../../application/task_bloc/task_state.dart';
import '../../application/category_bloc/category_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/priority_enum.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_dialog.dart';

/// صفحة Kanban Board
class KanbanPage extends StatelessWidget {
  const KanbanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kanban Board',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TaskLoaded) {
                  return Row(
                    children: [
                      _buildColumn(
                        context,
                        'للتنفيذ',
                        TaskStatus.todo,
                        state.allTasks
                            .where((t) => t.status == TaskStatus.todo)
                            .toList(),
                        const Color(0xFF78909C),
                      ),
                      const SizedBox(width: 12),
                      _buildColumn(
                        context,
                        'قيد التنفيذ',
                        TaskStatus.inProgress,
                        state.allTasks
                            .where((t) => t.status == TaskStatus.inProgress)
                            .toList(),
                        const Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 12),
                      _buildColumn(
                        context,
                        'مكتملة',
                        TaskStatus.done,
                        state.allTasks
                            .where((t) => t.status == TaskStatus.done)
                            .toList(),
                        const Color(0xFF4CAF50),
                      ),
                    ],
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

  Widget _buildColumn(
    BuildContext context,
    String title,
    TaskStatus status,
    List<TaskEntity> tasks,
    Color color,
  ) {
    return Expanded(
      child: DragTarget<TaskEntity>(
        onAcceptWithDetails: (details) {
          final task = details.data;
          if (task.status != status) {
            context.read<TaskBloc>().add(ToggleTaskStatus(task.id, status));
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isHovering
                  ? color.withOpacity(0.08)
                  : Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHovering
                    ? color.withOpacity(0.3)
                    : Colors.white.withOpacity(0.05),
                width: isHovering ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                // رأس العمود
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${tasks.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // البطاقات
                Expanded(
                  child: tasks.isEmpty
                      ? Center(
                          child: Text(
                            'اسحب مهمة هنا',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Draggable<TaskEntity>(
                                data: task,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width: 260,
                                    child: Opacity(
                                      opacity: 0.85,
                                      child: TaskCard(task: task),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: TaskCard(task: task),
                                ),
                                child: TaskCard(
                                  task: task,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => BlocProvider.value(
                                        value: context.read<TaskBloc>(),
                                        child: BlocProvider.value(
                                          value: context.read<CategoryBloc>(),
                                          child: AddTaskDialog(
                                            existingTask: task,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
