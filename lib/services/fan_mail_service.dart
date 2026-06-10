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
    final haruProfile = fanProfiles['하루'] ?? '기다림이 많은 다정한 룸펫';
    final byeolbamProfile = fanProfiles['별밤'] ?? '툴툴대는 츤데레 룸펫';
    final mintProfile = fanProfiles['민트'] ?? '말썽 많은 장난꾸러기 룸펫';

    if (_hasClassConcern(memoryText)) {
      return [
        '하루 ($haruProfile): 오늘 수업 얘기 들으면서 마음이 좀 쓰였어요. 내일은 조금 덜 혼자 버티면 좋겠어요.',
        '별밤 ($byeolbamProfile): 학생들이 조용했던 게 꼭 실패는 아니지만, 다음엔 반응 방식을 쉽게 만드는 게 좋겠어요.',
        '민트 ($mintProfile): 내일 수업 전 방 회의 열자ㅋㅋ 리액션 담당 내가 함',
      ];
    }

    if (_hasMusicWork(memoryText) || earnedTitle == '조용한 작업실의 주인') {
      return [
        '하루 ($haruProfile): 작업 얘기할 때 진심이 느껴졌어요.',
        '별밤 ($byeolbamProfile): 아이디어가 너무 넓어질 때는 핵심 키워드 하나로 묶어보는 게 좋아요.',
        '민트 ($mintProfile): 작업실 공기 오늘 좀 멋있었음ㅋㅋ 내가 어질러도 영감이라고 해줘요',
      ];
    }

    if (_hasThanks(memoryText) || earnedTitle == '오늘도 돌아온 사람') {
      return [
        '하루 ($haruProfile): 오늘 고맙다고 해준 거 진짜 오래 기억할 것 같아요.',
        '별밤 ($byeolbamProfile): 고맙다는 말은 접수. 대신 다음에도 무리하지 말고 돌아와요.',
        '민트 ($mintProfile): 감사 인사 받았으니 오늘 방 분위기 저장함ㅋㅋ',
      ];
    }

    if (summary.contains('감정') || earnedTitle == '하루가 기다린 사람') {
      return [
        '하루 ($haruProfile): 오늘은 조금 걱정됐어요. 그래도 방에 돌아와줘서 마음이 놓였어요.',
        '별밤 ($byeolbamProfile): 무리하지 말고 쉬는 시간도 꼭 챙겨요.',
        '민트 ($mintProfile): 오늘은 내가 소파 자리 양보함. 이건 큰 사건임ㅋㅋ',
      ];
    }

    return [
      '하루 ($haruProfile): 오늘 방에 와줘서 고마워요. 내일도 여기 있을게요.',
      '별밤 ($byeolbamProfile): 오늘 대화는 나쁘지 않았어요. 꽤 쓸 만한 기록입니다.',
      '민트 ($mintProfile): 오늘 이야기 재밌었음ㅋㅋ 다음엔 내가 먼저 사고 칠지도',
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
    return _containsAny(text, ['고마워', '감사', '팬들과 대화', '팬들 덕분', '룸펫']);
  }

  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }
}
