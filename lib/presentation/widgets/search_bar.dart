import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/task_bloc/task_bloc.dart';
import '../../application/task_bloc/task_event.dart';
import '../../application/task_bloc/task_state.dart';
import '../../application/category_bloc/category_bloc.dart';
import '../../application/category_bloc/category_state.dart';
import '../../domain/entities/priority_enum.dart';
// ignore: unused_import
import '../../domain/entities/category_entity.dart';
import 'category_chip.dart';

/// شريط البحث والفلترة
class TaskSearchBar extends StatefulWidget {
  const TaskSearchBar({super.key});

  @override
  State<TaskSearchBar> createState() => _TaskSearchBarState();
}

class _TaskSearchBarState extends State<TaskSearchBar> {
  final _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // شريط البحث
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'بحث في المهام...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (query) {
                    context.read<TaskBloc>().add(SearchTasks(query));
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildFilterToggle(),
          ],
        ),

        // لوحة الفلترة
        if (_showFilters) ...[const SizedBox(height: 12), _buildFilterPanel()],
      ],
    );
  }

  Widget _buildFilterToggle() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        final hasFilters =
            state is TaskLoaded &&
            (state.statusFilter != null ||
                state.priorityFilter != null ||
                state.categoryFilter != null);
        return GestureDetector(
          onTap: () => setState(() => _showFilters = !_showFilters),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: hasFilters
                  ? const Color(0xFF42A5F5).withOpacity(0.2)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFilters
                    ? const Color(0xFF42A5F5).withOpacity(0.4)
                    : Colors.white.withOpacity(0.08),
              ),
            ),
            child: Icon(
              _showFilters
                  ? Icons.filter_list_off_rounded
                  : Icons.filter_list_rounded,
              size: 18,
              color: hasFilters
                  ? const Color(0xFF42A5F5)
                  : Colors.white.withOpacity(0.5),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterPanel() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, taskState) {
        final currentStatusFilter = taskState is TaskLoaded
            ? taskState.statusFilter
            : null;
        final currentPriorityFilter = taskState is TaskLoaded
            ? taskState.priorityFilter
            : null;
        final currentCategoryFilter = taskState is TaskLoaded
            ? taskState.categoryFilter
            : null;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // فلتر الحالة
              _sectionLabel('الحالة'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: [
                  _statusChip('الكل', null, currentStatusFilter),
                  _statusChip('للتنفيذ', TaskStatus.todo, currentStatusFilter),
                  _statusChip(
                    'قيد التنفيذ',
                    TaskStatus.inProgress,
                    currentStatusFilter,
                  ),
                  _statusChip('مكتملة', TaskStatus.done, currentStatusFilter),
                ],
              ),
              const SizedBox(height: 12),

              // فلتر الأولوية
              _sectionLabel('الأولوية'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: [
                  _priorityChip('الكل', null, currentPriorityFilter),
                  _priorityChip('عاجل', Priority.urgent, currentPriorityFilter),
                  _priorityChip('مرتفع', Priority.high, currentPriorityFilter),
                  _priorityChip(
                    'متوسط',
                    Priority.medium,
                    currentPriorityFilter,
                  ),
                  _priorityChip('منخفض', Priority.low, currentPriorityFilter),
                ],
              ),
              const SizedBox(height: 12),

              // فلتر التصنيف
              _sectionLabel('التصنيف'),
              const SizedBox(height: 6),
              BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, catState) {
                  if (catState is! CategoryLoaded) return const SizedBox();
                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _categoryFilterChip(
                        'الكل',
                        null,
                        null,
                        null,
                        currentCategoryFilter,
                      ),
                      ...catState.categories.map(
                        (cat) => CategoryChip(
                          category: cat,
                          selected: currentCategoryFilter == cat.id,
                          onTap: () {
                            final taskBloc = context.read<TaskBloc>();
                            final ts = taskBloc.state;
                            if (ts is TaskLoaded) {
                              taskBloc.add(
                                FilterTasks(
                                  statusFilter: ts.statusFilter,
                                  priorityFilter: ts.priorityFilter,
                                  categoryFilter:
                                      currentCategoryFilter == cat.id
                                      ? null
                                      : cat.id,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 8),
              // زر مسح الفلاتر
              if (currentStatusFilter != null ||
                  currentPriorityFilter != null ||
                  currentCategoryFilter != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      context.read<TaskBloc>().add(ClearFilters());
                    },
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text(
                      'مسح الفلاتر',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.4),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _statusChip(String label, TaskStatus? status, TaskStatus? current) {
    final selected = status == current;
    return GestureDetector(
      onTap: () {
        final taskBloc = context.read<TaskBloc>();
        final ts = taskBloc.state;
        if (ts is TaskLoaded) {
          taskBloc.add(
            FilterTasks(
              statusFilter: status,
              priorityFilter: ts.priorityFilter,
              categoryFilter: ts.categoryFilter,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _priorityChip(String label, Priority? priority, Priority? current) {
    final selected = priority == current;
    Color chipColor = Colors.white;
    if (priority != null) {
      switch (priority) {
        case Priority.urgent:
          chipColor = const Color(0xFFFF4444);
          break;
        case Priority.high:
          chipColor = const Color(0xFFFF9800);
          break;
        case Priority.medium:
          chipColor = const Color(0xFF42A5F5);
          break;
        case Priority.low:
          chipColor = const Color(0xFF78909C);
          break;
      }
    }
    return GestureDetector(
      onTap: () {
        final taskBloc = context.read<TaskBloc>();
        final ts = taskBloc.state;
        if (ts is TaskLoaded) {
          taskBloc.add(
            FilterTasks(
              statusFilter: ts.statusFilter,
              priorityFilter: priority,
              categoryFilter: ts.categoryFilter,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? chipColor.withOpacity(0.15)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? chipColor.withOpacity(0.4)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? chipColor : Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _categoryFilterChip(
    String label,
    String? catId,
    int? colorVal,
    int? iconCode,
    String? current,
  ) {
    final selected = catId == current;
    return GestureDetector(
      onTap: () {
        final taskBloc = context.read<TaskBloc>();
        final ts = taskBloc.state;
        if (ts is TaskLoaded) {
          taskBloc.add(
            FilterTasks(
              statusFilter: ts.statusFilter,
              priorityFilter: ts.priorityFilter,
              categoryFilter: catId,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
