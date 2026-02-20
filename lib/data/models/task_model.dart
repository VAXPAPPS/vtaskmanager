import 'package:hive/hive.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/priority_enum.dart';

/// Hive TypeAdapter for TaskModel
/// TypeId: 0
class TaskModel extends HiveObject {
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
}

/// Hive Adapter يدوي لـ TaskModel
class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 0;

  @override
  TaskModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return TaskModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String? ?? '',
      priorityIndex: fields[3] as int? ?? 2,
      statusIndex: fields[4] as int? ?? 0,
      categoryId: fields[5] as String?,
      dueDate: fields[6] as DateTime?,
      subtasksData:
          (fields[7] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      createdAt: fields[8] as DateTime? ?? DateTime.now(),
      completedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer.writeByte(10); // number of fields
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.description);
    writer.writeByte(3);
    writer.write(obj.priorityIndex);
    writer.writeByte(4);
    writer.write(obj.statusIndex);
    writer.writeByte(5);
    writer.write(obj.categoryId);
    writer.writeByte(6);
    writer.write(obj.dueDate);
    writer.writeByte(7);
    writer.write(obj.subtasksData);
    writer.writeByte(8);
    writer.write(obj.createdAt);
    writer.writeByte(9);
    writer.write(obj.completedAt);
  }
}
