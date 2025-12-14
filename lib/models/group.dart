class Group {
  final String id;
  final String name;
  final String adminId; // The creator/admin of the group
  final String? password; // Null if no password
  final bool isAutoJoin; // true: auto-join, false: request approval
  final String adminTitle; // e.g., "목사님"
  final String userTitle; // e.g., "성도님"

  const Group({
    required this.id,
    required this.name,
    required this.adminId,
    this.password,
    this.isAutoJoin = false,
    this.adminTitle = '목사님',
    this.userTitle = '성도님',
  });

  // Aliases for compatibility
  String get adminName => adminTitle;
  String get userName => userTitle;

  factory Group.fromMap(Map<String, dynamic> data, String elementId) {
    return Group(
      id: elementId,
      name: data['name'] ?? '',
      adminId: data['adminId'] ?? '',
      password: data['password'],
      isAutoJoin: data['isAutoJoin'] ?? false,
      adminTitle: data['adminTitle'] ?? '목사님',
      userTitle: data['userTitle'] ?? '성도님',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'adminId': adminId,
      'password': password,
      'isAutoJoin': isAutoJoin,
      'adminTitle': adminTitle,
      'userTitle': userTitle,
    };
  }

  Group copyWith({
    String? name,
    String? adminId,
    String? password,
    bool? isAutoJoin,
    String? adminTitle,
    String? userTitle,
  }) {
    return Group(
      id: id,
      name: name ?? this.name,
      adminId: adminId ?? this.adminId,
      password: password ?? this.password,
      isAutoJoin: isAutoJoin ?? this.isAutoJoin,
      adminTitle: adminTitle ?? this.adminTitle,
      userTitle: userTitle ?? this.userTitle,
    );
  }
}
