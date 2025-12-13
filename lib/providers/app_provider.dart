import 'package:flutter/material.dart';
import '../models/qt_log.dart';
import '../models/prayer_request.dart';
import '../data/mock_data.dart';

enum ActiveTab { home, qt, prayer }

class AppProvider with ChangeNotifier {
  ActiveTab _activeTab = ActiveTab.home;

  ActiveTab get activeTab => _activeTab;

  void setActiveTab(ActiveTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  final int _streak = 7;
  int get streak => _streak;

  // Data State
  final List<QTLog> _qtLogs = List.from(initialQtLogs);
  List<QTLog> get qtLogs => _qtLogs;

  final List<PrayerRequest> _prayerRequests = List.from(initialPrayerRequests);
  List<PrayerRequest> get prayerRequests => _prayerRequests;

  // QT Logic
  void addQTLog(QTLog log) {
    _qtLogs.insert(0, log);
    notifyListeners();
  }

  // Prayer Logic
  void addPrayerRequest(PrayerRequest request) {
    _prayerRequests.insert(0, request);
    notifyListeners();
  }

  void toggleAmen(String id) {
    final index = _prayerRequests.indexWhere((req) => req.id == id);
    if (index != -1) {
      final req = _prayerRequests[index];
      final isAmened = !req.isAmenedByMe;
      final newCount = isAmened ? req.amenCount + 1 : req.amenCount - 1;

      // Create new object to trigger update if needed
      _prayerRequests[index] = PrayerRequest(
        id: req.id,
        userId: req.userId,
        userName: req.userName,
        userAvatar: req.userAvatar,
        content: req.content,
        createdAt: req.createdAt,
        amenCount: newCount,
        isAmenedByMe: isAmened,
        type: req.type,
      );
      notifyListeners();
    }
  }
}
