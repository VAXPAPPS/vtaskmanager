import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';

/// مصدر البيانات المحلي — يتعامل مع Hive مباشرة
class LocalDataSource {
  static const String tasksBoxName = 'tasks';
  static const String categoriesBoxName = 'categories';

  Box<TaskModel> get _tasksBox => Hive.box<TaskModel>(tasksBoxName);
  Box<CategoryModel> get _categoriesBox =>
      Hive.box<CategoryModel>(categoriesBoxName);

  // ==================== Tasks ====================

  List<TaskModel> getAllTasks() {
    return _tasksBox.values.toList();
  }

  TaskModel? getTaskById(String id) {
    try {
      return _tasksBox.values.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addTask(TaskModel task) async {
    await _tasksBox.put(task.id, task);
  }

  Future<void> updateTask(TaskModel task) async {
    await _tasksBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _tasksBox.delete(id);
  }

  Future<void> deleteAllTasks() async {
    await _tasksBox.clear();
  }

  // ==================== Categories ====================

  List<CategoryModel> getAllCategories() {
    return _categoriesBox.values.toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categoriesBox.put(category.id, category);
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _categoriesBox.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await _categoriesBox.delete(id);
  }
}
