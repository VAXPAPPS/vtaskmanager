import 'package:equatable/equatable.dart';

class StatsState extends Equatable {
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int todoTasks;
  final int overdueTasks;
  final double completionRate;
  final Map<String, int> tasksByCategory; // categoryId -> count
  final Map<String, int> tasksByPriority; // priority name -> count
  final bool isLoading;

  const StatsState({
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.inProgressTasks = 0,
    this.todoTasks = 0,
    this.overdueTasks = 0,
    this.completionRate = 0.0,
    this.tasksByCategory = const {},
    this.tasksByPriority = const {},
    this.isLoading = true,
  });

  @override
  List<Object?> get props => [
    totalTasks,
    completedTasks,
    inProgressTasks,
    todoTasks,
    overdueTasks,
    completionRate,
    tasksByCategory,
    tasksByPriority,
    isLoading,
  ];
}
