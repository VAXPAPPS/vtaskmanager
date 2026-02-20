import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/task_bloc/task_bloc.dart';
import '../../application/task_bloc/task_event.dart';
import '../../application/task_bloc/task_state.dart';
import '../../application/category_bloc/category_bloc.dart';
import '../widgets/task_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/empty_state.dart';

/// صفحة قائمة المهام
class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان + زر الإضافة
          Row(
            children: [
              Text(
                'المهام',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF42A5F5), Color(0xFF7C4DFF)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF42A5F5).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'مهمة جديدة',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // البحث والفلترة
          const TaskSearchBar(),
          const SizedBox(height: 16),

          // عدد النتائج
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoaded) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${state.filteredTasks.length} مهمة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),

          // القائمة
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TaskLoaded) {
                  if (state.filteredTasks.isEmpty) {
                    return EmptyState(
                      icon: Icons.task_alt_rounded,
                      message:
                          state.searchQuery.isNotEmpty ||
                              state.statusFilter != null
                          ? 'لا توجد نتائج مطابقة'
                          : 'لا توجد مهام بعد — أضف أول مهمة!',
                      actionLabel: state.searchQuery.isEmpty
                          ? 'إضافة مهمة'
                          : null,
                      onAction: state.searchQuery.isEmpty
                          ? () => _showAddDialog(context)
                          : null,
                    );
                  }
                  return ListView.separated(
                    itemCount: state.filteredTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final task = state.filteredTasks[index];
                      return Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4444).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Color(0xFFFF4444),
                          ),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1A1A1A),
                              title: const Text('حذف المهمة'),
                              content: Text('هل تريد حذف "${task.title}"؟'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('إلغاء'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'حذف',
                                    style: TextStyle(color: Color(0xFFFF4444)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) {
                          context.read<TaskBloc>().add(DeleteTask(task.id));
                        },
                        child: TaskCard(
                          task: task,
                          showStatus: true,
                          onTap: () => _showEditDialog(context, task),
                        ),
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

  void _showAddDialog(BuildContext context) {
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
  }

  void _showEditDialog(BuildContext context, dynamic task) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<TaskBloc>(),
        child: BlocProvider.value(
          value: context.read<CategoryBloc>(),
          child: AddTaskDialog(existingTask: task),
        ),
      ),
    );
  }
}
