class PrayerRequest {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime createdAt;
  int amenCount;
  bool isAmenedByMe;
  final String type; // 'INTERCESSORY' | 'ONE_ON_ONE'

  PrayerRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.createdAt,
    required this.amenCount,
    required this.isAmenedByMe,
    required this.type,
  });
}
