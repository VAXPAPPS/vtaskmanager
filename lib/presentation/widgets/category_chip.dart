import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';

/// شريحة التصنيف
class CategoryChip extends StatelessWidget {
  final CategoryEntity category;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.25) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : color.withOpacity(0.2),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
