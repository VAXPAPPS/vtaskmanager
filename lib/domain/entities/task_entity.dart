import 'package:equatable/equatable.dart';
import 'priority_enum.dart';

/// كيان المهمة الفرعية
class Subtask extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  const Subtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Subtask copyWith({String? id, String? title, bool? isCompleted}) {
    return Subtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}

/// كيان المهمة الرئيسية
class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final TaskStatus status;
  final String? categoryId;
  final DateTime? dueDate;
  final List<Subtask> subtasks;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = Priority.medium,
    this.status = TaskStatus.todo,
    this.categoryId,
    this.dueDate,
    this.subtasks = const [],
    required this.createdAt,
    this.completedAt,
  });

  /// هل المهمة متأخرة؟
  bool get isOverdue =>
      dueDate != null &&
      status != TaskStatus.done &&
      dueDate!.isBefore(DateTime.now());

  /// نسبة إكمال المهام الفرعية
  double get subtaskProgress {
    if (subtasks.isEmpty) return status == TaskStatus.done ? 1.0 : 0.0;
    final completed = subtasks.where((s) => s.isCompleted).length;
    return completed / subtasks.length;
  }

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    TaskStatus? status,
    String? categoryId,
    DateTime? dueDate,
    List<Subtask>? subtasks,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearDueDate = false,
    bool clearCategoryId = false,
    bool clearCompletedAt = false,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      subtasks: subtasks ?? this.subtasks,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    priority,
    status,
    categoryId,
    dueDate,
    subtasks,
    createdAt,
    completedAt,
  ];
}
