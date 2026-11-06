enum GroupRole { owner, manager, member }

extension GroupRoleExt on GroupRole {
  String get label {
    switch (this) {
      case GroupRole.owner:
        return 'Trưởng nhóm';
      case GroupRole.manager:
        return 'Thủ quỹ';
      case GroupRole.member:
        return 'Thành viên';
    }
  }
}

class GroupMember {
  final String userId;
  final String name;
  final GroupRole role;

  GroupMember({required this.userId, required this.name, required this.role});
}
