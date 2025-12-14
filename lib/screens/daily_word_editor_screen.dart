import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart'; // To get initial data

class DailyWordEditorScreen extends StatefulWidget {
  const DailyWordEditorScreen({super.key});

  @override
  State<DailyWordEditorScreen> createState() => _DailyWordEditorScreenState();
}

class _DailyWordEditorScreenState extends State<DailyWordEditorScreen> {
  late TextEditingController _referenceController;
  late TextEditingController _scriptureController;
  late TextEditingController _noteController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load current mock data
    _referenceController = TextEditingController(text: todaysWord.reference);
    _scriptureController = TextEditingController(text: todaysWord.scripture);
    _noteController = TextEditingController(text: todaysWord.pastorNote);
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _scriptureController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    // In real app, update Provider/Backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('오늘의 말씀이 저장되었습니다. (테스트용)')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('오늘의 말씀 작성', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('저장', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('날짜 선택'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_selectedDate.year}.${_selectedDate.month}.${_selectedDate.day}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(LucideIcons.calendar, size: 20, color: Colors.grey),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader('말씀 본문'),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: '말씀 장절 (예: 시편 23:1-3)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _scriptureController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: '말씀 내용',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('묵상 포인트 (목사님 말씀)'),
            TextField(
              controller: _noteController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: '오늘 성도들에게 전하고 싶은 묵상 포인트나 기도를 적어주세요.',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
