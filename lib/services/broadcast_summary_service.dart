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

    String bestMoment = '처음 방에서 말을 건 순간';
    String summary = '작은 방에서 룸펫과 조용히 하루를 나눈 생활 기록이에요.';
    String earnedTitle = '이상한 동거의 시작';

    if (_hasClassConcern(memoryText)) {
      bestMoment = _findBestMoment(userSpeechHistory, [
        '수업',
        '학생',
        '강의',
        '조용',
        '걱정',
        '힘들',
        '멘탈',
      ]);
      summary = _hasPositiveTurn(memoryText)
          ? '수업에서 학생들의 조용한 반응 때문에 지친 마음을 룸펫과 나누고, 방 안의 대화 속에서 조금 마음이 나아진 하루였어요.'
          : '수업에서 학생들의 조용한 반응 때문에 지친 마음을 룸펫에게 털어놓고 같이 버틴 하루였어요.';
      earnedTitle = '새벽을 같이 넘긴 방';
    } else if (_hasMusicWork(memoryText)) {
      bestMoment = _findBestMoment(userSpeechHistory, [
        '노래',
        '곡',
        '작업',
        '앨범',
        '컴백',
        '발매',
        '컨셉',
      ]);
      summary = '작업과 앨범 고민을 방 안의 룸펫과 나누며 생각을 정리한 생활 기록이에요.';
      earnedTitle = '조용한 작업실의 주인';
    } else if (_hasThanks(memoryText)) {
      bestMoment = _findBestMoment(userSpeechHistory, [
        '고마워',
        '감사',
        '동거',
        '친구',
      ]);
      summary = _hasPositiveTurn(memoryText)
          ? '룸펫에게 고마운 마음을 전하고, 함께 이야기하며 조금 마음이 나아진 기억이 남았어요.'
          : '룸펫에게 고마운 마음을 전하며 방 분위기가 조금 따뜻해졌어요.';
      earnedTitle = '오늘도 돌아온 사람';
    } else if (_hasEmotionalTalk(memoryText)) {
      bestMoment = _findBestMoment(userSpeechHistory, [
        '힘들',
        '피곤',
        '속상',
        '외롭',
        '고민',
        '걱정',
      ]);
      summary = '오늘은 솔직한 감정을 꺼내놓고 룸펫과 방 안에서 천천히 견딘 시간이었어요.';
      earnedTitle = '하루가 기다린 사람';
    }

    if (userSpeechHistory.isNotEmpty && bestMoment == '처음 방에서 말을 건 순간') {
      bestMoment = userSpeechHistory.last;
    }

    if (hearts >= 100) {
      earnedTitle = '민트의 공범';
    }

    if (viewers >= 300) {
      earnedTitle = '픽셀 룸의 주인';
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

    return userSpeechHistory.isEmpty
        ? '처음 방에서 말을 건 순간'
        : userSpeechHistory.last;
  }

  static bool _hasClassConcern(String text) {
    return _containsAny(text, ['수업', '학생', '강의', '수업/학생 반응']) &&
        _containsAny(text, ['조용', '반응', '걱정', '힘들', '위축', '멘탈']);
  }

  static bool _hasMusicWork(String text) {
    return _containsAny(text, ['노래', '곡', '작업', '앨범', '컴백', '발매', '컨셉']);
  }

  static bool _hasThanks(String text) {
    return _containsAny(text, ['고마워', '감사', '팬들과 대화', '팬들 덕분', '룸펫', '친구']);
  }

  static bool _hasEmotionalTalk(String text) {
    return _containsAny(text, ['힘들', '피곤', '속상', '외롭', '고민', '걱정']);
  }

  static bool _hasPositiveTurn(String text) {
    return _containsAny(text, ['조금 나아짐', '낫', '나아', '팬들과 대화', '룸펫과 대화']);
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }
}
