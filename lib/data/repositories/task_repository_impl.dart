import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/task_model.dart';

/// تنفيذ مستودع المهام
class TaskRepositoryImpl implements TaskRepository {
  final LocalDataSource _localDataSource;

  TaskRepositoryImpl(this._localDataSource);

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    final models = _localDataSource.getAllTasks();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    final model = _localDataSource.getTaskById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _localDataSource.addTask(model);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _localDataSource.updateTask(model);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDataSource.deleteTask(id);
  }

  @override
  Future<void> deleteAllTasks() async {
    await _localDataSource.deleteAllTasks();
  }
}
