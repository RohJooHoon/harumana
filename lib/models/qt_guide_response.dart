class QTGuideResponse {
  final String background;
  final List<String> questions;
  final String action;

  QTGuideResponse({
    required this.background,
    required this.questions,
    required this.action,
  });

  factory QTGuideResponse.fromJson(Map<String, dynamic> json) {
    return QTGuideResponse(
      background: json['background'] as String,
      questions: List<String>.from(json['questions'] as List),
      action: json['action'] as String,
    );
  }
}
