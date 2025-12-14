import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../models/qt_log.dart';
import '../data/mock_data.dart'; // accessing constants directly for now
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../widgets/streak_modal.dart';
import 'profile_screen.dart'; // Kept for reference but likely replacing with my_info_screen
import 'my_info_screen.dart';
import 'qt_screen.dart';
import 'admin_dashboard.dart';
import 'super_admin_dashboard.dart';
import 'sign_up_screen.dart';
import 'daily_word_management_screen.dart';
import 'admin_settings_screen.dart';
import 'prayer_screen.dart';
import '../widgets/login_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, these might come from a provider
    final provider = context.watch<AppProvider>();
    final user = provider.user;
    final word = todaysWord;
    final streak = provider.streak;
    final currentMode = provider.currentMode;

    // Unified Scaffold for both User and Admin
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background might be different for admin
      drawer: user != null ? _buildDrawer(context, user, provider) : null,
      body: Builder(
        builder: (context) => _buildBody(context, provider, user, word, streak),
      ),
      bottomNavigationBar: _buildBottomNav(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, AppProvider provider, User? user, dynamic word, int streak) {
    // If not logged in, show Guest Home (which is effectively User Home logic handling null user)
    // If Admin Mode:
    // If Admin Mode:
    if (provider.isAdminMode) {
      if (provider.activeTab == ActiveTab.qt) {
        return const QTScreen();
      } else if (provider.activeTab == ActiveTab.prayer) {
        return const PrayerScreen(); // TODO: Add admin flag if we want moderation
      } else if (provider.activeTab == ActiveTab.settings) {
        return AdminSettingsScreen(
          onOpenDrawer: () => Scaffold.of(context).openDrawer(),
        );
      }
      // Fallback or default
      return const QTScreen();
    }

    // User Mode
    switch (provider.activeTab) {
      case ActiveTab.home:
        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildUserHome(context, user, word, streak),
          ),
        );
      case ActiveTab.qt:
        return const QTScreen();
      case ActiveTab.prayer:
        return const PrayerScreen();
      case ActiveTab.settings: // Fallback if switch happens while on settings
        return Container(); 
      default:
        return Container();
    }
  }

  Widget _buildBottomNav(BuildContext context, AppProvider provider) {
    if (provider.isAdminMode) {
      // 3 Tabs for Admin - 사용자 네비게이션과 동일한 스타일
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, provider, ActiveTab.settings, LucideIcons.settings, '설정'),
                _buildNavItem(context, provider, ActiveTab.qt, LucideIcons.calendarDays, '말씀/묵상'),
                _buildNavItem(context, provider, ActiveTab.prayer, LucideIcons.heart, '기도 관리'),
              ],
            ),
          ),
        ),
      );
    }

    // 3 Tabs for User
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, provider, ActiveTab.home, LucideIcons.home, '홈'),
              _buildNavItem(context, provider, ActiveTab.qt, LucideIcons.bookOpen, '묵상'),
              _buildNavItem(context, provider, ActiveTab.prayer, LucideIcons.heart, '기도'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, AppProvider provider, ActiveTab tab, IconData icon, String label) {
    final isActive = provider.activeTab == tab;
    return GestureDetector(
      onTap: () => provider.setActiveTab(tab),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 62,
        height: 56,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? AppTheme.primary : Colors.grey, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.primary : Colors.grey,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, User user, AppProvider provider) {
    final group = provider.currentGroup;
    // Determine title to display next to name
    String displayTitle = '성도님'; // Default fallback
    if (group != null) {
      if (user.role == UserRole.admin || user.role == UserRole.superAdmin) {
        displayTitle = user.adminName ?? group.adminTitle; // User specific or Group default
      } else {
        displayTitle = user.userName ?? group.userTitle;
      }
    } else {
        // No group, fallback based on role if needed, or just defaults
         if (user.role == UserRole.admin || user.role == UserRole.superAdmin) {
            displayTitle = user.adminName ?? '목사님';
         } else {
            displayTitle = user.userName ?? '성도님';
         }
    }

    final groupName = group?.name ?? '';
    final isAdminOrSuper = user.role == UserRole.admin || user.role == UserRole.superAdmin;
    
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.75, // 화면의 75%로 너비 제한
      child: Column(
        children: [
          // Header Section with Primary Gradient - 콤팩트하게 수정
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Row - 프로필과 정보, X버튼을 가로로 배치
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Image
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundImage: (user.avatarUrl.isNotEmpty) ? NetworkImage(user.avatarUrl) : null,
                            child: (user.avatarUrl.isEmpty) ? Text(user.name.isNotEmpty ? user.name[0] : 'U', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)) : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Name, Title, Group
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    displayTitle,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                groupName,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Close Button - 프로필 우측에 배치
                        // IconButton(
                        //   icon: const Icon(LucideIcons.x, color: Colors.white, size: 20),
                        //   padding: EdgeInsets.zero,
                        //   constraints: const BoxConstraints(),
                        //   onPressed: () => Navigator.pop(context),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Role Badge - 크기 축소
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            user.role == UserRole.superAdmin 
                              ? LucideIcons.crown 
                              : (user.role == UserRole.admin ? LucideIcons.shield : LucideIcons.user),
                            color: user.role == UserRole.superAdmin 
                              ? Colors.amber 
                              : Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.role.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                // Admin Mode Toggle (only for admin/superAdmin) - 콤팩트하게 수정
                if (isAdminOrSuper) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              LucideIcons.shieldCheck,
                              color: AppTheme.primary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '관리자 모드',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  provider.isAdminMode 
                                    ? '관리자 권한으로 접속 중' 
                                    : '사용자 모드로 접속 중',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: provider.isAdminMode,
                              onChanged: (value) {
                                if (value) {
                                  provider.changeMode(user.role);
                                } else {
                                  provider.changeMode(UserRole.user);
                                }
                              },
                              activeColor: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, indent: 12, endIndent: 12, color: Colors.grey[200]),
                ],
                
                // My Info - 콤팩트하게 수정
                ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(vertical: -2),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.settings, color: Colors.grey[600], size: 16),
                  ),
                  title: const Text(
                    '내 정보 수정',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                  trailing: Icon(LucideIcons.chevronRight, color: Colors.grey[400], size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyInfoScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Logout Button at Bottom - 콤팩트하게 수정
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: SafeArea(
              top: false,
              child: ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -2),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Icon(LucideIcons.logOut, color: Colors.grey[500], size: 18),
                title: Text(
                  '로그아웃',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  provider.logout();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHome(BuildContext context, User? user, dynamic word, int streak) {
    final provider = context.watch<AppProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 가입 대기 상태 배너
        if (provider.isPendingGroupApproval)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.clock, color: Colors.orange[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '가입 승인 대기 중',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '모임 관리자의 승인을 기다리고 있습니다',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Header: User & Streak
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(
              builder: (context) => GestureDetector(
                onTap: () {
                  if (user == null) {
                    // Show Login Dialog
                    _showLoginDialog(context);
                  } else {
                    // Open Aside (Drawer)
                    Scaffold.of(context).openDrawer();
                  }
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage: (user != null && user.avatarUrl.isNotEmpty) ? NetworkImage(user.avatarUrl) : null,
                          child: (user == null || user.avatarUrl.isEmpty) ? const Icon(LucideIcons.user, color: Colors.grey) : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                        user != null ? '환영합니다 👋' : '로그인이 필요합니다',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        user != null ? user.name : '게스트',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ), // Closing parenthesis for Builder
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => StreakModal(streak: streak),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[100]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: AppTheme.pointGradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.point.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.flame, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '연속 묵상',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$streak일째',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.point[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 14),

        // Today's Word Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[100]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.primary, // Using primary color instead of complex gradient for simplicity, or we can use gradient
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.bookOpen, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      '오늘의 말씀',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Text(
                        word.date,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Scripture
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.reference,
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      word.scripture,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.6,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Pastor Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.messageCircle, size: 16, color: Colors.grey[400]),
                              const SizedBox(width: 8),
                              Text(
                                '묵상 포인트',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            word.pastorNote,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action Button (Moved inside card)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final provider = context.read<AppProvider>();
                          final user = provider.user;
                          
                          // Check for today's log - only if user is logged in
                          QTLog? todayLog;
                          if (user != null) {
                            final qtLogs = provider.qtLogs;
                            final todayLogIndex = qtLogs.indexWhere((l) => l.date == currentDate && l.userId == user.id);
                            todayLog = todayLogIndex != -1 ? qtLogs[todayLogIndex] : null;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => QTWriteScreen(existingLog: todayLog)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          shadowColor: AppTheme.primary.withOpacity(0.3),
                          elevation: 8,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.penTool, size: 20),
                            SizedBox(width: 8),
                            Text('오늘 묵상 기록하기'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLoginDialog(BuildContext context) {
    showLoginDialog(context);
  }
}


