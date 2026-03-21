import '../models/task_model.dart';
import '../models/category_model.dart';
import '../../infrastructure/database_service.dart';

/// مصدر البيانات المحلي — يتعامل مع SQLite مباشرة
class LocalDataSource {
  // ==================== Tasks ====================

  Future<List<TaskModel>> getAllTasks() async {
    final db = await DatabaseService.database;
    final rows = await db.query('tasks', orderBy: 'created_at DESC');
    return rows.map(TaskModel.fromMap).toList();
  }

  Future<TaskModel?> getTaskById(String id) async {
    final db = await DatabaseService.database;
    final rows = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TaskModel.fromMap(rows.first);
  }

  Future<void> addTask(TaskModel task) async {
    final db = await DatabaseService.database;
    await db.insert('tasks', task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await DatabaseService.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await DatabaseService.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllTasks() async {
    final db = await DatabaseService.database;
    await db.delete('tasks');
  }

  // ==================== Categories ====================

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await DatabaseService.database;
    final rows = await db.query('categories', orderBy: 'name ASC');
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    final db = await DatabaseService.database;
    await db.insert('categories', category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    final db = await DatabaseService.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await DatabaseService.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
