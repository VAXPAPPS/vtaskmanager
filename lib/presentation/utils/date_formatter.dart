import 'package:intl/intl.dart';

/// أدوات تنسيق التواريخ
class DateFormatter {
  static final DateFormat _dateFormat = DateFormat('yyyy/MM/dd');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy/MM/dd HH:mm');
  static final DateFormat _timeAgo = DateFormat('HH:mm');

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return _dateTimeFormat.format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'اليوم ${_timeAgo.format(date)}';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return 'قبل ${diff.inDays} أيام';
    } else {
      return formatDate(date);
    }
  }

  static String dueLabel(DateTime? dueDate) {
    if (dueDate == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final diff = due.difference(today).inDays;

    if (diff < 0) return 'متأخر بـ ${-diff} يوم';
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'غدًا';
    if (diff < 7) return 'بعد $diff أيام';
    return formatDate(dueDate);
  }
}
