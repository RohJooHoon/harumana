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
  // Tabs:
  // User: 'INTERCESSORY', 'ONE_ON_ONE'
  // Admin: 'ADMIN_NEW', 'ADMIN_COMPLETED' (Both are 1:1 type)
  String _activeTab = 'INTERCESSORY'; 

  @override
  void initState() {
    super.initState();
    // Defer admin check to build or use post-frame callback if needed, 
    // but here we can just default to INTERCESSORY and switch in build if needed, 
    // or better, handle it dynamically.
  }

  @override
  Widget build(BuildContext context) {
    // Check Admin Mode
    final isAdmin = context.watch<AppProvider>().isAdminMode;

    // Auto-switch tab if mismatched mode (e.g. freshly switched to Admin)
    if (isAdmin && (_activeTab == 'INTERCESSORY' || _activeTab == 'ONE_ON_ONE')) {
       // Using simpler logic: If in Admin mode, treat standard keys as invalid or auto-map?
       // Let's force update logic implicitly by rendering correct tabs, but we need state to match.
       // Better: Just maintain valid state.
       // If currently using User tabs, switch to Admin default.
       WidgetsBinding.instance.addPostFrameCallback((_) {
         setState(() => _activeTab = 'ADMIN_NEW');
       });
    } else if (!isAdmin && (_activeTab == 'ADMIN_NEW' || _activeTab == 'ADMIN_COMPLETED')) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         setState(() => _activeTab = 'INTERCESSORY');
       });
    }

    // Calculate Start of Week (Monday)
    final requests = context.watch<AppProvider>().prayerRequests;
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    
    final filteredRequests = requests.where((r) {
      if (isAdmin) {
        // Admin View: Only ONE_ON_ONE
        if (r.type != 'ONE_ON_ONE') return false;

        if (_activeTab == 'ADMIN_NEW') {
          return !r.isAmenedByMe;
        } else if (_activeTab == 'ADMIN_COMPLETED') {
          return r.isAmenedByMe;
        }
        return false; // Should not reach here if tab logic is sound
      } else {
        // User View
        if (r.type != _activeTab) return false;
        
        if (r.type == 'INTERCESSORY') {
           return r.createdAt.isAfter(startOfWeek);
        } else {
           return r.userId == currentUser.id;
        }
      }
    }).toList();

    // Sorting
    filteredRequests.sort((a, b) {
       // Admin New/Completed are typically chronological based on creation?
       // Newest first.
       return b.createdAt.compareTo(a.createdAt);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isAdmin ? AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.menu, color: Colors.black),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const Text('기도 관리', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ) : null,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   if (!isAdmin) ...[
                     const Text('기도', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 16),
                   ],
                   Container(
                     padding: const EdgeInsets.all(4),
                     decoration: BoxDecoration(
                       color: Colors.grey[200],
                       borderRadius: BorderRadius.circular(100),
                     ),
                     child: Row(
                       children: isAdmin 
                        ? [
                           _buildTab('신규 기도 요청', 'ADMIN_NEW'),
                           _buildTab('완료된 기도', 'ADMIN_COMPLETED'),
                          ]
                        : [
                           _buildTab('이번주 중보기도', 'INTERCESSORY'),
                           _buildTab('1:1 기도요청', 'ONE_ON_ONE'),
                          ],
                     ),
                   ),
                ],
              ),
            ),
            
            // List
            Expanded(
              child: filteredRequests.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.clipboardList, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        '아직 등록된 기도제목이 없습니다',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: filteredRequests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final req = filteredRequests[index];
                  return _PrayerCard(request: req);
                },
              ),
            ),

            // Bottom Action Button (Hidden for Admin)
            if (!isAdmin)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_activeTab == 'INTERCESSORY') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const WriteIntercessoryPrayerScreen()),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const WriteOneOnOnePrayerScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _activeTab == 'INTERCESSORY' ? '중보기도 요청하기' : '1:1 기도 요청하기',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
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

class _PrayerCard extends StatefulWidget {
  final PrayerRequest request;

  const _PrayerCard({required this.request});

  @override
  State<_PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<_PrayerCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Access provider for admin check
    final isAdmin = context.watch<AppProvider>().isAdminMode;

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
                backgroundImage: widget.request.userAvatar.isNotEmpty 
                  ? NetworkImage(widget.request.userAvatar) 
                  : null,
                child: widget.request.userAvatar.isEmpty ? const Icon(LucideIcons.user, color: Colors.blue) : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.request.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
                    DateFormat('MM.dd a hh:mm').format(widget.request.createdAt),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              widget.request.content,
              maxLines: _isExpanded ? null : 3,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 16),
          
          // Conditions to show Amen Button:
          // 1. Intercessory: Always show
          // 2. 1:1: Show if I am Admin OR if it has been amened (by admin)
          if (widget.request.type == 'INTERCESSORY' || (widget.request.type == 'ONE_ON_ONE' && (widget.request.amenCount > 0 || isAdmin)))
          GestureDetector(
            // Enable interaction if Intercessory OR (1:1 and Admin)
            onTap: (widget.request.type == 'INTERCESSORY' || (widget.request.type == 'ONE_ON_ONE' && isAdmin))
              ? () {
                  context.read<AppProvider>().toggleAmen(widget.request.id);
                }
              : null, 
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                // Color Logic:
                // 1. One-on-One that IS amened (count > 0): Special Point Color (Pastor Checked)
                // 2. My Amen (Intercessory): Primary Color
                // 3. Default: Grey
                color: (widget.request.type == 'ONE_ON_ONE' && widget.request.amenCount > 0)
                  ? AppTheme.point[200]!
                  : (widget.request.isAmenedByMe ? AppTheme.primary[200]! : Colors.grey[50]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Icon(
                    LucideIcons.heart,
                    size: 14,
                    color: (widget.request.type == 'ONE_ON_ONE' && widget.request.amenCount > 0)
                      ? Colors.white
                      : (widget.request.isAmenedByMe ? AppTheme.primary : Colors.grey[400]),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.request.type == 'ONE_ON_ONE' ? '아멘' : '아멘 ${widget.request.amenCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: (widget.request.type == 'ONE_ON_ONE' && widget.request.amenCount > 0)
                        ? Colors.white
                        : (widget.request.isAmenedByMe ? AppTheme.primary : Colors.grey[400]),
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

class WriteIntercessoryPrayerScreen extends StatefulWidget {
  const WriteIntercessoryPrayerScreen({super.key});

  @override
  State<WriteIntercessoryPrayerScreen> createState() => _WriteIntercessoryPrayerScreenState();
}

class _WriteIntercessoryPrayerScreenState extends State<WriteIntercessoryPrayerScreen> {
  final _contentController = TextEditingController();
  bool _isRefining = false;

  Future<void> _handleSubmit() async {
    if (_contentController.text.isEmpty) return;

    final newRequest = PrayerRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser.id,
      userName: currentUser.name,
      userAvatar: currentUser.avatarUrl,
      content: _contentController.text,
      createdAt: DateTime.now(),
      amenCount: 0,
      isAmenedByMe: false,
      type: 'INTERCESSORY',
    );

    try {
      await context.read<AppProvider>().addPrayerRequest(newRequest);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('중보기도 요청', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
                     autocorrect: false,
                     enableSuggestions: false,
                     maxLines: null,
                     expands: true,
                     textAlignVertical: TextAlignVertical.top,
                     decoration: InputDecoration(
                       hintText: '함께 기도하고 싶은 중보기도를 적어주세요',
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
                 child: const Text('중보기도 요청하기'),
               ),
             ),
           ),
        ],
      ),
    );
  }
}

class WriteOneOnOnePrayerScreen extends StatefulWidget {
  const WriteOneOnOnePrayerScreen({super.key});

  @override
  State<WriteOneOnOnePrayerScreen> createState() => _WriteOneOnOnePrayerScreenState();
}

class _WriteOneOnOnePrayerScreenState extends State<WriteOneOnOnePrayerScreen> {
  final _contentController = TextEditingController();
  bool _isRefining = false;

  Future<void> _handleSubmit() async {
    if (_contentController.text.isEmpty) return;

    final newRequest = PrayerRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser.id,
      userName: currentUser.name,
      userAvatar: currentUser.avatarUrl,
      content: _contentController.text,
      createdAt: DateTime.now(),
      amenCount: 0,
      isAmenedByMe: false,
      type: 'ONE_ON_ONE',
    );

    try {
      await context.read<AppProvider>().addPrayerRequest(newRequest);
      if (mounted) Navigator.pop(context);
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get dynamic admin title
    final provider = context.watch<AppProvider>();
    final group = provider.currentGroup;
    final adminTitle = group?.adminTitle ?? '목사님';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('$adminTitle께 1:1 기도 요청', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
                     autocorrect: false,
                     enableSuggestions: false,
                     maxLines: null,
                     expands: true,
                     textAlignVertical: TextAlignVertical.top,
                     decoration: InputDecoration(
                       hintText: '$adminTitle께 요청드릴 개인 기도를 적어주세요',
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
                 child: const Text('1:1 기도 요청하기'),
               ),
             ),
           ),
        ],
      ),
    );
  }
}
