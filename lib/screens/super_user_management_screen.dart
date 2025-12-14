import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class SuperUserManagementScreen extends StatefulWidget {
  const SuperUserManagementScreen({super.key});

  @override
  State<SuperUserManagementScreen> createState() => _SuperUserManagementScreenState();
}

class _SuperUserManagementScreenState extends State<SuperUserManagementScreen> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = UserService.getAllUsers();
    });
  }

  Future<void> _handleUpdateRole(User user, UserRole newRole) async {
    // Logic for Super Admins is handled in Firebase Console, not here.
    
    // Safety Check: When demoting Admin to User, ensure at least 1 Admin remains in the group
    if (user.role == UserRole.admin && newRole == UserRole.user && user.groupId != null) {
      try {
        final users = await UserService.getAllUsers();
        // Count admins in this specific group
        final groupAdminCount = users.where((u) => u.groupId == user.groupId && u.role == UserRole.admin).length;
        
        if (groupAdminCount <= 1) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('해당 모임에 최소 1명의 관리자는 존재해야 합니다.')),
            );
            Navigator.pop(context); // Close bottom sheet
          }
          return;
        }
      } catch (e) {
        // Handle error safely
        return;
      }
    }

    try {
      await UserService.updateUserRole(user.id, newRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user.name}님의 권한이 변경되었습니다.')),
        );
        _refreshUsers();
        Navigator.pop(context); // Close bottom sheet
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('권한 변경 실패: $e')),
        );
      }
    }
  }

  Future<void> _handleDeleteUser(User user) async {
    // Super Admin deletion is not handled here
    if (user.role == UserRole.superAdmin) {
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('슈퍼 관리자는 앱에서 삭제할 수 없습니다.')),
          );
          Navigator.pop(context);
       }
       return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: Text('${user.name}님을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await UserService.deleteUser(user.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('계정이 삭제되었습니다.')),
          );
          _refreshUsers();
          Navigator.pop(context); // Close bottom sheet
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: $e')),
          );
        }
      }
    }
  }

  void _showUserOptions(User user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Don't allowing editing Super Admins via UI
        if (user.role == UserRole.superAdmin) {
           return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('${user.name} 계정 관리', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('슈퍼 관리자는 Firebase Console에서 관리해주세요.', style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('${user.name} 계정 관리', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const Divider(),
              // Super Admin promotion removed
              if (user.role != UserRole.admin)
                ListTile(
                  leading: const Icon(LucideIcons.shield, color: Colors.blue),
                  title: const Text('관리자로 변경'),
                  onTap: () => _handleUpdateRole(user, UserRole.admin),
                ),
              if (user.role != UserRole.user)
                ListTile(
                  leading: const Icon(LucideIcons.user, color: Colors.grey),
                  title: const Text('일반 사용자로 변경'),
                  onTap: () => _handleUpdateRole(user, UserRole.user),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: Colors.red),
                title: const Text('계정 삭제', style: TextStyle(color: Colors.red)),
                onTap: () => _handleDeleteUser(user),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('전체 계정 관리', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다: ${snapshot.error}'));
          }
          
          final allUsers = snapshot.data ?? [];
          
          if (allUsers.isEmpty) {
            return const Center(child: Text('가입된 사용자가 없습니다.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: allUsers.length,
            itemBuilder: (context, index) {
              final user = allUsers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: (user.avatarUrl.isNotEmpty) ? NetworkImage(user.avatarUrl) : null,
                      child: (user.avatarUrl.isEmpty) ? Text(user.name.isNotEmpty ? user.name[0] : 'U') : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              if (user.role == UserRole.superAdmin)
                                _buildRoleBadge('Super', Colors.purple)
                              else if (user.role == UserRole.admin)
                                _buildRoleBadge('Admin', Colors.blue)
                              else
                                 _buildRoleBadge('User', Colors.grey),
                            ],
                          ),
                          Text(
                            user.email,
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                          if (user.groupName != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                user.groupName!,
                                style: TextStyle(color: Colors.grey[400], fontSize: 11),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.moreHorizontal, color: Colors.grey),
                      onPressed: () => _showUserOptions(user),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRoleBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
