import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../models/qt_log.dart';
import '../models/daily_word.dart';
import '../providers/app_provider.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';

enum QTMode { calendar, write, detail }

class QTScreen extends StatefulWidget {
  const QTScreen({super.key});

  @override
  State<QTScreen> createState() => _QTScreenState();
}

class _QTScreenState extends State<QTScreen> {
  QTMode _mode = QTMode.calendar;
  QTLog? _selectedLog;

  // Write Form State
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _applicationController = TextEditingController();
  final _prayerController = TextEditingController();

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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: currentDate, // Mock current date
      title: _titleController.text,
      content: _contentController.text,
      application: _applicationController.text,
      prayer: _prayerController.text,
      isPublic: true,
    );

    context.read<AppProvider>().addQTLog(newLog);
    
    // Reset and go back
    _titleController.clear();
    _contentController.clear();
    _applicationController.clear();
    _prayerController.clear();
    setState(() => _mode = QTMode.calendar);
  }

  @override
  Widget build(BuildContext context) {
    // Mode Switching
    if (_mode == QTMode.write) {
      return _buildWriteMode(context);
    } else if (_mode == QTMode.detail && _selectedLog != null) {
      return _buildDetailMode(context, _selectedLog!);
    }
    return _buildCalendarMode(context);
  }

  Widget _buildCalendarMode(BuildContext context) {
    final qtLogs = context.watch<AppProvider>().qtLogs;
    final word = todaysWord;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Banner
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF9333EA)], // indigo-600 to purple-600
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.sparkles, color: Color(0xFFC7D2FE), size: 14), // indigo-200
                    const SizedBox(width: 6),
                    Text(
                      "TODAY'S WORD",
                      style: TextStyle(
                        color: const Color(0xFFC7D2FE),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  word.scripture, // Truncate visually via maxLines if needed, simple here
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFE0E7FF), // indigo-100
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => setState(() => _mode = QTMode.write),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '오늘 묵상 쓰기',
                      style: TextStyle(
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
                const Text('12월의 기록', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                // Legend
                const Row(
                  children: [
                    _LegendItem(color: Colors.yellow, label: 'All'),
                    SizedBox(width: 12),
                    _LegendItem(color: Colors.green, label: 'Me'),
                    SizedBox(width: 12),
                    _LegendItem(color: Colors.blue, label: 'Group'),
                  ],
                ),
                const SizedBox(height: 16),

                // Calendar Grid (Simplified visual representation for now)
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
                      // Days Grid (Mock logic: just days 1-31)
                      Wrap(
                        spacing: 14, // tuned for roughly 7 cols
                        runSpacing: 16,
                        alignment: WrapAlignment.start,
                        children: List.generate(31, (index) {
                          final day = index + 1;
                          final dateStr = '2024-12-${day.toString().padLeft(2, '0')}';
                          final hasLog = qtLogs.any((l) => l.date == dateStr);
                          final isToday = dateStr == currentDate;

                          return SizedBox(
                            width: 30,
                            child: Column(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                    border: isToday ? Border.all(color: AppTheme.primary, width: 2) : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$day',
                                    style: TextStyle(
                                      color: isToday ? AppTheme.primary : Colors.grey[700],
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 14
                                    ),
                                  ),
                                ),
                                if (hasLog)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.green, // 'ME' status simplified
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Text('내 묵상 리스트', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // List
                ...qtLogs.map((log) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      _selectedLog = log;
                      setState(() => _mode = QTMode.detail);
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF), // indigo-50
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text('${log.date.split('-')[1]}월', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                Text(log.date.split('-')[2], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                              ],
                            ),
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

  Widget _buildWriteMode(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         leading: TextButton(
           onPressed: () => setState(() => _mode = QTMode.calendar),
           child: const Text('취소', style: TextStyle(color: Colors.grey)),
         ),
         leadingWidth: 70,
         title: const Text('오늘의 묵상', style: TextStyle(fontSize: 16)),
         centerTitle: true,
       ),
       body: SingleChildScrollView(
         padding: const EdgeInsets.all(24),
         child: Column(
           children: [
             // Word Section
             Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(todaysWord.reference, style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(todaysWord.scripture, style: const TextStyle(height: 1.5, fontSize: 14)),
                  ],
                ),
             ),
             const SizedBox(height: 24),
             
             // Title Input
             TextField(
               controller: _titleController,
               decoration: const InputDecoration(
                 hintText: '제목을 입력하세요',
                 border: InputBorder.none,
                 hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
               ),
               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
             ),
             const SizedBox(height: 24),

             _inputSection('묵상 (깨달은 점)', '말씀을 통해 무엇을 깨달으셨나요?', _contentController, LucideIcons.bookOpen, Colors.indigo),
             const SizedBox(height: 24),
             _inputSection('적용', '오늘 삶에서 어떻게 실천할까요?', _applicationController, LucideIcons.checkCircle, Colors.green),
             const SizedBox(height: 24),
             _inputSection('감사와 기도', '주님께 드릴 기도를 적어보세요.', _prayerController, LucideIcons.heart, Colors.purple),

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
                 child: const Text('저장하기'),
               ),
             ),
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
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration.collapsed(hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14)),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailMode(BuildContext context, QTLog log) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => setState(() => _mode = QTMode.calendar),
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
             _detailSection('묵상', log.content, LucideIcons.bookOpen, Colors.indigo),
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
