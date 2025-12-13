class DailyWord {
  final String date;
  final String reference;
  final String scripture;
  final String pastorNote;

  const DailyWord({
    required this.date,
    required this.reference,
    required this.scripture,
    required this.pastorNote,
  });

  factory DailyWord.fromMap(Map<String, dynamic> data) {
    return DailyWord(
      date: data['date'] ?? '',
      reference: data['reference'] ?? '',
      scripture: data['scripture'] ?? '',
      pastorNote: data['pastorNote'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'reference': reference,
      'scripture': scripture,
      'pastorNote': pastorNote,
    };
  }
}
