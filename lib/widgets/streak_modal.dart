import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class StreakModal extends StatelessWidget {
  final int streak;

  const StreakModal({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.x, size: 20, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(LucideIcons.flame, size: 40, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '$streak일 연속 묵상 중!',
              style: AppTheme.lightTheme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '꾸준한 묵상이 영적 성장의 밑거름이 됩니다.\n오늘도 말씀과 함께 승리하세요! 🔥',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('계속하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
