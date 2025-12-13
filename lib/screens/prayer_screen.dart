import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/prayer_request.dart';
import '../providers/app_provider.dart';
import '../models/user.dart';
import '../data/mock_data.dart'; // for current user
import '../theme/app_theme.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> with SingleTickerProviderStateMixin {
  String _activeTab = 'INTERCESSORY'; // 'INTERCESSORY' | 'ONE_ON_ONE'

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<AppProvider>().prayerRequests;
    final filteredRequests = requests.where((r) => r.type == _activeTab).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const WritePrayerScreen(),
              fullscreenDialog: true,
            ),
          );
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   const Text('기도', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 16),
                   Container(
                     padding: const EdgeInsets.all(4),
                     decoration: BoxDecoration(
                       color: Colors.grey[200],
                       borderRadius: BorderRadius.circular(100),
                     ),
                     child: Row(
                       children: [
                         _buildTab('중보기도', 'INTERCESSORY'),
                         _buildTab('1:1 요청', 'ONE_ON_ONE'),
                       ],
                     ),
                   ),
                ],
              ),
            ),
            
            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                itemCount: filteredRequests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final req = filteredRequests[index];
                  return _PrayerCard(request: req);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, String tabKey) {
    final isActive = _activeTab == tabKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tabKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final PrayerRequest request;

  const _PrayerCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                backgroundImage: request.userAvatar.isNotEmpty 
                  ? NetworkImage(request.userAvatar) 
                  : null,
                child: request.userAvatar.isEmpty ? const Icon(LucideIcons.user, color: Colors.blue) : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
                    DateFormat('a hh:mm').format(request.createdAt),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            request.content,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              context.read<AppProvider>().toggleAmen(request.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: request.isAmenedByMe ? const Color(0xFFEEF2FF) : Colors.grey[50], // indigo-50
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.heart,
                    size: 14,
                    color: request.isAmenedByMe ? AppTheme.primary : Colors.grey[400],
                  ), // Filled heart simulation logic needed if icon data doesn't support fill property easily, using color mainly
                  const SizedBox(width: 4),
                  Text(
                    '아멘 ${request.amenCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: request.isAmenedByMe ? AppTheme.primary : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WritePrayerScreen extends StatefulWidget {
  const WritePrayerScreen({super.key});

  @override
  State<WritePrayerScreen> createState() => _WritePrayerScreenState();
}

class _WritePrayerScreenState extends State<WritePrayerScreen> {
  final _contentController = TextEditingController();
  bool _isRefining = false; // Mock state

  void _handleSubmit() {
    if (_contentController.text.isEmpty) return;

    final newRequest = PrayerRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser.id, // Current user
      userName: currentUser.name,
      userAvatar: currentUser.avatarUrl,
      content: _contentController.text,
      createdAt: DateTime.now(),
      amenCount: 0,
      isAmenedByMe: false,
      type: 'INTERCESSORY', // Default
    );

    context.read<AppProvider>().addPrayerRequest(newRequest);
    Navigator.pop(context);
  }

  void _handleRefine() async {
    if (_contentController.text.isEmpty) return;
    setState(() => _isRefining = true);
    
    // Mock AI delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock refinement
    setState(() {
      _contentController.text = "[AI 다듬음] ${_contentController.text}\n\n주님, 이 기도를 들어주소서. 아멘.";
      _isRefining = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(color: Colors.grey)),
        ),
        leadingWidth: 70,
        title: const Text('기도 제목 작성', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
           Expanded(
             child: Padding(
               padding: const EdgeInsets.all(20),
               child: Stack(
                 children: [
                   TextField(
                     controller: _contentController,
                     maxLines: null,
                     expands: true,
                     textAlignVertical: TextAlignVertical.top,
                     decoration: InputDecoration(
                       hintText: '나누고 싶은 기도 제목을 적어주세요...',
                       hintStyle: TextStyle(color: Colors.grey[400]),
                       filled: true,
                       fillColor: Colors.grey[50],
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(16),
                         borderSide: BorderSide.none,
                       ),
                       contentPadding: const EdgeInsets.all(20),
                     ),
                   ),
                   Positioned(
                     top: 12,
                     right: 12,
                     child: IconButton(
                       onPressed: _handleRefine,
                       style: IconButton.styleFrom(backgroundColor: Colors.white),
                       icon: _isRefining 
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Icon(LucideIcons.sparkles, size: 18, color: AppTheme.primary),
                     ),
                   ),
                 ],
               ),
             ),
           ),
           Padding(
             padding: const EdgeInsets.all(20),
             child: SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: _handleSubmit,
                 style: ElevatedButton.styleFrom(
                   backgroundColor: AppTheme.primary,
                   padding: const EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 ),
                 child: const Text('기도 요청하기'),
               ),
             ),
           ),
        ],
      ),
    );
  }
}
