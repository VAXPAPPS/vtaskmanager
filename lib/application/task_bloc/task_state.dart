import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/priority_enum.dart';

/// حالات BLoC المهام
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskEntity> allTasks;
  final List<TaskEntity> filteredTasks;
  final TaskStatus? statusFilter;
  final Priority? priorityFilter;
  final String? categoryFilter;
  final String searchQuery;

  const TaskLoaded({
    required this.allTasks,
    required this.filteredTasks,
    this.statusFilter,
    this.priorityFilter,
    this.categoryFilter,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
    allTasks,
    filteredTasks,
    statusFilter,
    priorityFilter,
    categoryFilter,
    searchQuery,
  ];

  TaskLoaded copyWith({
    List<TaskEntity>? allTasks,
    List<TaskEntity>? filteredTasks,
    TaskStatus? statusFilter,
    Priority? priorityFilter,
    String? categoryFilter,
    String? searchQuery,
    bool clearStatusFilter = false,
    bool clearPriorityFilter = false,
    bool clearCategoryFilter = false,
  }) {
    return TaskLoaded(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      priorityFilter: clearPriorityFilter
          ? null
          : (priorityFilter ?? this.priorityFilter),
      categoryFilter: clearCategoryFilter
          ? null
          : (categoryFilter ?? this.categoryFilter),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
