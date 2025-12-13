class QTLog {
  final String id;
  final String date; // Keeping as String YYYY-MM-DD for simplicity mostly
  final String title;
  final String content;
  final String application;
  final String prayer;
  final bool isPublic;

  QTLog({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    required this.application,
    required this.prayer,
    required this.isPublic,
  });
}
