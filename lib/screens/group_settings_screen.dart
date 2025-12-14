import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/group.dart';

class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({super.key});

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _adminTitleController;
  late TextEditingController _userTitleController;
  bool _isAutoJoin = false;
  
  @override
  void initState() {
    super.initState();
    final group = context.read<AppProvider>().currentGroup;
    _nameController = TextEditingController(text: group?.name ?? '');
    _passwordController = TextEditingController(text: group?.password ?? '');
    _adminTitleController = TextEditingController(text: group?.adminTitle ?? '목사님');
    _userTitleController = TextEditingController(text: group?.userTitle ?? '성도님');
    _isAutoJoin = group?.isAutoJoin ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _adminTitleController.dispose();
    _userTitleController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final provider = context.read<AppProvider>();
    final currentGroup = provider.currentGroup;
    
    if (currentGroup != null) {
      // Validate inputs
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모임 이름을 입력해주세요.')));
        return;
      }
      if (_adminTitleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('관리자 호칭을 입력해주세요.')));
        return;
      }
      if (_userTitleController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('구성원 호칭을 입력해주세요.')));
        return;
      }
      
      final updatedGroup = currentGroup.copyWith(
        name: _nameController.text,
        password: _passwordController.text.isEmpty ? null : _passwordController.text,
        adminTitle: _adminTitleController.text,
        userTitle: _userTitleController.text,
        isAutoJoin: _isAutoJoin,
      );
      
      try {
        // Update Provider (which updates Firestore)
        await provider.updateGroup(updatedGroup); 
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('설정이 저장되었습니다.')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('저장 실패: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('모임 설정', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('저장', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('기본 정보'),
            _buildTextField('모임 이름', _nameController, icon: LucideIcons.users),
            const SizedBox(height: 24),
            
            _buildSectionHeader('호칭 설정'),
            const Text(
              '관리자와 구성원을 부르는 호칭을 설정해주세요.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildTextField('관리자 호칭 (예: 목사님, 리더님)', _adminTitleController, icon: LucideIcons.crown),
            const SizedBox(height: 16),
            _buildTextField('구성원 호칭 (예: 성도님, 조원님)', _userTitleController, icon: LucideIcons.user),
            const SizedBox(height: 24),

            _buildSectionHeader('가입 설정'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: SwitchListTile(
                title: const Text('자동 승인'),
                subtitle: const Text('가입 신청 시 관리자 승인 없이 바로 가입됩니다.'),
                value: _isAutoJoin,
                activeColor: AppTheme.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    _isAutoJoin = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('보안 설정'),
            const Text(
              '모임 가입 시 필요한 비밀번호를 설정할 수 있습니다. 비워두면 비밀번호 없이 가입 신청이 가능합니다.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildTextField('모임 비밀번호', _passwordController, icon: LucideIcons.lock, obscureText: false),  
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400]) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
