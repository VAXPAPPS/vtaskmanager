import 'package:flutter/material.dart';

/// شريط جانبي للتنقل
class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const _items = [
    _SidebarItem(icon: Icons.dashboard_rounded, label: 'الرئيسية'),
    _SidebarItem(icon: Icons.list_alt_rounded, label: 'المهام'),
    _SidebarItem(icon: Icons.view_kanban_rounded, label: 'Kanban'),
    _SidebarItem(icon: Icons.category_rounded, label: 'التصنيفات'),
    _SidebarItem(icon: Icons.bar_chart_rounded, label: 'الإحصائيات'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 56), // مسافة للـ AppBar
          // الشعار
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF42A5F5), Color(0xFF7C4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 24),
          // القائمة
          ...List.generate(_items.length, (index) {
            return _buildItem(index);
          }),
          const Spacer(),
          // إعدادات
          _buildBottomItem(Icons.settings_outlined, 'إعدادات'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = _items[index];
    final selected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 68,
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // مؤشر التحديد
            if (selected)
              Positioned(
                left: 0,
                child: Container(
                  width: 3,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            // الأيقونة
            Tooltip(
              message: item.label,
              preferBelow: false,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF42A5F5).withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: 22,
                  color: selected
                      ? const Color(0xFF42A5F5)
                      : Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomItem(IconData icon, String label) {
    return Tooltip(
      message: label,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 22, color: Colors.white.withOpacity(0.3)),
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;
  const _SidebarItem({required this.icon, required this.label});
}
