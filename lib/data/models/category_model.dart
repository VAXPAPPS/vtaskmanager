import '../../domain/entities/category_entity.dart';

/// Model تخزين التصنيف في قاعدة SQLite
class CategoryModel {
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

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      colorValue: map['color_value'] as int,
      iconCodePoint: map['icon_code_point'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_value': colorValue,
      'icon_code_point': iconCodePoint,
    };
  }
}
