import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/group.dart';
import '../models/group_member.dart';

class GroupProvider extends ChangeNotifier {
  // Người dùng đang đăng nhập (giả lập, sau này lấy từ Firebase)
  final String currentUserId = 'u1';

  final List<Group> _groups = [
    Group(
      id: 'g1',
      name: 'Phòng trọ 301',
      description: 'Chi tiêu chung của 4 bạn cùng phòng',
      inviteCode: 'PT301',
      monthlyBudget: 5000000,
      members: [
        GroupMember(
          userId: 'u1',
          name: 'Bạn (Trưởng nhóm)',
          role: GroupRole.owner,
        ),
        GroupMember(userId: 'u2', name: 'Minh', role: GroupRole.manager),
        GroupMember(userId: 'u3', name: 'Lan', role: GroupRole.member),
        GroupMember(userId: 'u4', name: 'Hùng', role: GroupRole.member),
      ],
      expenses: [
        Expense(
          id: 'e1',
          title: 'Tiền điện tháng 10',
          amount: 650000,
          category: 'Điện nước',
          paidBy: 'u1',
          date: DateTime(2026, 11, 1),
          status: ExpenseStatus.approved,
        ),
        Expense(
          id: 'e2',
          title: 'Đi chợ nấu ăn',
          amount: 320000,
          category: 'Ăn uống',
          paidBy: 'u3',
          date: DateTime(2026, 11, 3),
          status: ExpenseStatus.pending,
        ),
        Expense(
          id: 'e3',
          title: 'Mua nước lọc',
          amount: 90000,
          category: 'Ăn uống',
          paidBy: 'u4',
          date: DateTime(2026, 11, 4),
          status: ExpenseStatus.pending,
        ),
      ],
    ),
    Group(
      id: 'g2',
      name: 'Du lịch Đà Lạt',
      description: 'Chuyến đi cuối năm',
      inviteCode: 'DL2026',
      monthlyBudget: 8000000,
      members: [
        GroupMember(userId: 'u1', name: 'Bạn', role: GroupRole.member),
        GroupMember(userId: 'u5', name: 'Trang', role: GroupRole.owner),
      ],
      expenses: [
        Expense(
          id: 'e4',
          title: 'Đặt homestay',
          amount: 2400000,
          category: 'Nhà ở',
          paidBy: 'u5',
          date: DateTime(2026, 11, 2),
          status: ExpenseStatus.approved,
        ),
      ],
    ),
  ];

  List<Group> get groups => List.unmodifiable(_groups);

  Group? getGroup(String id) {
    for (final g in _groups) {
      if (g.id == id) return g;
    }
    return null;
  }

  GroupRole? myRoleIn(Group group) => group.roleOf(currentUserId);

  /// Thêm khoản chi mới.
  /// Owner/Manager: tự động "Đã duyệt". Member: "Chờ duyệt".
  void addExpense({
    required String groupId,
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required DateTime date,
    String? note,
  }) {
    final group = getGroup(groupId);
    if (group == null) return;

    final role = group.roleOf(currentUserId);
    final autoApprove = role == GroupRole.owner || role == GroupRole.manager;

    group.expenses.insert(
      0,
      Expense(
        id: 'e${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        amount: amount,
        category: category,
        paidBy: paidBy,
        date: date,
        note: note,
        status: autoApprove ? ExpenseStatus.approved : ExpenseStatus.pending,
      ),
    );
    notifyListeners();
  }

  /// Duyệt khoản chi (chỉ Owner/Manager mới gọi được từ UI)
  void approveExpense(String groupId, String expenseId) {
    _updateStatus(groupId, expenseId, ExpenseStatus.approved);
  }

  /// Từ chối khoản chi kèm lý do
  void rejectExpense(String groupId, String expenseId, String reason) {
    _updateStatus(groupId, expenseId, ExpenseStatus.rejected, reason: reason);
  }

  void _updateStatus(
    String groupId,
    String expenseId,
    ExpenseStatus status, {
    String? reason,
  }) {
    final group = getGroup(groupId);
    if (group == null) return;
    final index = group.expenses.indexWhere((e) => e.id == expenseId);
    if (index == -1) return;
    group.expenses[index] = group.expenses[index].copyWith(
      status: status,
      rejectReason: reason,
    );
    notifyListeners();
  }
}
