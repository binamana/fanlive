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
    String? sessionMemory,
    String? conversationDigest,
  }) {
    final memoryText = [
      sessionMemory,
      conversationDigest,
      ...userSpeechHistory,
    ].whereType<String>().join(' ');

    String bestMoment = '첫 인사를 나눈 순간';
    String summary = '팬들과 편안하게 소통한 라방이었어요.';
    String earnedTitle = '첫 데뷔';

    if (_hasClassConcern(memoryText)) {
      bestMoment = _findBestMoment(
        userSpeechHistory,
        ['수업', '학생', '강의', '조용', '걱정', '힘들', '멘탈'],
      );
      summary = _hasPositiveTurn(memoryText)
          ? '수업에서 학생들의 조용한 반응 때문에 지친 마음을 팬들과 나누고, 이야기하며 조금 마음이 나아진 라방이었어요.'
          : '수업에서 학생들의 조용한 반응 때문에 지친 마음을 팬들과 나누며 위로받은 라방이었어요.';
      earnedTitle = '팬들과 버틴 하루';
    } else if (_hasMusicWork(memoryText)) {
      bestMoment = _findBestMoment(
        userSpeechHistory,
        ['노래', '곡', '작업', '앨범', '컴백', '발매', '컨셉'],
      );
      summary = '작업과 앨범 고민을 팬들과 나누며 아이디어를 정리한 라방이었어요.';
      earnedTitle = '작업 토크 장인';
    } else if (_hasThanks(memoryText)) {
      bestMoment = _findBestMoment(userSpeechHistory, ['고마워', '감사', '팬']);
      summary = _hasPositiveTurn(memoryText)
          ? '팬들에게 고마운 마음을 전하고, 팬들과 이야기하며 조금 마음이 나아진 흐름이 남은 라방이었어요.'
          : '팬들에게 고마운 마음을 전하며 분위기가 따뜻해졌어요.';
      earnedTitle = '팬서비스 요정';
    } else if (_hasEmotionalTalk(memoryText)) {
      bestMoment = _findBestMoment(
        userSpeechHistory,
        ['힘들', '피곤', '속상', '외롭', '고민', '걱정'],
      );
      summary = '오늘은 솔직한 감정 이야기를 나누며 팬들과 따뜻한 시간을 보냈어요.';
      earnedTitle = '감성 방송러';
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

  static String _findBestMoment(
    List<String> userSpeechHistory,
    List<String> keywords,
  ) {
    for (final speech in userSpeechHistory.reversed) {
      if (keywords.any(speech.contains)) {
        return speech;
      }
    }

    return userSpeechHistory.isEmpty ? '첫 인사를 나눈 순간' : userSpeechHistory.last;
  }

  static bool _hasClassConcern(String text) {
    return _containsAny(text, ['수업', '학생', '강의', '수업/학생 반응']) &&
        _containsAny(text, ['조용', '반응', '걱정', '힘들', '위축', '멘탈']);
  }

  static bool _hasMusicWork(String text) {
    return _containsAny(text, ['노래', '곡', '작업', '앨범', '컴백', '발매', '컨셉']);
  }

  static bool _hasThanks(String text) {
    return _containsAny(text, ['고마워', '감사', '팬들과 대화', '팬들 덕분']);
  }

  static bool _hasEmotionalTalk(String text) {
    return _containsAny(text, ['힘들', '피곤', '속상', '외롭', '고민', '걱정']);
  }

  static bool _hasPositiveTurn(String text) {
    return _containsAny(text, ['조금 나아짐', '낫', '나아', '팬들과 대화']);
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }
}
