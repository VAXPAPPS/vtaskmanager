import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../application/task_bloc/task_bloc.dart';
import '../../application/task_bloc/task_event.dart';
import '../../application/category_bloc/category_bloc.dart';
import '../../application/category_bloc/category_state.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/priority_enum.dart';

/// حوار إضافة/تعديل مهمة
class AddTaskDialog extends StatefulWidget {
  final TaskEntity? existingTask; // null = إضافة جديدة

  const AddTaskDialog({super.key, this.existingTask});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late Priority _priority;
  late TaskStatus _status;
  String? _categoryId;
  DateTime? _dueDate;
  final List<Subtask> _subtasks = [];
  final _subtaskController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _priority = task?.priority ?? Priority.medium;
    _status = task?.status ?? TaskStatus.todo;
    _categoryId = task?.categoryId;
    _dueDate = task?.dueDate;
    if (task != null) {
      _subtasks.addAll(task.subtasks);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(230, 20, 20, 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // العنوان
                Row(
                  children: [
                    Icon(
                      _isEditing ? Icons.edit_rounded : Icons.add_task_rounded,
                      color: const Color(0xFF42A5F5),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isEditing ? 'تعديل المهمة' : 'مهمة جديدة',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      splashRadius: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // عنوان المهمة
                _label('العنوان'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 14),
                  decoration: _inputDecoration('أدخل عنوان المهمة'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'العنوان مطلوب' : null,
                ),
                const SizedBox(height: 16),

                // الوصف
                _label('الوصف'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 3,
                  decoration: _inputDecoration('وصف تفصيلي (اختياري)'),
                ),
                const SizedBox(height: 16),

                // الأولوية + الحالة
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('الأولوية'),
                          const SizedBox(height: 6),
                          _buildPrioritySelector(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('الحالة'),
                          const SizedBox(height: 6),
                          _buildStatusSelector(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // التصنيف
                _label('التصنيف'),
                const SizedBox(height: 6),
                _buildCategorySelector(),
                const SizedBox(height: 16),

                // تاريخ الاستحقاق
                _label('تاريخ الاستحقاق'),
                const SizedBox(height: 6),
                _buildDatePicker(),
                const SizedBox(height: 16),

                // المهام الفرعية
                _label('المهام الفرعية'),
                const SizedBox(height: 6),
                _buildSubtasks(),
                const SizedBox(height: 24),

                // أزرار الإجراءات
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF42A5F5,
                        ).withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _submit,
                      child: Text(
                        _isEditing ? 'حفظ التعديلات' : 'إضافة المهمة',
                      ),
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    const uuid = Uuid();
    final task = TaskEntity(
      id: widget.existingTask?.id ?? uuid.v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      priority: _priority,
      status: _status,
      categoryId: _categoryId,
      dueDate: _dueDate,
      subtasks: _subtasks,
      createdAt: widget.existingTask?.createdAt ?? DateTime.now(),
      completedAt: _status == TaskStatus.done
          ? (widget.existingTask?.completedAt ?? DateTime.now())
          : null,
    );

    if (_isEditing) {
      context.read<TaskBloc>().add(UpdateTask(task));
    } else {
      context.read<TaskBloc>().add(AddTask(task));
    }
    Navigator.pop(context);
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.5),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF42A5F5), width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _buildPrioritySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Priority>(
          value: _priority,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A1A),
          style: const TextStyle(fontSize: 13),
          items: Priority.values.map((p) {
            final label = switch (p) {
              Priority.urgent => '🔴 عاجل',
              Priority.high => '🟠 مرتفع',
              Priority.medium => '🔵 متوسط',
              Priority.low => '⚪ منخفض',
            };
            return DropdownMenuItem(value: p, child: Text(label));
          }).toList(),
          onChanged: (v) => setState(() => _priority = v!),
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TaskStatus>(
          value: _status,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A1A),
          style: const TextStyle(fontSize: 13),
          items: TaskStatus.values.map((s) {
            final label = switch (s) {
              TaskStatus.todo => '📋 للتنفيذ',
              TaskStatus.inProgress => '🔄 قيد التنفيذ',
              TaskStatus.done => '✅ مكتملة',
            };
            return DropdownMenuItem(value: s, child: Text(label));
          }).toList(),
          onChanged: (v) => setState(() => _status = v!),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is! CategoryLoaded) return const SizedBox();
        final cats = state.categories;
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _catChip('بدون', null, null, null),
            ...cats.map(
              (c) =>
                  _catChip(c.name, c.id, Color(c.colorValue), c.iconCodePoint),
            ),
          ],
        );
      },
    );
  }

  Widget _catChip(String label, String? id, Color? color, int? iconCode) {
    final selected = _categoryId == id;
    final chipColor = color ?? Colors.white;
    return GestureDetector(
      onTap: () => setState(() => _categoryId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? chipColor.withOpacity(0.15)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? chipColor.withOpacity(0.4)
                : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconCode != null) ...[
              Icon(
                IconData(iconCode, fontFamily: 'MaterialIcons'),
                size: 14,
                color: chipColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? chipColor : Colors.white.withOpacity(0.5),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF42A5F5),
                  surface: Color(0xFF1A1A1A),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _dueDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: Colors.white.withOpacity(0.4),
            ),
            const SizedBox(width: 8),
            Text(
              _dueDate != null
                  ? '${_dueDate!.year}/${_dueDate!.month}/${_dueDate!.day}'
                  : 'اختر تاريخ...',
              style: TextStyle(
                fontSize: 13,
                color: _dueDate != null
                    ? Colors.white.withOpacity(0.8)
                    : Colors.white.withOpacity(0.3),
              ),
            ),
            const Spacer(),
            if (_dueDate != null)
              GestureDetector(
                onTap: () => setState(() => _dueDate = null),
                child: Icon(
                  Icons.clear,
                  size: 16,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtasks() {
    return Column(
      children: [
        // قائمة المهام الفرعية
        ..._subtasks.asMap().entries.map((entry) {
          final i = entry.key;
          final st = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _subtasks[i] = st.copyWith(isCompleted: !st.isCompleted);
                    });
                  },
                  child: Icon(
                    st.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 18,
                    color: st.isCompleted
                        ? const Color(0xFF4CAF50)
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    st.title,
                    style: TextStyle(
                      fontSize: 13,
                      decoration: st.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: st.isCompleted
                          ? Colors.white.withOpacity(0.3)
                          : Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _subtasks.removeAt(i));
                  },
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          );
        }),
        // حقل إضافة مهمة فرعية
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _subtaskController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'أضف مهمة فرعية...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.2),
                    fontSize: 12,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onSubmitted: (_) => _addSubtask(),
              ),
            ),
            GestureDetector(
              onTap: _addSubtask,
              child: Icon(
                Icons.add_circle_outline,
                size: 18,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtasks.add(Subtask(id: const Uuid().v4(), title: text));
      _subtaskController.clear();
    });
  }
}
