import 'package:flutter/material.dart';
import '../../domain/entities/priority_enum.dart';

/// شارة الأولوية
class PriorityBadge extends StatelessWidget {
  final Priority priority;
  final bool compact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.compact = false,
  });

  Color get _color {
    switch (priority) {
      case Priority.urgent:
        return const Color(0xFFFF4444);
      case Priority.high:
        return const Color(0xFFFF9800);
      case Priority.medium:
        return const Color(0xFF42A5F5);
      case Priority.low:
        return const Color(0xFF78909C);
    }
  }

  String get _label {
    switch (priority) {
      case Priority.urgent:
        return 'عاجل';
      case Priority.high:
        return 'مرتفع';
      case Priority.medium:
        return 'متوسط';
      case Priority.low:
        return 'منخفض';
    }
  }

  IconData get _icon {
    switch (priority) {
      case Priority.urgent:
        return Icons.priority_high_rounded;
      case Priority.high:
        return Icons.arrow_upward_rounded;
      case Priority.medium:
        return Icons.remove_rounded;
      case Priority.low:
        return Icons.arrow_downward_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: _color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: _color.withOpacity(0.4), blurRadius: 4)],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _color),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
