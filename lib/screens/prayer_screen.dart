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
    // Calculate Start of Week (Monday)
    final requests = context.watch<AppProvider>().prayerRequests;
    final now = DateTime.now();
    // Monday = 1, Sunday = 7. Subtract (weekday - 1) days to get Monday.
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    
    final filteredRequests = requests.where((r) {
      if (r.type != _activeTab) return false;
      // Filter for this week (only if Intercessory? User said "Intercessory is weekly", but let's apply to all for now or just Intercessory based on tab)
      // "Intercessory is for this week" - implying 1:1 might not be restricted? 
      // User query: "Intercessory... weekly reset". I will apply to Intercessory mainly, but usually feed logic applies to tab. 
      // Let's safe bet apply to Intercessory only if tab is Intercessory, or both. 
      // "Intercessory is this week...". 1:1 is usually private history.
      // I'll apply logic to Intercessory tab specifically or both if unspecified. 
      // "Intercessory is weekly reset".
      if (r.type == 'INTERCESSORY') {
        return r.createdAt.isAfter(startOfWeek);
      }
      return true; // Keep 1:1 as is? Or filter too? "Each prayer date..."
      // I'll filter Intercessory only based on request phrasing. But actually "This week's intercessory".
      // Let's filter only 'INTERCESSORY' types by date.
    }).toList();

    // Sorting: My posts first, then Chronological (Newest first)
    filteredRequests.sort((a, b) {
      final aIsMine = a.userId == currentUser.id;
      final bIsMine = b.userId == currentUser.id;

      if (aIsMine && !bIsMine) return -1;
      if (!aIsMine && bIsMine) return 1;
      
      // Secondary: Time order (Newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return Scaffold(
      backgroundColor: Colors.white,
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
                         _buildTab('이번주 중보기도', 'INTERCESSORY'), // Updated Label hint
                         _buildTab('1:1 기도요청', 'ONE_ON_ONE'),
                       ],
                     ),
                   ),
                ],
              ),
            ),
            
            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: filteredRequests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final req = filteredRequests[index];
                  return _PrayerCard(request: req);
                },
              ),
            ),

            // Bottom Action Button
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
          if (widget.request.type == 'INTERCESSORY' || (widget.request.type == 'ONE_ON_ONE' && widget.request.amenCount > 0))
          GestureDetector(
            onTap: widget.request.type == 'INTERCESSORY' 
              ? () {
                  context.read<AppProvider>().toggleAmen(widget.request.id);
                }
              : null, // Read-only for 1:1
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (widget.request.type == 'ONE_ON_ONE' && widget.request.amenCount > 0)
                  ? AppTheme.point[200] // Pastor Checked: Point Color
                  : (widget.request.isAmenedByMe ? AppTheme.primary[200] : Colors.grey[50]),
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

  void _handleSubmit() {
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

    context.read<AppProvider>().addPrayerRequest(newRequest);
    Navigator.pop(context);
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

  void _handleSubmit() {
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

    context.read<AppProvider>().addPrayerRequest(newRequest);
    Navigator.pop(context);
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
        title: const Text('1:1 기도 요청', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
                       hintText: '목사님 or 목회장님께 요청드릴 개인 기도를 적어주세요',
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
