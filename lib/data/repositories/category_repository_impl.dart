import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/category_model.dart';

/// تنفيذ مستودع التصنيفات
class CategoryRepositoryImpl implements CategoryRepository {
  final LocalDataSource _localDataSource;

  CategoryRepositoryImpl(this._localDataSource);

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    final models = _localDataSource.getAllCategories();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    await _localDataSource.addCategory(model);
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    await _localDataSource.updateCategory(model);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _localDataSource.deleteCategory(id);
  }
}
