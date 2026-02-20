import 'package:equatable/equatable.dart';
import '../../domain/entities/priority_enum.dart';
import '../../domain/entities/task_entity.dart';

/// أحداث BLoC المهام
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// تحميل جميع المهام
class LoadTasks extends TaskEvent {}

/// إضافة مهمة جديدة
class AddTask extends TaskEvent {
  final TaskEntity task;
  const AddTask(this.task);

  @override
  List<Object?> get props => [task];
}

/// تحديث مهمة
class UpdateTask extends TaskEvent {
  final TaskEntity task;
  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

/// حذف مهمة
class DeleteTask extends TaskEvent {
  final String taskId;
  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// تغيير حالة المهمة
class ToggleTaskStatus extends TaskEvent {
  final String taskId;
  final TaskStatus newStatus;
  const ToggleTaskStatus(this.taskId, this.newStatus);

  @override
  List<Object?> get props => [taskId, newStatus];
}

/// فلترة المهام
class FilterTasks extends TaskEvent {
  final TaskStatus? statusFilter;
  final Priority? priorityFilter;
  final String? categoryFilter;

  const FilterTasks({
    this.statusFilter,
    this.priorityFilter,
    this.categoryFilter,
  });

  @override
  List<Object?> get props => [statusFilter, priorityFilter, categoryFilter];
}

/// بحث نصي
class SearchTasks extends TaskEvent {
  final String query;
  const SearchTasks(this.query);

  @override
  List<Object?> get props => [query];
}

/// مسح جميع الفلاتر
class ClearFilters extends TaskEvent {}

/// تبديل إتمام مهمة فرعية
class ToggleSubtask extends TaskEvent {
  final String taskId;
  final String subtaskId;
  const ToggleSubtask(this.taskId, this.subtaskId);

  @override
  List<Object?> get props => [taskId, subtaskId];
}
