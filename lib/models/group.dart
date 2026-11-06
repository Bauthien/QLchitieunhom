import 'group_member.dart';
import 'expense.dart';

class Group {
  final String id;
  final String name;
  final String description;
  final String inviteCode;
  final double monthlyBudget;
  final List<GroupMember> members;
  final List<Expense> expenses;

  Group({
    required this.id,
    required this.name,
    this.description = '',
    required this.inviteCode,
    this.monthlyBudget = 0,
    required this.members,
    required this.expenses,
  });

  /// Tổng chi đã được duyệt
  double get totalApproved => expenses
      .where((e) => e.status == ExpenseStatus.approved)
      .fold(0.0, (sum, e) => sum + e.amount);

  /// Số khoản đang chờ duyệt
  int get pendingCount =>
      expenses.where((e) => e.status == ExpenseStatus.pending).length;

  /// Lấy vai trò của một người dùng trong nhóm
  GroupRole? roleOf(String userId) {
    for (final m in members) {
      if (m.userId == userId) return m.role;
    }
    return null;
  }
}
