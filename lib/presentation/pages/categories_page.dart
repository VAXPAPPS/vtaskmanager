import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../application/category_bloc/category_bloc.dart';
import '../../application/category_bloc/category_event.dart';
import '../../application/category_bloc/category_state.dart';
import '../../domain/entities/category_entity.dart';

/// صفحة إدارة التصنيفات
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'التصنيفات',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddCategory(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF42A5F5), Color(0xFF7C4DFF)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'تصنيف جديد',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CategoryLoaded) {
                  if (state.categories.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد تصنيفات',
                        style: TextStyle(color: Colors.white.withOpacity(0.3)),
                      ),
                    );
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                        ),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final cat = state.categories[index];
                      return _buildCategoryCard(context, cat);
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryEntity cat) {
    final color = Color(cat.colorValue);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
              // حذف
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A1A),
                      title: const Text('حذف التصنيف'),
                      content: Text('هل تريد حذف "${cat.name}"؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<CategoryBloc>().add(
                              DeleteCategory(cat.id),
                            );
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            'حذف',
                            style: TextStyle(color: Color(0xFFFF4444)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategory(BuildContext context) {
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;
    int selectedIcon = Icons.folder_outlined.codePoint;

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
      Colors.indigo,
    ];

    final icons = [
      Icons.folder_outlined,
      Icons.work_outline,
      Icons.person_outline,
      Icons.school_outlined,
      Icons.rocket_launch_outlined,
      Icons.code_rounded,
      Icons.design_services_rounded,
      Icons.fitness_center_rounded,
      Icons.shopping_bag_outlined,
      Icons.music_note_rounded,
      Icons.favorite_outline,
      Icons.home_outlined,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: const Color.fromARGB(230, 20, 20, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تصنيف جديد',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'اسم التصنيف',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'اللون',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((c) {
                    final isSelected = selectedColor.value == c.value;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = c),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'الأيقونة',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: icons.map((ic) {
                    final isSelected = selectedIcon == ic.codePoint;
                    return GestureDetector(
                      onTap: () =>
                          setDialogState(() => selectedIcon = ic.codePoint),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withOpacity(0.2)
                              : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(
                                  color: selectedColor.withOpacity(0.5),
                                )
                              : null,
                        ),
                        child: Icon(
                          ic,
                          size: 18,
                          color: isSelected
                              ? selectedColor
                              : Colors.white.withOpacity(0.4),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedColor.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) return;
                        context.read<CategoryBloc>().add(
                          AddCategory(
                            CategoryEntity(
                              id: const Uuid().v4(),
                              name: nameController.text.trim(),
                              colorValue: selectedColor.value,
                              iconCodePoint: selectedIcon,
                            ),
                          ),
                        );
                        Navigator.pop(ctx);
                      },
                      child: const Text('إضافة'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
