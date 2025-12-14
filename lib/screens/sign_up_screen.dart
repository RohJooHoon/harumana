import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../models/group.dart';
import '../providers/app_provider.dart';
import '../data/mock_data.dart'; // To read mockGroups
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/group_service.dart';
import '../services/notification_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isAdmin = false; // false: User (Join), true: Admin (Create)
  bool _isLoading = false;
  String? _errorMessage;
  
  // Common
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Admin Group Create
  final _groupNameController = TextEditingController();
  // final _groupPasswordController = TextEditingController(); // Removed as per request
  final _adminTitleController = TextEditingController(text: '목사님');
  final _userTitleController = TextEditingController(text: '성도님');

  // User Group Join
  String? _selectedGroupId;
  bool _joinGroupLater = false;
  final _joinPasswordController = TextEditingController();
  
  List<Group> _availableGroups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await GroupService.getAllGroups();
      setState(() {
        _availableGroups = groups;
      });
    } catch (e) {
      print('Error loading groups: $e');
    }
  }
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _groupNameController.dispose();
    // _groupPasswordController.dispose();
    _adminTitleController.dispose();
    _userTitleController.dispose();
    _joinPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = '기본 정보를 모두 입력해주세요.');
      return;
    }

    if (_isAdmin) {
      // Create Group Logic
      if (_groupNameController.text.isEmpty) {
        setState(() => _errorMessage = '모임 이름을 입력해주세요.');
        return;
      }
    } else {
      // Join Group Logic
      if (!_joinGroupLater && _selectedGroupId == null) {
        setState(() => _errorMessage = '가입할 모임을 선택하거나 모임 없이 시작하기를 체크해주세요.');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create Firebase Auth user
      final credential = await AuthService.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        displayName: _nameController.text,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw '사용자 생성에 실패했습니다.';
      }

      // Determine role, groupId, and other metadata
      final UserRole role = _isAdmin ? UserRole.admin : UserRole.user;
      String? groupId = _isAdmin ? null : (_joinGroupLater ? null : _selectedGroupId);
      
      String? groupName;
      String? adminName;
      String? userName;

      if (_isAdmin) {
        // Creating a group
        groupName = _groupNameController.text;
        adminName = _adminTitleController.text;
        userName = _userTitleController.text;
        
        // Create actual Group document in Firestore
        groupId = await GroupService.createGroup(
          name: groupName,
          adminId: firebaseUser.uid,
          // password: null, // 초기 생성 시 비밀번호 없음
          adminTitle: adminName,
          userTitle: userName,
        );
      } else {
        // Joining a group
        if (!_joinGroupLater && _selectedGroupId != null) {
          // Find group name from real loaded data
          final group = _availableGroups.firstWhere(
            (g) => g.id == _selectedGroupId,
            orElse: () => const Group(
              id: '', 
              name: 'Unknown Group', 
              adminId: 'unknown', 
              adminTitle: '목사님', 
              userTitle: '성도님'
            ), // Fallback
          );
          
          // Verify Password if group has one
          if (group.password != null && group.password!.isNotEmpty) {
            if (_joinPasswordController.text != group.password) {
              setState(() {
                _isLoading = false;
                _errorMessage = '모임 비밀번호가 일치하지 않습니다.';
              });
              return;
            }
          }

          groupName = group.name;
          // In real implementation, we should copy these from the Group document or reference them
          adminName = group.adminName; 
          userName = group.userName; 
        }
      }

      // Save user to Firestore
      await UserService.createUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? _emailController.text,
        name: _nameController.text,
        photoUrl: null, // Default
        role: role,
        groupId: groupId,
        groupName: groupName,
        adminName: adminName,
        userName: userName,
      );

      // Check if user is in pending state (needs approval)
      // If group doesn't allow auto-join, create notification for admin
      if (!_isAdmin && !_joinGroupLater && _selectedGroupId != null) {
        final selectedGroup = _availableGroups.firstWhere(
          (g) => g.id == _selectedGroupId,
          orElse: () => const Group(id: '', name: '', adminId: ''),
        );

        if (!selectedGroup.isAutoJoin) {
          // Create notification for admin about pending approval
          await NotificationService().createPendingApprovalNotification(
            groupId: _selectedGroupId!,
            userId: firebaseUser.uid,
            userName: _nameController.text,
          );
        }
      }

      if (!mounted) return;

      // Refresh AppProvider with the new user from Firestore
      await context.read<AppProvider>().refreshCurrentUser();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isAdmin
              ? '모임이 생성되었습니다!'
              : (_joinGroupLater
                  ? '가입이 완료되었습니다!'
                  : ((_availableGroups.any((g) => g.id == _selectedGroupId && !g.isAutoJoin))
                      ? '가입 신청이 완료되었습니다. 관리자 승인을 기다려주세요.'
                      : '가입이 완료되었습니다!'))),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        // If Firestore write fails but Auth succeeded, we might want to cleanup Auth user 
        // to avoid "zombie" accounts, but for now just show error.
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('회원가입', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Role Selection Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildRoleTab('모임 들어가기', false)),
                  Expanded(child: _buildRoleTab('새 모임 만들기', true)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Error Message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.alertCircle, color: Colors.red[600], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Common Fields
            const Text('기본 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTextField('이름 (실명)', _nameController, icon: LucideIcons.user),
            const SizedBox(height: 12),
            _buildTextField('이메일', _emailController, icon: LucideIcons.mail),
            const SizedBox(height: 12),
            _buildTextField('비밀번호', _passwordController, icon: LucideIcons.lock, obscureText: true),
            
            const SizedBox(height: 32),

            // Role Specific Fields
            if (_isAdmin) ...[
              const Text('모임 생성 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField('모임 이름', _groupNameController, icon: LucideIcons.users),
              const SizedBox(height: 12),
              // _buildTextField('모임 비밀번호 (선택)', _groupPasswordController, icon: LucideIcons.key), // Removed
              // const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField('관리자 호칭', _adminTitleController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('구성원 호칭', _userTitleController)),
                ],
              ),
            ] else ...[
              const Text('모임 찾기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Mock Group Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: _joinGroupLater ? Colors.grey[200]! : Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: _joinGroupLater ? Colors.grey[100] : null,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGroupId,
                    hint: Text('가입할 모임을 선택하세요', style: TextStyle(color: _joinGroupLater ? Colors.grey[400] : null)),
                    isExpanded: true,
                    // Use real Available Groups
                    items: _availableGroups.map((g) {
                      return DropdownMenuItem(
                        value: g.id,
                        child: Text(g.name),
                      );
                    }).toList(),
                    onChanged: _joinGroupLater ? null : (val) => setState(() => _selectedGroupId = val),
                    iconEnabledColor: _joinGroupLater ? Colors.grey[400] : null,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Join Later Checkbox
              GestureDetector(
                onTap: () {
                  setState(() {
                    _joinGroupLater = !_joinGroupLater;
                    if (_joinGroupLater) {
                      _selectedGroupId = null;
                      _joinPasswordController.clear();
                    }
                  });
                },
                child: Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _joinGroupLater, 
                        onChanged: (val) {
                          setState(() {
                            _joinGroupLater = val ?? false;
                            if (_joinGroupLater) {
                              _selectedGroupId = null;
                              _joinPasswordController.clear();
                            }
                          });
                        },
                        activeColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('모임 없이 시작하기 (나중에 가입 가능)'),
                  ],
                ),
              ),

              if (_selectedGroupId != null && !_joinGroupLater) ...[
                 Builder(
                   builder: (context) {
                     final selectedGroup = _availableGroups.firstWhere(
                       (g) => g.id == _selectedGroupId,
                       orElse: () => const Group(id: '', name: '', adminId: ''),
                     );
                     
                     if (selectedGroup.password != null && selectedGroup.password!.isNotEmpty) {
                       return Column(
                         children: [
                           const SizedBox(height: 12),
                           _buildTextField('모임 비밀번호', _joinPasswordController, icon: LucideIcons.key, obscureText: true),
                         ],
                       );
                     }
                     return const SizedBox.shrink();
                   },
                 ),
              ],
            ],

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: AppTheme.primary.withOpacity(0.6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _isAdmin ? '모임 생성하고 시작하기' : '가입하기',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRoleTab(String label, bool isAdminTab) {
    final isSelected = _isAdmin == isAdminTab;
    return GestureDetector(
      onTap: () => setState(() => _isAdmin = isAdminTab),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {IconData? icon, bool obscureText = false}) {
    final isEmail = label == '이메일';
    
    return TextField(
      controller: controller,
      obscureText: obscureText,
      // Disable autocorrect and suggestions globally, enable only for email if needed (usually email also doesn't need autocorrect but suggestions/autofill are good)
      autocorrect: false,
      enableSuggestions: isEmail, 
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      autofillHints: isEmail ? const [AutofillHints.email] : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey[400]) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
