import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../providers/app_provider.dart';
import '../services/user_management_service.dart';
import '../services/user_service.dart'; // For removing user (update groupId)

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _approveUser(String userId, String groupId) async {
    try {
      await UserManagementService.approveUser(userId, groupId);
      setState(() {}); // Refresh UI
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('가입이 승인되었습니다.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    }
  }

  Future<void> _rejectUser(String userId) async {
     try {
      await UserManagementService.rejectUser(userId);
      setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('가입 요청이 거절되었습니다.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    }
  }
  
  Future<void> _removeUser(String userId) async {
    // Should confirm dialog
    bool confirm = await showDialog(context: context, builder: (context) => AlertDialog(
      title: const Text('회원 추방'),
      content: const Text('정말 이 회원을 내보내시겠습니까?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('추방', style: TextStyle(color: Colors.red))),
      ],
    )) ?? false;

    if (confirm) {
      try {
        // Removing user means setting groupId back to null
        await UserService.updateUserRole(userId, UserRole.user); // Reset role if needed or kept
        // Actually UserService needs a method to clear groupId. We can use update but let's do it manually via a new helper or re-use existing.
        // For now, let's just clear groupId using Firestore directly via UserManagementService or similar.
        // Let's add removeMember to UserManagementService for clarity? Or just use rejectUser logic but clear groupId instead of pending.
        // Let's assume rejectUser clears pending. We need clearGroupId.
        // Actually, let's use a quick UserService update if possible or add to UserManagementService.
        // Adding deleteMembership to UserManagementService is best.
        // Wait, I can't modify Service file in this chunk easily. 
        // I will use UserService.deleteUser? No that deletes the document.
        // Let's implment _removeMember locally or assumes UserManagementService has it (I'll add it in next tool call if needed or use run_command).
        // For now, let's use UserManagementService.rejectUser Logic but on groupId field.
        // Ah, run_command created the service file. I can't edit it here.
        // I will just implement the logic here inside setState for now using Firestore directly? No, avoid direct DB in UI.
        // I'll call UserManagementService.rejectUser(userId) - wait, that clears pendingGroupId. 
        // I'll update UserManagementService via run_command to include removeMember.
      } catch (e) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentGroup = context.watch<AppProvider>().currentGroup;

    if (currentGroup == null) {
      return const Scaffold(body: Center(child: Text('그룹 정보를 불러올 수 없습니다.')));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('회원 관리', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: '승인 대기'),
            Tab(text: '멤버 목록'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingList(currentGroup.id),
          _buildMemberList(currentGroup.id),
        ],
      ),
    );
  }

  Widget _buildPendingList(String groupId) {
    return FutureBuilder<List<User>>(
      future: UserManagementService.getPendingMembers(groupId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final users = snapshot.data!;
        
        if (users.isEmpty) {
          return const Center(child: Text('승인 대기 중인 회원이 없습니다.', style: TextStyle(color: Colors.grey)));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = users[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null, child: user.avatarUrl.isEmpty ? const Icon(LucideIcons.user) : null),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(user.email, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.checkCircle, color: Colors.green),
                    onPressed: () => _approveUser(user.id, groupId),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.xCircle, color: Colors.red),
                    onPressed: () => _rejectUser(user.id),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMemberList(String groupId) {
    return FutureBuilder<List<User>>(
      future: UserManagementService.getMembers(groupId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final users = snapshot.data!;

        if (users.isEmpty) {
          return const Center(child: Text('그룹 멤버가 없습니다.', style: TextStyle(color: Colors.grey)));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = users[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
              ),
              child: Row(
                children: [
                  CircleAvatar(backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null, child: user.avatarUrl.isEmpty ? const Icon(LucideIcons.user) : null),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(user.email, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  // Hide remove button for admins to prevent self-lockout or handle safely
                  if (user.role != UserRole.admin && user.role != UserRole.superAdmin)
                  IconButton(
                    icon: const Icon(LucideIcons.userX, color: Colors.red),
                    onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('추방 기능은 곧 지원됩니다.')));
                         // Implement _removeUser logic once service is ready
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
