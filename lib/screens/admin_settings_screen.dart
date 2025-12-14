import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'group_settings_screen.dart';
import 'user_management_screen.dart';
import 'super_user_management_screen.dart';
import 'mock_data_management_screen.dart';

class AdminSettingsScreen extends StatelessWidget {
  final VoidCallback? onOpenDrawer;

  const AdminSettingsScreen({super.key, this.onOpenDrawer});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;
    final isSuperAdmin = user?.role == UserRole.superAdmin;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: onOpenDrawer != null 
          ? IconButton(
              icon: const Icon(LucideIcons.menu, color: Colors.black),
              onPressed: onOpenDrawer,
            )
          : null,
        title: const Text('관리자 설정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('모임 관리'),
            _buildSettingTile(
              context,
              icon: LucideIcons.settings,
              title: '모임 정보 설정',
              subtitle: '이름, 비밀번호, 호칭 관리',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupSettingsScreen())),
            ),
            const SizedBox(height: 12),
            _buildSettingTile(
              context,
              icon: LucideIcons.users,
              title: '회원 관리',
              subtitle: '가입 승인, 멤버 관리',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen())),
            ),

            if (isSuperAdmin) ...[
              const SizedBox(height: 32),
              _buildSectionHeader('슈퍼 관리자 권한'),
              _buildSettingTile(
                context,
                icon: LucideIcons.userCog,
                title: '전체 계정 관리',
                subtitle: '모든 사용자의 권한 및 상태 관리',
                iconColor: Colors.purple,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuperUserManagementScreen())),
              ),
              const SizedBox(height: 12),
              _buildSettingTile(
                context,
                icon: LucideIcons.database,
                title: '데이터 초기화',
                subtitle: '테스트용 데이터 리셋',
                iconColor: Colors.orange,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MockDataManagementScreen())),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = AppTheme.primary,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        trailing: const Icon(LucideIcons.chevronRight, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}
