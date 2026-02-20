import '../entities/task_entity.dart';

/// واجهة مستودع المهام (Abstract)
abstract class TaskRepository {
  Future<List<TaskEntity>> getAllTasks();
  Future<TaskEntity?> getTaskById(String id);
  Future<void> addTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String id);
  Future<void> deleteAllTasks();
}
