import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/task_model.dart';
import '../data/models/category_model.dart';
import '../domain/entities/category_entity.dart';
import 'package:uuid/uuid.dart';

/// خدمة تهيئة Hive
class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // تسجيل Adapters
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());

    // فتح الصناديق
    await Hive.openBox<TaskModel>('tasks');
    await Hive.openBox<CategoryModel>('categories');

    // إضافة تصنيفات افتراضية إذا كانت فارغة
    await _seedDefaultCategories();
  }

  /// تصنيفات افتراضية عند أول تشغيل
  static Future<void> _seedDefaultCategories() async {
    final box = Hive.box<CategoryModel>('categories');
    if (box.isEmpty) {
      const uuid = Uuid();
      final defaults = [
        CategoryEntity(
          id: uuid.v4(),
          name: 'عمل',
          colorValue: Colors.blue.value,
          iconCodePoint: Icons.work_outline.codePoint,
        ),
        CategoryEntity(
          id: uuid.v4(),
          name: 'شخصي',
          colorValue: Colors.green.value,
          iconCodePoint: Icons.person_outline.codePoint,
        ),
        CategoryEntity(
          id: uuid.v4(),
          name: 'دراسة',
          colorValue: Colors.purple.value,
          iconCodePoint: Icons.school_outlined.codePoint,
        ),
        CategoryEntity(
          id: uuid.v4(),
          name: 'مشاريع',
          colorValue: Colors.orange.value,
          iconCodePoint: Icons.rocket_launch_outlined.codePoint,
        ),
      ];

      for (final cat in defaults) {
        await box.put(cat.id, CategoryModel.fromEntity(cat));
      }
    }
  }

  static Future<void> close() async {
    await Hive.close();
  }
}
