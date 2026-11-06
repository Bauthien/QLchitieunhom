import '../models/group_member.dart';

class PermissionHelper {
  static bool canApproveExpense(GroupRole role) =>
      role == GroupRole.owner || role == GroupRole.manager;

  static bool canManageMembers(GroupRole role) => role == GroupRole.owner;

  static bool canInviteMember(GroupRole role) =>
      role == GroupRole.owner || role == GroupRole.manager;

  static bool canExportReport(GroupRole role) =>
      role == GroupRole.owner || role == GroupRole.manager;

  static bool canDeleteGroup(GroupRole role) => role == GroupRole.owner;
}
