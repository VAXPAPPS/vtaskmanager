import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/priority_enum.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

/// BLoC رئيسي لإدارة المهام
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;

  TaskBloc(this._taskRepository) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskStatus>(_onToggleTaskStatus);
    on<FilterTasks>(_onFilterTasks);
    on<SearchTasks>(_onSearchTasks);
    on<ClearFilters>(_onClearFilters);
    on<ToggleSubtask>(_onToggleSubtask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskRepository.getAllTasks();
      // ترتيب: المتأخرة أولًا، ثم حسب الأولوية
      tasks.sort((a, b) {
        if (a.isOverdue && !b.isOverdue) return -1;
        if (!a.isOverdue && b.isOverdue) return 1;
        return a.priority.index.compareTo(b.priority.index);
      });
      emit(TaskLoaded(allTasks: tasks, filteredTasks: tasks));
    } catch (e) {
      emit(TaskError('فشل تحميل المهام: $e'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.addTask(event.task);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError('فشل إضافة المهمة: $e'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.updateTask(event.task);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError('فشل تحديث المهمة: $e'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await _taskRepository.deleteTask(event.taskId);
      add(LoadTasks());
    } catch (e) {
      emit(TaskError('فشل حذف المهمة: $e'));
    }
  }

  Future<void> _onToggleTaskStatus(
    ToggleTaskStatus event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final task = await _taskRepository.getTaskById(event.taskId);
      if (task != null) {
        final updated = task.copyWith(
          status: event.newStatus,
          completedAt: event.newStatus == TaskStatus.done
              ? DateTime.now()
              : null,
          clearCompletedAt: event.newStatus != TaskStatus.done,
        );
        await _taskRepository.updateTask(updated);
        add(LoadTasks());
      }
    } catch (e) {
      emit(TaskError('فشل تغيير حالة المهمة: $e'));
    }
  }

  void _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final filtered = _applyFilters(
        currentState.allTasks,
        event.statusFilter,
        event.priorityFilter,
        event.categoryFilter,
        currentState.searchQuery,
      );
      emit(
        currentState.copyWith(
          filteredTasks: filtered,
          statusFilter: event.statusFilter,
          priorityFilter: event.priorityFilter,
          categoryFilter: event.categoryFilter,
          clearStatusFilter: event.statusFilter == null,
          clearPriorityFilter: event.priorityFilter == null,
          clearCategoryFilter: event.categoryFilter == null,
        ),
      );
    }
  }

  void _onSearchTasks(SearchTasks event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final filtered = _applyFilters(
        currentState.allTasks,
        currentState.statusFilter,
        currentState.priorityFilter,
        currentState.categoryFilter,
        event.query,
      );
      emit(
        currentState.copyWith(
          filteredTasks: filtered,
          searchQuery: event.query,
        ),
      );
    }
  }

  void _onClearFilters(ClearFilters event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      emit(
        TaskLoaded(
          allTasks: currentState.allTasks,
          filteredTasks: currentState.allTasks,
        ),
      );
    }
  }

  Future<void> _onToggleSubtask(
    ToggleSubtask event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final task = await _taskRepository.getTaskById(event.taskId);
      if (task != null) {
        final updatedSubtasks = task.subtasks.map((s) {
          if (s.id == event.subtaskId) {
            return s.copyWith(isCompleted: !s.isCompleted);
          }
          return s;
        }).toList();
        final updated = task.copyWith(subtasks: updatedSubtasks);
        await _taskRepository.updateTask(updated);
        add(LoadTasks());
      }
    } catch (e) {
      emit(TaskError('فشل تحديث المهمة الفرعية: $e'));
    }
  }

  /// تطبيق الفلاتر والبحث
  List<TaskEntity> _applyFilters(
    List<TaskEntity> tasks,
    TaskStatus? statusFilter,
    Priority? priorityFilter,
    String? categoryFilter,
    String searchQuery,
  ) {
    var result = tasks.toList();

    if (statusFilter != null) {
      result = result.where((t) => t.status == statusFilter).toList();
    }

    if (priorityFilter != null) {
      result = result.where((t) => t.priority == priorityFilter).toList();
    }

    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      result = result.where((t) => t.categoryId == categoryFilter).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }
}
