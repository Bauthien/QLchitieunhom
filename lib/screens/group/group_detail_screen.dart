import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/expense.dart';
import '../../models/group_member.dart';
import '../../providers/group_provider.dart';
import '../../utils/format_helper.dart';
import '../../utils/permission_helper.dart';
import '../expense/add_expense_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    final group = provider.getGroup(groupId);

    if (group == null) {
      return const Scaffold(body: Center(child: Text('Không tìm thấy nhóm')));
    }

    final role = provider.myRoleIn(group) ?? GroupRole.member;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(group.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chi tiêu'),
              Tab(text: 'Thành viên'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ExpenseTab(groupId: groupId, role: role),
            _MemberTab(groupId: groupId, role: role),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddExpenseScreen(groupId: groupId),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Thêm khoản chi'),
        ),
      ),
    );
  }
}

class _ExpenseTab extends StatelessWidget {
  final String groupId;
  final GroupRole role;
  const _ExpenseTab({required this.groupId, required this.role});

  Color _statusColor(ExpenseStatus s) {
    switch (s) {
      case ExpenseStatus.pending:
        return Colors.orange;
      case ExpenseStatus.approved:
        return Colors.green;
      case ExpenseStatus.rejected:
        return Colors.red;
    }
  }

  Future<void> _askReject(BuildContext context, String expenseId) async {
    final ctrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lý do từ chối'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Nhập lý do...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
    if (reason != null && reason.isNotEmpty && context.mounted) {
      context.read<GroupProvider>().rejectExpense(groupId, expenseId, reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    final group = provider.getGroup(groupId)!;
    final canApprove = PermissionHelper.canApproveExpense(role);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng chi đã duyệt'),
                Text(
                  FormatHelper.money(group.totalApproved),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text('Vai trò của bạn: ${role.label}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...group.expenses.map((e) {
          final payer = group.members
              .firstWhere(
                (m) => m.userId == e.paidBy,
                orElse: () => GroupMember(
                  userId: e.paidBy,
                  name: 'Không rõ',
                  role: GroupRole.member,
                ),
              )
              .name;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        FormatHelper.money(e.amount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${e.category} • $payer • ${FormatHelper.date(e.date)}'),
                  const SizedBox(height: 8),
                  Text(
                    e.status.label,
                    style: TextStyle(
                      color: _statusColor(e.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (e.rejectReason != null)
                    Text(
                      'Lý do: ${e.rejectReason}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  // Chỉ Owner/Manager mới thấy nút Duyệt / Từ chối
                  if (canApprove && e.status == ExpenseStatus.pending)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _askReject(context, e.id),
                          child: const Text('Từ chối'),
                        ),
                        FilledButton(
                          onPressed: () => context
                              .read<GroupProvider>()
                              .approveExpense(groupId, e.id),
                          child: const Text('Duyệt'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _MemberTab extends StatelessWidget {
  final String groupId;
  final GroupRole role;
  const _MemberTab({required this.groupId, required this.role});

  @override
  Widget build(BuildContext context) {
    final group = context.watch<GroupProvider>().getGroup(groupId)!;
    final canInvite = PermissionHelper.canInviteMember(role);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (canInvite)
          Card(
            child: ListTile(
              leading: const Icon(Icons.key),
              title: const Text('Mã mời nhóm'),
              subtitle: Text(group.inviteCode),
            ),
          ),
        ...group.members.map(
          (m) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(m.name[0])),
              title: Text(m.name),
              trailing: Chip(
                label: Text(m.role.label),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
