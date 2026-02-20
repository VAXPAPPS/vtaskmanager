import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc(this._categoryRepository) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoad);
    on<AddCategory>(_onAdd);
    on<UpdateCategory>(_onUpdate);
    on<DeleteCategory>(_onDelete);
  }

  Future<void> _onLoad(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await _categoryRepository.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('فشل تحميل التصنيفات: $e'));
    }
  }

  Future<void> _onAdd(AddCategory event, Emitter<CategoryState> emit) async {
    try {
      await _categoryRepository.addCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('فشل إضافة التصنيف: $e'));
    }
  }

  Future<void> _onUpdate(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.updateCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('فشل تحديث التصنيف: $e'));
    }
  }

  Future<void> _onDelete(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.deleteCategory(event.categoryId);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('فشل حذف التصنيف: $e'));
    }
  }
}
