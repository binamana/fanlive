class BroadcastRecord {
  final String themeTitle;
  final int viewers;
  final int hearts;
  final String bestMoment;
  final String summary;
  final String earnedTitle;
  final DateTime createdAt;

  BroadcastRecord({
    required this.themeTitle,
    required this.viewers,
    required this.hearts,
    required this.bestMoment,
    required this.summary,
    required this.earnedTitle,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'themeTitle': themeTitle,
      'viewers': viewers,
      'hearts': hearts,
      'bestMoment': bestMoment,
      'summary': summary,
      'earnedTitle': earnedTitle,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BroadcastRecord.fromJson(Map<String, dynamic> json) {
    return BroadcastRecord(
      themeTitle: json['themeTitle'] ?? '',
      viewers: json['viewers'] ?? 0,
      hearts: json['hearts'] ?? 0,
      bestMoment: json['bestMoment'] ?? '',
      summary: json['summary'] ?? '',
      earnedTitle: json['earnedTitle'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}