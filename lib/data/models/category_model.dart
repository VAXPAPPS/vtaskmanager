import 'package:hive/hive.dart';
import '../../domain/entities/category_entity.dart';

/// Hive Model للتصنيف
class CategoryModel extends HiveObject {
  String id;
  String name;
  int colorValue;
  int iconCodePoint;

  CategoryModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
  });

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      colorValue: entity.colorValue,
      iconCodePoint: entity.iconCodePoint,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
    );
  }
}

/// Hive Adapter يدوي لـ CategoryModel
class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 1;

  @override
  CategoryModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return CategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      colorValue: fields[2] as int,
      iconCodePoint: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer.writeByte(4);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.colorValue);
    writer.writeByte(3);
    writer.write(obj.iconCodePoint);
  }
}
