import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/priority_enum.dart';
import '../../domain/repositories/task_repository.dart';
import 'stats_event.dart';
import 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final TaskRepository _taskRepository;

  StatsBloc(this._taskRepository) : super(const StatsState()) {
    on<LoadStats>(_onLoadStats);
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(const StatsState(isLoading: true));
    try {
      final tasks = await _taskRepository.getAllTasks();
      final total = tasks.length;
      final completed = tasks.where((t) => t.status == TaskStatus.done).length;
      final inProgress = tasks
          .where((t) => t.status == TaskStatus.inProgress)
          .length;
      final todo = tasks.where((t) => t.status == TaskStatus.todo).length;
      final overdue = tasks.where((t) => t.isOverdue).length;

      // حساب المهام حسب التصنيف
      final byCategory = <String, int>{};
      for (final task in tasks) {
        final catId = task.categoryId ?? 'uncategorized';
        byCategory[catId] = (byCategory[catId] ?? 0) + 1;
      }

      // حساب المهام حسب الأولوية
      final byPriority = <String, int>{};
      for (final task in tasks) {
        final name = task.priority.name;
        byPriority[name] = (byPriority[name] ?? 0) + 1;
      }

      emit(
        StatsState(
          totalTasks: total,
          completedTasks: completed,
          inProgressTasks: inProgress,
          todoTasks: todo,
          overdueTasks: overdue,
          completionRate: total > 0 ? completed / total : 0.0,
          tasksByCategory: byCategory,
          tasksByPriority: byPriority,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(const StatsState(isLoading: false));
    }
  }
}
