import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Users
    final List<User> users = [
      const User(id: 'u2', name: '김철수', email: 'chulsoo@example.com', avatarUrl: 'https://picsum.photos/id/91/200/200', role: UserRole.user),
      const User(id: 'u3', name: '이영희', email: 'young@example.com', avatarUrl: 'https://picsum.photos/id/177/200/200', role: UserRole.user),
      const User(id: 'u4', name: '박민수', email: 'min@example.com', avatarUrl: 'https://picsum.photos/id/338/200/200', role: UserRole.user),
    ];

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
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
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
                  backgroundImage: NetworkImage(user.avatarUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.userX, color: Colors.red),
                  onPressed: () {
                    // TODO: Implement Remove Logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${user.name} 회원을 탈퇴 처리했습니다.')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
