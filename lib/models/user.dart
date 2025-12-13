class User {
  final String id;
  final String email;
  final String name;
  final String avatarUrl;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.avatarUrl,
  });

  factory User.fromMap(Map<String, dynamic> data, String elementId) {
    return User(
      id: elementId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
    };
  }
}
