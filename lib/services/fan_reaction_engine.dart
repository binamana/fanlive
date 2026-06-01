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
  }) {
    final normalizedText = text.trim();

    if (_containsAny(normalizedText, ['안녕', '하이'])) {
      return FanReactionResult(
        comments: [
          '하루: 왔다 왔다! 오늘도 와줘서 안심돼요',
          '별밤: $fandomName 출석 확인. 오늘도 천천히 가보자',
          '민트: 입장하자마자 하트 장전 완료 💖',
        ],
        viewerDelta: 8,
        heartDelta: 20,
      );
    }

    if (_containsAny(normalizedText, ['힘들', '피곤', '속상'])) {
      return const FanReactionResult(
        comments: [
          '하루: 무슨 일 있었어요? 너무 걱정돼요',
          '별밤: 오늘은 무리하지 말고 페이스 낮춰도 괜찮아요',
          '민트: 일단 하트 담요 덮어드림 💖💖💖',
          '하루: 우리 여기 있으니까 조금만 기대도 돼요',
        ],
        viewerDelta: 14,
        heartDelta: 55,
      );
    }

    if (_containsAny(normalizedText, ['고마워', '감사'])) {
      return const FanReactionResult(
        comments: [
          '하루: 그런 말 들으면 진짜 울컥해요',
          '별밤: 고마움은 서로 주고받는 거죠. 오래 봐요',
          '민트: 감동 멘트 수집 완료... 이건 못 떠남 💖',
        ],
        viewerDelta: 12,
        heartDelta: 70,
      );
    }

    if (_containsAny(normalizedText, ['갈게', '종료', '잘자'])) {
      return const FanReactionResult(
        comments: [
          '하루: 벌써 가요? 조심히 들어가고 꼭 쉬어요',
          '별밤: 오늘 방송 수고했어요. 마무리 잘하고 자요',
          '민트: 가지마 모드 켜짐... 그래도 잘자요 💖',
        ],
        viewerDelta: 4,
        heartDelta: 12,
      );
    }

    if (_containsAny(normalizedText, ['컴백', '발매', '스포'])) {
      return const FanReactionResult(
        comments: [
          '하루: 컴백 얘기 들으니까 심장이 너무 빨리 뛰어요',
          '별밤: 발매 일정 나오면 바로 캘린더에 넣어둘게요',
          '민트: 스포 감지! 지금 채팅창 뒤집어짐 💖',
          '별밤: 기대는 되지만 컨디션도 꼭 챙겨요',
        ],
        viewerDelta: 18,
        heartDelta: 65,
      );
    }

    if (_containsAny(normalizedText, ['노래', '곡', '작업', '앨범'])) {
      return const FanReactionResult(
        comments: [
          '하루: 작업 이야기 들으면 괜히 마음이 두근거려요',
          '별밤: 곡 얘기는 언제 들어도 좋아요. 과정도 궁금해요',
          '민트: 앨범 떡밥이다! 하트 폭주 버튼 누름 💖',
        ],
        viewerDelta: 6,
        heartDelta: 18,
      );
    }

    return FanReactionResult(
      comments: [
        '하루: 오늘 말투도 다정해서 계속 듣고 싶어요',
        '별밤: $stageName 라방은 편하게 오래 보기 좋아요',
        '민트: 방금 멘트 귀여움 저장함ㅋㅋ 💖',
      ],
      viewerDelta: 6,
      heartDelta: 18,
    );
  }

  static bool _containsAny(String text, List<String> triggers) {
    return triggers.any(text.contains);
  }
}
