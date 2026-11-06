enum ExpenseStatus { pending, approved, rejected }

extension ExpenseStatusExt on ExpenseStatus {
  String get label {
    switch (this) {
      case ExpenseStatus.pending:
        return 'Chờ duyệt';
      case ExpenseStatus.approved:
        return 'Đã duyệt';
      case ExpenseStatus.rejected:
        return 'Bị từ chối';
    }
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String paidBy;
  final DateTime date;
  final String? note;
  final ExpenseStatus status;
  final String? rejectReason;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.paidBy,
    required this.date,
    this.note,
    this.status = ExpenseStatus.pending,
    this.rejectReason,
  });

  Expense copyWith({ExpenseStatus? status, String? rejectReason}) {
    return Expense(
      id: id,
      title: title,
      amount: amount,
      category: category,
      paidBy: paidBy,
      date: date,
      note: note,
      status: status ?? this.status,
      rejectReason: rejectReason ?? this.rejectReason,
    );
  }
}
