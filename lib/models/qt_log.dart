class QTLog {
  final String id;
  final String userId; // Added to distinguish author
  final String date; // Keeping as String YYYY-MM-DD for simplicity mostly
  final String title;
  final String content;
  final String application;
  final String prayer;
  final bool isPublic;

  QTLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.title,
    required this.content,
    required this.application,
    required this.prayer,
    required this.isPublic,
  });

  factory QTLog.fromMap(Map<String, dynamic> data, String id) {
    return QTLog(
      id: id,
      userId: data['userId'] ?? '',
      date: data['date'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      application: data['application'] ?? '',
      prayer: data['prayer'] ?? '',
      isPublic: data['isPublic'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'title': title,
      'content': content,
      'application': application,
      'prayer': prayer,
      'isPublic': isPublic,
    };
  }
}
