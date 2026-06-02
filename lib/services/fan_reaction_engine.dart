class FanReactionResult {
  final List<String> comments;
  final int viewerDelta;
  final int heartDelta;

  const FanReactionResult({
    required this.comments,
    required this.viewerDelta,
    required this.heartDelta,
  });
}

class FanReactionEngine {
  const FanReactionEngine._();

  static FanReactionResult reactToSpeech({
    required String text,
    required String stageName,
    required String fandomName,
    required String themeTitle,
  }) {
    final normalizedText = text.trim();
    final normalizedTheme = themeTitle.trim();

    if (_containsAny(normalizedText, ['안녕', '하이'])) {
      return FanReactionResult(
        comments: _greetingComments(normalizedTheme, fandomName),
        viewerDelta: 8,
        heartDelta: 20,
      );
    }

    if (_containsAny(normalizedText, ['힘들', '피곤', '속상'])) {
      return FanReactionResult(
        comments: _emotionalComments(normalizedTheme),
        viewerDelta: 14,
        heartDelta: 55,
      );
    }

    if (_containsAny(normalizedText, ['고마워', '감사'])) {
      return FanReactionResult(
        comments: _thanksComments(normalizedTheme),
        viewerDelta: 12,
        heartDelta: 70,
      );
    }

    if (_containsAny(normalizedText, ['갈게', '종료', '잘자'])) {
      return FanReactionResult(
        comments: _goodbyeComments(normalizedTheme),
        viewerDelta: 4,
        heartDelta: 12,
      );
    }

    if (_containsAny(normalizedText, ['컴백', '발매', '스포'])) {
      return FanReactionResult(
        comments: _comebackComments(normalizedTheme),
        viewerDelta: 18,
        heartDelta: 65,
      );
    }

    if (_containsAny(normalizedText, ['노래', '곡', '작업', '앨범'])) {
      return FanReactionResult(
        comments: _musicWorkComments(normalizedTheme),
        viewerDelta: 6,
        heartDelta: 18,
      );
    }

    return FanReactionResult(
      comments: _defaultComments(normalizedTheme, stageName),
      viewerDelta: 6,
      heartDelta: 18,
    );
  }

  static List<String> _greetingComments(String themeTitle, String fandomName) {
    switch (themeTitle) {
      case '생일 기념 라방':
        return [
          '하루: 생일 라방 입장 완료! 오늘 진짜 특별한 날이야',
          '별밤: $fandomName 다 같이 축하하러 왔어요',
          '민트: 생일 축하 하트 장전 완료 💖',
        ];
      case '새벽 고민 상담':
        return [
          '하루: 안녕, 새벽엔 천천히 얘기해도 돼요',
          '별밤: 조용히 들어왔어요. 오늘도 편하게 가요',
          '민트: 작은 목소리로 하이... 하트는 크게 💖',
        ];
      case '첫 방송':
        return [
          '하루: 왔다 왔다! 첫 방송부터 함께라니 좋아요',
          '별밤: $fandomName 출석 확인. 천천히 시작해보자',
          '민트: 첫 인사부터 하트 장전 완료 💖',
        ];
      default:
        return [
          '하루: 왔다 왔다! 오늘도 와줘서 안심돼요',
          '별밤: $fandomName 출석 확인. 오늘도 천천히 가보자',
          '민트: 입장하자마자 하트 장전 완료 💖',
        ];
    }
  }

  static List<String> _emotionalComments(String themeTitle) {
    switch (themeTitle) {
      case '새벽 고민 상담':
        return [
          '하루: 오늘은 힘든 얘기 천천히 해도 괜찮아요',
          '별밤: 새벽엔 마음이 더 크게 느껴질 때가 있죠',
          '민트: 말 안 해도 옆에 앉아있는 모드 켰어요 💖',
          '하루: 여기서는 조금 내려놓고 쉬어도 돼요',
        ];
      case '새벽 감성 방송':
        return [
          '하루: 새벽이라 그런지 그 말이 더 마음에 와요',
          '별밤: 오늘은 무리하지 말고 낮은 텐션이어도 좋아요',
          '민트: 조용한 하트 담요 덮어드림 💖',
        ];
      default:
        return [
          '하루: 무슨 일 있었어요? 너무 걱정돼요',
          '별밤: 오늘은 무리하지 말고 페이스 낮춰도 괜찮아요',
          '민트: 일단 하트 담요 덮어드림 💖💖💖',
          '하루: 우리 여기 있으니까 조금만 기대도 돼요',
        ];
    }
  }

  static List<String> _thanksComments(String themeTitle) {
    switch (themeTitle) {
      case '생일 기념 라방':
        return [
          '하루: 생일에 그런 말까지 해주면 진짜 울컥해요',
          '별밤: 오늘 특별한 날을 같이 보내줘서 우리가 더 고마워요',
          '민트: 축하하다가 감동까지 받는 중 💖',
        ];
      case '100일 기념 방송':
        return [
          '하루: 100일 동안 같이 봐줘서 우리가 더 고마워요',
          '별밤: 고마움은 쌓이는 거죠. 오래 보자',
          '민트: 100일 감동 멘트 저장 완료 💖',
        ];
      default:
        return [
          '하루: 그런 말 들으면 진짜 울컥해요',
          '별밤: 고마움은 서로 주고받는 거죠. 오래 봐요',
          '민트: 감동 멘트 수집 완료... 이건 못 떠남 💖',
        ];
    }
  }

  static List<String> _goodbyeComments(String themeTitle) {
    switch (themeTitle) {
      case '팬미팅 전야제':
        return [
          '하루: 내일 팬미팅에서 또 보자, 푹 쉬어요',
          '별밤: 응원법 복습은 여기까지. 컨디션 챙기자',
          '민트: 내일 목소리 아껴야 해서 잘자요 💖',
        ];
      case '새벽 고민 상담':
        return [
          '하루: 오늘 얘기 고마워요. 편하게 잠들었으면 좋겠어',
          '별밤: 마무리는 천천히 해도 돼요. 잘 쉬어요',
          '민트: 새벽 상담소 종료... 따뜻한 꿈 꿔요 💖',
        ];
      default:
        return [
          '하루: 벌써 가요? 조심히 들어가고 꼭 쉬어요',
          '별밤: 오늘 방송 수고했어요. 마무리 잘하고 자요',
          '민트: 가지마 모드 켜짐... 그래도 잘자요 💖',
        ];
    }
  }

  static List<String> _comebackComments(String themeTitle) {
    switch (themeTitle) {
      case '앨범 발매 전 라방':
        return [
          '하루: 앨범 발매 얘기만 나오면 심장이 빨라져요',
          '별밤: 트랙 스포는 적당히만요. 기대감은 이미 충분해요',
          '민트: 스포 감지! 채팅창 지금 발매 대기 중 💖',
          '별밤: 앨범 나오면 바로 들을 준비 끝났어요',
        ];
      case '컴백 직전 방송':
        return [
          '하루: 컴백 얘기 들으니까 심장이 너무 빨리 뛰어요',
          '별밤: 발매 일정 나오면 바로 캘린더에 넣어둘게요',
          '민트: 스포 감지! 지금 채팅창 뒤집어짐 💖',
          '별밤: 기대는 되지만 컨디션도 꼭 챙겨요',
        ];
      case '팬미팅 전야제':
        return [
          '하루: 내일 팬미팅에서 컴백 얘기도 듣는 거야?',
          '별밤: 응원법이랑 스포 둘 다 준비해야겠네요',
          '민트: 팬미팅 전날 스포라니 잠 못 잠 💖',
        ];
      default:
        return [
          '하루: 컴백 얘기 들으니까 심장이 너무 빨리 뛰어요',
          '별밤: 발매 일정 나오면 바로 캘린더에 넣어둘게요',
          '민트: 스포 감지! 지금 채팅창 뒤집어짐 💖',
          '별밤: 기대는 되지만 컨디션도 꼭 챙겨요',
        ];
    }
  }

  static List<String> _musicWorkComments(String themeTitle) {
    switch (themeTitle) {
      case '앨범 발매 전 라방':
        return [
          '하루: 앨범 작업 이야기 들으면 괜히 두근거려요',
          '별밤: 트랙 설명 들으니까 발매가 더 기다려져요',
          '민트: 앨범 떡밥이다! 하트 폭주 버튼 누름 💖',
        ];
      case '작업실 비하인드':
        return [
          '하루: 작업실 비하인드 들으니까 곡이 더 소중해져요',
          '별밤: 제작 과정 얘기는 언제 들어도 흥미로워요',
          '민트: 작업실 썰 더 주세요. 귀가 반짝함 💖',
          '별밤: 이런 디테일 들으면 다시 듣게 돼요',
        ];
      case '컴백 직전 방송':
        return [
          '하루: 이번 곡 얘기 나올 때마다 기대가 커져요',
          '별밤: 작업 과정 들으니까 컴백이 더 현실 같아요',
          '민트: 노래 떡밥이면 채팅창 바로 폭주 💖',
        ];
      default:
        return [
          '하루: 작업 이야기 들으면 괜히 마음이 두근거려요',
          '별밤: 곡 얘기는 언제 들어도 좋아요. 과정도 궁금해요',
          '민트: 앨범 떡밥이다! 하트 폭주 버튼 누름 💖',
        ];
    }
  }

  static List<String> _defaultComments(String themeTitle, String stageName) {
    switch (themeTitle) {
      case '새벽 고민 상담':
        return [
          '하루: 오늘 말이 조용해서 더 오래 듣고 싶어요',
          '별밤: $stageName 얘기 덕분에 마음이 조금 가라앉아요',
          '민트: 새벽 공기처럼 말랑한 멘트 저장 💖',
        ];
      case '팬미팅 전야제':
        return [
          '하루: 내일 팬미팅 생각하니까 계속 설레요',
          '별밤: $stageName이랑 응원법 맞춰볼 생각에 기대돼요',
          '민트: 내일 만날 준비 이미 완료함 💖',
        ];
      case '100일 기념 방송':
        return [
          '하루: 100일 동안 같이 본 시간이 생각나요',
          '별밤: $stageName 라방은 오래 보고 싶은 힘이 있어요',
          '민트: 오래 보자 멘트 자동 재생 중 💖',
        ];
      default:
        return [
          '하루: 오늘 말투도 다정해서 계속 듣고 싶어요',
          '별밤: $stageName 라방은 편하게 오래 보기 좋아요',
          '민트: 방금 멘트 귀여움 저장함ㅋㅋ 💖',
        ];
    }
  }

  static bool _containsAny(String text, List<String> triggers) {
    return triggers.any(text.contains);
  }
}
