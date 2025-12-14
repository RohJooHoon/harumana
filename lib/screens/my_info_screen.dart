import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../models/user.dart';
import '../models/group.dart';
import '../theme/app_theme.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  late TextEditingController _nameController;
  String? _selectedGroupId;
  List<Group> _groups = [];
  bool _isLoadingGroups = true;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    final user = provider.user;
    final group = provider.currentGroup;
    _nameController = TextEditingController(text: user?.name ?? '');
    _selectedGroupId = group?.id;
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final provider = context.read<AppProvider>();
      final groups = await provider.getAllGroups();
      if (mounted) {
        setState(() {
          _groups = groups;
          _isLoadingGroups = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingGroups = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final provider = context.read<AppProvider>();
    final user = provider.user;
    final currentGroup = provider.currentGroup;
    final currentPendingGroupId = user?.pendingGroupId;

    try {
      // 이름 저장
      if (_nameController.text.trim().isNotEmpty) {
        await provider.updateUserName(_nameController.text.trim());
      }

      // 그룹 변경 (USER 타입일 때만)
      bool? directlyJoined;
      bool clearedGroup = false;

      if (user?.role == UserRole.user) {
        // 그룹 해제 선택 (개별 사용자)
        if (_selectedGroupId == null && (currentGroup?.id != null || currentPendingGroupId != null)) {
          await provider.clearUserGroup();
          clearedGroup = true;
        }
        // 그룹 변경 (새 그룹 선택)
        else if (_selectedGroupId != null &&
            _selectedGroupId != currentGroup?.id &&
            _selectedGroupId != currentPendingGroupId) {
          directlyJoined = await provider.updateUserGroupId(_selectedGroupId!);
        }
      }

      if (mounted) {
        String message;
        if (clearedGroup) {
          message = '그룹에서 탈퇴하여 개별 사용자로 전환되었습니다.';
        } else if (directlyJoined == true) {
          message = '모임 가입이 완료되었습니다.';
        } else if (directlyJoined == false) {
          message = '가입 신청이 완료되었습니다. 관리자 승인을 기다려주세요.';
        } else {
          message = '정보가 저장되었습니다.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _handleChangePhoto() {
    // TODO: 실제 이미지 선택 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('프로필 사진 변경 기능은 준비 중입니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;
    final group = provider.currentGroup;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('내 정보 수정')),
        body: const Center(child: Text('로그인이 필요합니다.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('내 정보 수정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 섹션
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  // 프로필 이미지 + 변경 버튼
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[200]!, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundImage: (user.avatarUrl.isNotEmpty) ? NetworkImage(user.avatarUrl) : null,
                          backgroundColor: Colors.grey[100],
                          child: (user.avatarUrl.isEmpty)
                              ? const Icon(LucideIcons.user, size: 40, color: Colors.grey)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _handleChangePhoto,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(LucideIcons.camera, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '사진을 눌러 변경하세요',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 이름 입력 섹션
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이름',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: '이름을 입력하세요',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 계정 정보
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '계정 정보',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('이메일', user.email),
                  const Divider(height: 24),
                  // Logic to determine title
                  Builder(
                    builder: (context) {
                      String displayTitle = '성도님';
                      if (group != null) {
                        if (user.role == UserRole.admin || user.role == UserRole.superAdmin) {
                          displayTitle = user.adminName ?? group.adminTitle;
                        } else {
                          displayTitle = user.userName ?? group.userTitle;
                        }
                      } else {
                         if (user.role == UserRole.admin || user.role == UserRole.superAdmin) {
                            displayTitle = user.adminName ?? '목사님';
                         } else {
                            displayTitle = user.userName ?? '성도님';
                         }
                      }
                      return _buildInfoRow('직분', displayTitle);
                    }
                  ),
                  const Divider(height: 24),
                  _buildGroupSelector(user, group),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.save, size: 18),
                    SizedBox(width: 8),
                    Text('저장하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildGroupSelector(User user, Group? group) {
    final isUser = user.role == UserRole.user;

    if (isUser) {
      // USER 타입만 드롭다운으로 그룹 변경 가능
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '소속 그룹',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (_isLoadingGroups)
            const Center(child: CircularProgressIndicator())
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _selectedGroupId,
                  isExpanded: true,
                  icon: const Icon(LucideIcons.chevronDown, size: 18),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  items: [
                    // 개별 사용자 옵션 (그룹 없음)
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('개별 사용자 (그룹 없음)'),
                    ),
                    // 그룹 목록
                    ..._groups.map((g) {
                      return DropdownMenuItem<String?>(
                        value: g.id,
                        child: Text(g.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedGroupId = value);
                  },
                ),
              ),
            ),
        ],
      );
    } else {
      // Admin/SuperAdmin은 그룹 변경 불가 (읽기 전용)
      return _buildInfoRow('소속 그룹', group?.name ?? '없음');
    }
  }
}
