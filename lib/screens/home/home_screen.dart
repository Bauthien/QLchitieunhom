import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qlchitieunhom/models/group_member.dart';

import '../../providers/group_provider.dart';
import '../../models/group.dart';
import '../../utils/format_helper.dart';
import '../../services/auth_service.dart';
import '../group/group_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GroupProvider>();
    final groups = provider.groups;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhóm của tôi'),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().logout(),
          ),
        ],
      ),
      body: groups.isEmpty
          ? const Center(child: Text('Bạn chưa tham gia nhóm nào'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, i) =>
                  _GroupCard(group: groups[i], provider: provider),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tạo nhóm: sẽ làm ở bước sau')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tạo nhóm'),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final Group group;
  final GroupProvider provider;

  const _GroupCard({required this.group, required this.provider});

  @override
  Widget build(BuildContext context) {
    final role = provider.myRoleIn(group);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GroupDetailScreen(groupId: group.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.groups)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text('${group.members.length} thành viên'),
                      ],
                    ),
                  ),
                  if (role != null)
                    Chip(
                      label: Text(role.label),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng chi: ${FormatHelper.money(group.totalApproved)}'),
                  if (group.pendingCount > 0)
                    Text(
                      '${group.pendingCount} chờ duyệt',
                      style: const TextStyle(color: Colors.orange),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
