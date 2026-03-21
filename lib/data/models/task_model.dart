import 'dart:convert';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/priority_enum.dart';

/// Model تخزين المهمة في قاعدة SQLite
class TaskModel {
  String id;
  String title;
  String description;
  int priorityIndex; // Priority enum index
  int statusIndex; // TaskStatus enum index
  String? categoryId;
  DateTime? dueDate;
  List<Map<String, dynamic>> subtasksData;
  DateTime createdAt;
  DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.priorityIndex = 2, // medium
    this.statusIndex = 0, // todo
    this.categoryId,
    this.dueDate,
    this.subtasksData = const [],
    required this.createdAt,
    this.completedAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    final subtasksJson = map['subtasks_json'] as String? ?? '[]';
    final decodedSubtasks = jsonDecode(subtasksJson) as List<dynamic>;

    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      priorityIndex: map['priority_index'] as int? ?? 2,
      statusIndex: map['status_index'] as int? ?? 0,
      categoryId: map['category_id'] as String?,
      dueDate: map['due_date'] == null
          ? null
          : DateTime.parse(map['due_date'] as String),
      subtasksData: decodedSubtasks
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      createdAt: DateTime.parse(map['created_at'] as String),
      completedAt: map['completed_at'] == null
          ? null
          : DateTime.parse(map['completed_at'] as String),
    );
  }

  /// تحويل من Entity إلى Model
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      priorityIndex: entity.priority.index,
      statusIndex: entity.status.index,
      categoryId: entity.categoryId,
      dueDate: entity.dueDate,
      subtasksData: entity.subtasks
          .map(
            (s) => {'id': s.id, 'title': s.title, 'isCompleted': s.isCompleted},
          )
          .toList(),
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
    );
  }

  /// تحويل من Model إلى Entity
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      priority: Priority.values[priorityIndex],
      status: TaskStatus.values[statusIndex],
      categoryId: categoryId,
      dueDate: dueDate,
      subtasks: subtasksData
          .map(
            (s) => Subtask(
              id: s['id'] as String,
              title: s['title'] as String,
              isCompleted: s['isCompleted'] as bool,
            ),
          )
          .toList(),
      createdAt: createdAt,
      completedAt: completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority_index': priorityIndex,
      'status_index': statusIndex,
      'category_id': categoryId,
      'due_date': dueDate?.toIso8601String(),
      'subtasks_json': jsonEncode(subtasksData),
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
