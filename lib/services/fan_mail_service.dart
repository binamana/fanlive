class FanMailService {
  const FanMailService._();

  static List<String> generateMessages({
    required String summary,
    required String earnedTitle,
    required Map<String, String> fanProfiles,
    String? sessionMemory,
    String? conversationDigest,
  }) {
    final memoryText = [
      summary,
      earnedTitle,
      sessionMemory,
      conversationDigest,
    ].whereType<String>().join(' ');
    final haruProfile = fanProfiles['하루'] ?? '다정한 오래된 팬';
    final byeolbamProfile = fanProfiles['별밤'] ?? '현실적인 조언 팬';
    final mintProfile = fanProfiles['민트'] ?? '장난 많은 리액션 팬';

    if (_hasClassConcern(memoryText)) {
      return [
        '하루 ($haruProfile): 오늘 수업 얘기 들으면서 마음이 좀 쓰였어요. 내일은 조금 덜 혼자 버티면 좋겠어요.',
        '별밤 ($byeolbamProfile): 학생들이 조용했던 게 꼭 실패는 아니지만, 다음엔 반응 방식을 쉽게 만드는 게 좋겠어요.',
        '민트 ($mintProfile): 내일 수업 리액션 담당은 우리가 예약함ㅋㅋ',
      ];
    }

    if (_hasMusicWork(memoryText) || earnedTitle == '작업 토크 장인') {
      return [
        '하루 ($haruProfile): 작업 얘기할 때 진심이 느껴졌어요.',
        '별밤 ($byeolbamProfile): 아이디어가 너무 넓어질 때는 핵심 키워드 하나로 묶어보는 게 좋아요.',
        '민트 ($mintProfile): 앨범 컨셉 떡밥 오늘 맛있었다ㅋㅋ',
      ];
    }

    if (_hasThanks(memoryText) || earnedTitle == '팬서비스 요정') {
      return [
        '하루 ($haruProfile): 오늘 고맙다고 해준 거 진짜 감동이었어요.',
        '별밤 ($byeolbamProfile): 우리가 더 고마워요. 오래 봐요.',
        '민트 ($mintProfile): 팬서비스 미쳤다... 오늘 못 잊음 😆',
      ];
    }

    if (summary.contains('감정') || earnedTitle == '감성 방송러') {
      return [
        '하루 ($haruProfile): 오늘은 조금 걱정됐어요. 그래도 와줘서 고마워요 💖',
        '별밤 ($byeolbamProfile): 무리하지 말고 쉬는 시간도 꼭 챙겨요.',
        '민트 ($mintProfile): 일단 하트 잔뜩 보내고 갈게요 💖💖💖',
      ];
    }

    return [
      '하루 ($haruProfile): 오늘 방송 와줘서 고마워요 💖',
      '별밤 ($byeolbamProfile): 다음 방송도 기다릴게요!',
      '민트 ($mintProfile): 오늘 이야기 재밌었어요 😆',
    ];
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

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }
}
