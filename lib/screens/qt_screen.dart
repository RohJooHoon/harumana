import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/qt_log.dart';
import '../models/daily_word.dart';
import '../providers/app_provider.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';

class QTScreen extends StatefulWidget {
  const QTScreen({super.key});

  @override
  State<QTScreen> createState() => _QTScreenState();
}

class _QTScreenState extends State<QTScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return _buildCalendarMode(context);
  }

  Widget _buildCalendarMode(BuildContext context) {
    final qtLogs = context.watch<AppProvider>().qtLogs;
    final word = todaysWord;

    // Calendar Calculations
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 for Sunday, 1 for Monday...

    // Date Formatters
    final monthFormat = DateFormat('yyyy년 M월');
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Filter and Sort Logs for Selected Date
    final selectedDateStr = dateFormat.format(_selectedDate);
    final logsForDate = qtLogs.where((log) => log.date == selectedDateStr).toList()
      ..sort((a, b) => b.id.compareTo(a.id)); // Newest first

    // Check if I wrote today
    final todayLogIndex = qtLogs.indexWhere((l) => l.date == currentDate && l.userId == currentUser.id);
    final todayLog = todayLogIndex != -1 ? qtLogs[todayLogIndex] : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Banner (Unchanged logic, just simplified code structure if needed, keeping mostly same)
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.sparkles, color: Colors.white54, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "TODAY'S WORD",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  word.scripture,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QTWriteScreen(existingLog: todayLog)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      todayLog != null ? '오늘의 묵상 수정' : '오늘의 묵상 쓰기',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.chevronLeft),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                        });
                      },
                    ),
                    Text(
                      monthFormat.format(_focusedMonth),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.chevronRight),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(color: Colors.yellow[400]!, label: 'All'),
                    const SizedBox(width: 12),
                    _LegendItem(color: Colors.green[400]!, label: 'Me'),
                    const SizedBox(width: 12),
                    _LegendItem(color: Colors.blue[400]!, label: 'Group'),
                  ],
                ),
                const SizedBox(height: 16),

                // Calendar Grid
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Weekday Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => 
                          SizedBox(
                            width: 30,
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: day == 'S' ? Colors.red[300] : (day == 'S' ? Colors.blue[300] : Colors.grey[400]),
                              ),
                            ),
                          )
                        ).toList(),
                      ),
                      const SizedBox(height: 16),
                      // Days Grid
                      Wrap(
                        spacing: 14,
                        runSpacing: 16,
                        alignment: WrapAlignment.start,
                        children: [
                          ...List.generate(firstWeekday, (_) => const SizedBox(width: 30)), // Empty slots
                          ...List.generate(daysInMonth, (index) {
                            final day = index + 1;
                            final currentDayDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                            final dateStr = dateFormat.format(currentDayDate);
                            final dayLogs = qtLogs.where((l) => l.date == dateStr).toList();
                            final hasMe = dayLogs.any((l) => l.userId == currentUser.id);
                            final hasOthers = dayLogs.any((l) => l.userId != currentUser.id);
                            
                            Color? dotColor;
                            if (hasMe && hasOthers) {
                              dotColor = Colors.yellow[400];
                            } else if (hasMe) {
                              dotColor = Colors.green[400];
                            } else if (hasOthers) {
                              dotColor = Colors.blue[400];
                            }
                            
                            final isSelected = DateUtils.isSameDay(currentDayDate, _selectedDate);
                            final isToday = DateUtils.isSameDay(currentDayDate, DateTime.now());

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDate = currentDayDate;
                                });
                              },
                              child: SizedBox(
                                width: 30,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? AppTheme.primary : Colors.transparent,
                                        border: isToday && !isSelected ? Border.all(color: AppTheme.primary, width: 2) : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '$day',
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : (isToday ? AppTheme.primary : Colors.grey[700]),
                                          fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.normal,
                                          fontSize: 14
                                        ),
                                      ),
                                    ),
                                    if (dotColor != null)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: dotColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Text(
                  '${dateFormat.format(_selectedDate)} 묵상',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Selected Day Logs List
                if (logsForDate.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      '작성된 묵상이 없습니다.',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  )
                else
                  ...logsForDate.map((log) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QTDetailScreen(log: log)),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(LucideIcons.fileText, color: AppTheme.primary, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    log.content,
                                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QTWriteScreen extends StatefulWidget {
  final QTLog? existingLog;
  const QTWriteScreen({super.key, this.existingLog});

  @override
  State<QTWriteScreen> createState() => _QTWriteScreenState();
}

class _QTWriteScreenState extends State<QTWriteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _applicationController = TextEditingController();
  final _prayerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingLog != null) {
      _titleController.text = widget.existingLog!.title;
      _contentController.text = widget.existingLog!.content;
      _applicationController.text = widget.existingLog!.application;
      _prayerController.text = widget.existingLog!.prayer;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _applicationController.dispose();
    _prayerController.dispose();
    super.dispose();
  }

  void _handleSave(BuildContext context) {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 묵상 내용을 입력해주세요.')),
      );
      return;
    }

    final newLog = QTLog(
      id: widget.existingLog?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser.id, // Add this
      date: currentDate,
      title: _titleController.text,
      content: _contentController.text,
      application: _applicationController.text,
      prayer: _prayerController.text,
      isPublic: true,
    );

    if (widget.existingLog != null) {
      context.read<AppProvider>().updateQTLog(newLog);
    } else {
      context.read<AppProvider>().addQTLog(newLog);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.grey[50],
       appBar: AppBar(
          leading: IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
         backgroundColor: Colors.white,
         elevation: 0,
         title: Text(widget.existingLog != null ? '오늘의 묵상 수정' : '오늘의 묵상 쓰기', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
         centerTitle: true,
       ),
       body: SingleChildScrollView(
         padding: const EdgeInsets.all(24),
         child: Column(
           children: [
             // Today's Word Card
             Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.bookOpen, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(todaysWord.reference, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todaysWord.scripture,
                            style: const TextStyle(height: 1.6, fontSize: 15, color: Colors.black87),
                          ),
                          const SizedBox(height: 20),
                          // Pastor's Note
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(LucideIcons.messageCircle, size: 14, color: AppTheme.primary),
                                    SizedBox(width: 8),
                                    Text('묵상 포인트', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  todaysWord.pastorNote,
                                  style: TextStyle(fontSize: 13, height: 1.5, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
             ),
             const SizedBox(height: 24),
             
             // Input Form
             Container(
               padding: const EdgeInsets.all(24),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(20),
                 boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
                 ],
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // Title Input
                   TextField(
                     controller: _titleController,
                     autocorrect: false,
                     enableSuggestions: false,
                     decoration: const InputDecoration(
                       hintText: '제목을 입력하세요',
                       border: InputBorder.none,
                       hintStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                       contentPadding: EdgeInsets.zero,
                     ),
                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                   const Divider(height: 32),

                   _inputSection('묵상 (깨달은 점)', '말씀을 통해 무엇을 깨달으셨나요?', _contentController, LucideIcons.lightbulb, Colors.amber),
                   const SizedBox(height: 24),
                   _inputSection('적용', '오늘 삶에서 어떻게 실천할까요?', _applicationController, LucideIcons.checkCircle, Colors.green),
                   const SizedBox(height: 24),
                   _inputSection('감사와 기도', '주님께 드릴 기도를 적어보세요.', _prayerController, LucideIcons.heart, Colors.redAccent),
                 ],
               ),
             ),

             const SizedBox(height: 32),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: () => _handleSave(context),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: AppTheme.primary,
                   padding: const EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 ),
                 child: const Text('저장하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               ),
             ),
             const SizedBox(height: 32),
           ],
         ),
       ),
     );
  }

  Widget _inputSection(String label, String hint, TextEditingController controller, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            autocorrect: false,
            enableSuggestions: false,
            maxLines: 4,
            minLines: 3,
            decoration: InputDecoration.collapsed(hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14)),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class QTDetailScreen extends StatelessWidget {
  final QTLog log;

  const QTDetailScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${log.date} 묵상'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(log.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
             const SizedBox(height: 32),
             _detailSection('묵상', log.content, LucideIcons.bookOpen, AppTheme.primary),
             const SizedBox(height: 24),
             _detailSection('적용', log.application, LucideIcons.checkCircle, Colors.green),
             const SizedBox(height: 24),
             _detailSection('기도', log.prayer, LucideIcons.heart, Colors.purple),
           ],
        ),
      ),
    );
  }

  Widget _detailSection(String label, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
           children: [
             Icon(icon, size: 16, color: color),
             const SizedBox(width: 8),
             Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
           ],
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87)),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
