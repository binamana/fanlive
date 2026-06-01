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
    if (_containsAny(text, ['안녕', '하이'])) {
      return FanReactionResult(
        comments: [
          '하루: 왔다 왔다!',
          '별밤: 오늘도 반가워요 💖',
          '민트: $fandomName 출석!',
        ],
        viewerDelta: 8,
        heartDelta: 20,
      );
    }

    if (_containsAny(text, ['힘들', '피곤', '속상'])) {
      return const FanReactionResult(
        comments: [
          '새벽이: 무슨 일 있었어요ㅠ',
          '모찌: 괜찮아요? 무리하지 말아요',
          '하루: 우리 여기 있어요',
          '별밤: 오늘 와줘서 고마워요',
        ],
        viewerDelta: 14,
        heartDelta: 55,
      );
    }

    if (_containsAny(text, ['고마워', '감사'])) {
      return const FanReactionResult(
        comments: [
          '하트요정: 우리가 더 고마워요',
          '민트: 이래서 못 떠남 진짜',
          '별밤: 평생 응원할게요',
        ],
        viewerDelta: 12,
        heartDelta: 70,
      );
    }

    if (_containsAny(text, ['노래', '곡', '작업', '앨범'])) {
      return const FanReactionResult(
        comments: [
          '하루: 작업 이야기 너무 좋다',
          '별밤: 새 곡 이야기 기대돼요',
          '민트: 스포 더 주세요... 아니 조금만요 😆',
        ],
        viewerDelta: 6,
        heartDelta: 18,
      );
    }

    return FanReactionResult(
      comments: [
        '첫방문자: 오늘 분위기 좋다',
        '민트: 방금 말투 귀여움ㅋㅋ',
        '별밤: $stageName 라방 은근 중독됨',
      ],
      viewerDelta: 6,
      heartDelta: 18,
    );
  }

  static bool _containsAny(String text, List<String> triggers) {
    return triggers.any(text.contains);
  }
}
