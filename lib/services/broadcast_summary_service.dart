class BroadcastSummaryResult {
  final String bestMoment;
  final String summary;
  final String earnedTitle;

  const BroadcastSummaryResult({
    required this.bestMoment,
    required this.summary,
    required this.earnedTitle,
  });
}

class BroadcastSummaryService {
  const BroadcastSummaryService._();

  static BroadcastSummaryResult calculate({
    required List<String> userSpeechHistory,
    required int hearts,
    required int viewers,
  }) {
    String bestMoment = '첫 인사를 나눈 순간';
    String summary = '팬들과 편안하게 소통한 라방이었어요.';
    String earnedTitle = '첫 데뷔';

    for (final speech in userSpeechHistory) {
      if (speech.contains('힘들') ||
          speech.contains('피곤') ||
          speech.contains('속상')) {
        bestMoment = speech;
        summary = '오늘은 솔직한 감정 이야기를 나누며 팬들과 따뜻한 시간을 보냈어요.';
        earnedTitle = '감성 방송러';
        break;
      }

      if (speech.contains('노래') ||
          speech.contains('곡') ||
          speech.contains('작업') ||
          speech.contains('앨범')) {
        bestMoment = speech;
        summary = '오늘은 음악과 작업 이야기를 중심으로 팬들과 소통했어요.';
        earnedTitle = '작업 토크 장인';
      }

      if (speech.contains('고마워') || speech.contains('감사')) {
        bestMoment = speech;
        summary = '팬들에게 고마운 마음을 전하며 분위기가 따뜻해졌어요.';
        earnedTitle = '팬서비스 요정';
      }
    }

    if (userSpeechHistory.isNotEmpty && bestMoment == '첫 인사를 나눈 순간') {
      bestMoment = userSpeechHistory.last;
    }

    if (hearts >= 100) {
      earnedTitle = '하트 폭격';
    }

    if (viewers >= 300) {
      earnedTitle = '라이징 스타';
    }

    return BroadcastSummaryResult(
      bestMoment: bestMoment,
      summary: summary,
      earnedTitle: earnedTitle,
    );
  }
}
