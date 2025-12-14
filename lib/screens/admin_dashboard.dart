import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'group_settings_screen.dart';
import 'daily_word_editor_screen.dart';
import 'user_management_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '관리자 대시보드',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildActionCard(
            context,
            '오늘의 말씀 관리',
            '매일의 말씀과 목사님의 묵상 노트를 작성합니다.',
            Icons.book,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DailyWordEditorScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            '모임 설정',
            '모임 이름, 비밀번호, 호칭 등을 설정합니다.',
            Icons.settings,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GroupSettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            context,
            '회원 관리',
            '가입 대기중인 회원을 승인하거나 관리합니다.',
            Icons.people,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserManagementScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String startDescription,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppTheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    startDescription,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
