enum UserRole {
  superAdmin,
  admin,
  user;

  String get label {
    switch (this) {
      case UserRole.superAdmin: return '슈퍼관리자';
      case UserRole.admin: return '관리자';
      case UserRole.user: return '사용자';
    }
  }

  // Convert to Firestore 'auth' string
  String get toAuthString {
    switch (this) {
      case UserRole.superAdmin: return 'SUPER';
      case UserRole.admin: return 'ADMIN';
      case UserRole.user: return 'USER';
    }
  }

  // Create from Firestore 'auth' string
  static UserRole fromAuthString(String? auth) {
    if (auth == 'SUPER') return UserRole.superAdmin;
    if (auth == 'ADMIN') return UserRole.admin;
    return UserRole.user;
  }
}

class User {
  final String id;
  final String email;
  final String name;      // Firestore: displayName
  final String? photoUrl; // Firestore: photoURL
  final UserRole role;    // Firestore: auth
  final String? groupId;
  final String? groupName;
  final String? adminName; // 호칭 (예: 목사님)
  final String? userName;  // 호칭 (예: 성도님)
  final String? deviceId;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    String? photoUrl,
    String? avatarUrl, // for backward compatibility
    this.role = UserRole.user,
    this.groupId,
    this.groupName,
    this.adminName,
    this.userName,
    this.deviceId,
    this.createdAt,
  }) : photoUrl = photoUrl ?? avatarUrl; // initialize photoUrl with avatarUrl if photoUrl is null

  factory User.fromMap(Map<String, dynamic> data, String elementId) {
    // Handle Timestamp or String for createdAt
    DateTime? created;
    if (data['createdAt'] != null) {
      try {
        if (data['createdAt'].toString().contains('Timestamp')) {
          created = data['createdAt'].toDate();
        } else if (data['createdAt'] is String) {
          created = DateTime.parse(data['createdAt']);
        }
      } catch (_) {}
    }

    return User(
      id: elementId,
      email: data['email'] ?? '',
      name: data['displayName'] ?? '', // Mapped from displayName
      photoUrl: data['photoURL'] ?? data['avatarUrl'], // Mapped from photoURL with fallback
      role: UserRole.fromAuthString(data['auth']), // Mapped from auth
      groupId: data['groupId'],
      groupName: data['groupName'],
      adminName: data['adminName'],
      userName: data['userName'],
      deviceId: data['deviceId'],
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': name,     // Mapped to displayName
      'photoURL': photoUrl,    // Mapped to photoURL
      'auth': role.toAuthString, // Mapped to auth
      'groupId': groupId,
      'groupName': groupName,
      'adminName': adminName,
      'userName': userName,
      'deviceId': deviceId,
      'createdAt': createdAt ?? DateTime.now(), // Usually set by ServerTimestamp
    };
  }

  // Helper properties
  bool get isSuperAdmin => role == UserRole.superAdmin;
  bool get isAdmin => role == UserRole.admin;
  String get avatarUrl => photoUrl ?? ''; // Backward compatibility
}
