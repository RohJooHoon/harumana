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
  bool isRead; // Critical for Admin 1:1 workflow (New/Read state)

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
    this.isRead = false,
  });

  factory PrayerRequest.fromMap(Map<String, dynamic> data, String id) {
    DateTime createdAt;
    final createdAtValue = data['createdAt'];
    if (createdAtValue == null) {
      createdAt = DateTime.now();
    } else if (createdAtValue is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtValue);
    } else if (createdAtValue.runtimeType.toString().contains('Timestamp')) {
      // Firestore Timestamp
      createdAt = (createdAtValue as dynamic).toDate();
    } else {
      createdAt = DateTime.tryParse(createdAtValue.toString()) ?? DateTime.now();
    }

    return PrayerRequest(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userAvatar: data['userAvatar'] ?? '',
      content: data['content'] ?? '',
      createdAt: createdAt,
      amenCount: data['amenCount'] ?? 0,
      isAmenedByMe: data['isAmenedByMe'] ?? false,
      type: data['type'] ?? 'INTERCESSORY',
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'amenCount': amenCount,
      'isAmenedByMe': isAmenedByMe,
      'type': type,
      'isRead': isRead,
    };
  }
}
