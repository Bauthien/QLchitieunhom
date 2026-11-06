import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/group_provider.dart';
import '../../utils/categories.dart';
import '../../utils/format_helper.dart';

class AddExpenseScreen extends StatefulWidget {
  final String groupId;
  const AddExpenseScreen({super.key, required this.groupId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _category = Categories.all.first.name;
  DateTime _date = DateTime.now();
  String? _paidBy;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<GroupProvider>();
    final amount = double.parse(_amountCtrl.text.replaceAll('.', '').trim());

    provider.addExpense(
      groupId: widget.groupId,
      title: _titleCtrl.text.trim(),
      amount: amount,
      category: _category,
      paidBy: _paidBy ?? provider.currentUserId,
      date: _date,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã thêm khoản chi')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    final group = provider.getGroup(widget.groupId)!;
    _paidBy ??= provider.currentUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm khoản chi')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên khoản chi',
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập tên khoản chi'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền (đ)',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vui lòng nhập số tiền';
                    }
                    final n = double.tryParse(v.replaceAll('.', '').trim());
                    if (n == null) return 'Số tiền không hợp lệ';
                    if (n <= 0) return 'Số tiền phải lớn hơn 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Loại chi tiêu',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: Categories.all
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.name,
                          child: Row(
                            children: [
                              Icon(c.icon, size: 20),
                              const SizedBox(width: 8),
                              Text(c.name),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _paidBy,
                  decoration: const InputDecoration(
                    labelText: 'Người chi tiền',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: group.members
                      .map(
                        (m) => DropdownMenuItem(
                          value: m.userId,
                          child: Text(m.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _paidBy = v),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ngày chi',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(FormatHelper.date(_date)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú (không bắt buộc)',
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Lưu khoản chi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
