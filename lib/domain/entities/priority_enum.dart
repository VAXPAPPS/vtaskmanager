/// مستويات أولوية المهام
enum Priority {
  urgent, // 🔴 عاجل
  high, // 🟠 مرتفع
  medium, // 🔵 متوسط
  low, // ⚪ منخفض
}

/// حالات المهام
enum TaskStatus {
  todo, // 📋 للتنفيذ
  inProgress, // 🔄 قيد التنفيذ
  done, // ✅ مكتملة
}
