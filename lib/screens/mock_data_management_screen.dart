import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MockDataManagementScreen extends StatelessWidget {
  const MockDataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('목업 데이터 관리', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                   const Icon(LucideIcons.database, size: 48, color: Colors.orange),
                   const SizedBox(height: 16),
                   const Text(
                     '데이터 초기화',
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     '모든 기도제목, 묵상 기록을 초기화하고\n기본 목업 데이터로 되돌립니다.',
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.grey[600]),
                   ),
                   const SizedBox(height: 24),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('데이터가 초기화되었습니다. (테스트)')),
                         );
                       },
                       style: ElevatedButton.styleFrom(
                         backgroundColor: Colors.orange,
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       ),
                       child: const Text('초기화 실행'),
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
