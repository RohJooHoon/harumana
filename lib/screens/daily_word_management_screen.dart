import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import 'daily_word_editor_screen.dart';

class DailyWordManagementScreen extends StatelessWidget {
  const DailyWordManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock List of recent words
    final words = [todaysWord];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('말씀 관리', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: AppTheme.primary),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DailyWordEditorScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: words.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final word = words[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              title: Text(
                word.reference,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                word.scripture,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(LucideIcons.chevronRight, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DailyWordEditorScreen()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
