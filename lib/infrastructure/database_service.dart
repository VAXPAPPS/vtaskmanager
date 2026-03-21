import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../data/models/category_model.dart';
import '../domain/entities/category_entity.dart';

/// خدمة تهيئة وإدارة قاعدة بيانات SQLite.
class DatabaseService {
  static Database? _database;

  static Future<void> init() async {
    await database;
    await _seedDefaultCategories();
  }

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  static Future<Database> _openDatabase() async {
    final isDesktop =
        !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

    if (isDesktop) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'vtaskmanager.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            priority_index INTEGER NOT NULL,
            status_index INTEGER NOT NULL,
            category_id TEXT,
            due_date TEXT,
            subtasks_json TEXT NOT NULL DEFAULT '[]',
            created_at TEXT NOT NULL,
            completed_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            color_value INTEGER NOT NULL,
            icon_code_point INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  static Future<void> _seedDefaultCategories() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories'),
    );

    if ((count ?? 0) > 0) return;

    const uuid = Uuid();
    final defaults = [
      CategoryEntity(
        id: uuid.v4(),
        name: 'عمل',
        colorValue: Colors.blue.toARGB32(),
        iconCodePoint: Icons.work_outline.codePoint,
      ),
      CategoryEntity(
        id: uuid.v4(),
        name: 'شخصي',
        colorValue: Colors.green.toARGB32(),
        iconCodePoint: Icons.person_outline.codePoint,
      ),
      CategoryEntity(
        id: uuid.v4(),
        name: 'دراسة',
        colorValue: Colors.purple.toARGB32(),
        iconCodePoint: Icons.school_outlined.codePoint,
      ),
      CategoryEntity(
        id: uuid.v4(),
        name: 'مشاريع',
        colorValue: Colors.orange.toARGB32(),
        iconCodePoint: Icons.rocket_launch_outlined.codePoint,
      ),
    ];

    final batch = db.batch();
    for (final category in defaults) {
      batch.insert('categories', CategoryModel.fromEntity(category).toMap());
    }
    await batch.commit(noResult: true);
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
