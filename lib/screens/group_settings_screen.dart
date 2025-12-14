import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../models/group.dart';

class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({super.key});

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminTitleController = TextEditingController();
  final _userTitleController = TextEditingController();
  final _idController = TextEditingController(); // Added ID controller
  bool _isAutoJoin = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    final group = context.read<AppProvider>().currentGroup;
    _idController.text = group?.id ?? '';
    _nameController.text = group?.name ?? '';
    _passwordController.text = group?.password ?? '';
    _adminTitleController.text = group?.adminTitle ?? '목사님';
    _userTitleController.text = group?.userTitle ?? '성도님';
    _isAutoJoin = group?.isAutoJoin ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _adminTitleController.dispose();
    _userTitleController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    
    final provider = context.read<AppProvider>();
    final group = provider.currentGroup;

    try {
      if (group == null) {
        // Recovery Mode: Try to link to the provided Group ID
        final inputId = _idController.text.trim();
        if (inputId.isEmpty) throw '그룹 ID를 입력해주세요.';
        
        // Update User's groupId
        if (provider.user != null) {
           await UserService.updateUserGroup(provider.user!.id, inputId);
           // Refresh app state
           await provider.refreshCurrentUser();
           
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('그룹 연결을 시도했습니다. 잠시 후 화면이 갱신됩니다.')));
             Navigator.pop(context); // Close screen to refresh (or setState if we want to stay)
           }
        } else {
          throw '사용자 정보를 찾을 수 없습니다.';
        }
      } else {
        // Normal Update Mode
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
        
        final updatedGroup = group.copyWith(
          name: _nameController.text,
          password: _passwordController.text.isEmpty ? null : _passwordController.text,
          adminTitle: _adminTitleController.text,
          userTitle: _userTitleController.text,
          isAutoJoin: _isAutoJoin,
        );

        await provider.updateGroup(updatedGroup);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('설정이 저장되었습니다.')));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            if (context.read<AppProvider>().currentGroup == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                child: const Text('⚠️ 그룹 정보를 불러오지 못했습니다. 앱을 재시작하거나 네트워크를 확인해주세요.\n\n해결 방법: 아래 [모임 ID]에 올바른 그룹 ID(Firestore 문서 ID)를 입력하고 우측 상단 [저장]을 누르세요.', style: TextStyle(color: Colors.red, fontSize: 13)),
              ),
            _buildTextField(
              '모임 ID (식별용)', 
              _idController, // Use controller
              icon: LucideIcons.hash, 
              readOnly: context.read<AppProvider>().currentGroup != null // Editable only if null
            ),
            const SizedBox(height: 16),
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

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, bool obscureText = false, bool readOnly = false}) {
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
        readOnly: readOnly,
        style: readOnly ? TextStyle(color: Colors.grey[600]) : null,
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
