import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

class AddCategory extends CategoryEvent {
  final CategoryEntity category;
  const AddCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class UpdateCategory extends CategoryEvent {
  final CategoryEntity category;
  const UpdateCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoryEvent {
  final String categoryId;
  const DeleteCategory(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}
