import '../entities/category_entity.dart';

/// واجهة مستودع التصنيفات (Abstract)
abstract class CategoryRepository {
  Future<List<CategoryEntity>> getAllCategories();
  Future<void> addCategory(CategoryEntity category);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(String id);
}
