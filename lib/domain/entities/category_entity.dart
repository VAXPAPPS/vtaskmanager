import 'package:equatable/equatable.dart';

/// كيان التصنيف
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final int colorValue; // hex color as int
  final int iconCodePoint; // Material icon code point

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
  });

  CategoryEntity copyWith({
    String? id,
    String? name,
    int? colorValue,
    int? iconCodePoint,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }

  @override
  List<Object?> get props => [id, name, colorValue, iconCodePoint];
}
