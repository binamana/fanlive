class FanMailService {
  const FanMailService._();

  static List<String> generateMessages({
    required String summary,
    required String earnedTitle,
    required Map<String, String> fanProfiles,
  }) {
    if (summary.contains('감정') || earnedTitle == '감성 방송러') {
      return [
        '하루 (${fanProfiles['하루']}): 오늘은 조금 걱정됐어요. 그래도 와줘서 고마워요 💖',
        '별밤 (${fanProfiles['별밤']}): 무리하지 말고 쉬는 시간도 꼭 챙겨요.',
        '민트 (${fanProfiles['민트']}): 일단 하트 잔뜩 보내고 갈게요 💖💖💖',
      ];
    }

    if (summary.contains('음악') || earnedTitle == '작업 토크 장인') {
      return [
        '하루 (${fanProfiles['하루']}): 오늘 작업 이야기 너무 좋았어요. 다음에 또 들려줘요!',
        '별밤 (${fanProfiles['별밤']}): 새 곡 이야기 들으니까 진짜 기대돼요.',
        '민트 (${fanProfiles['민트']}): 스포 더 주세요... 아니 조금만요 😆',
      ];
    }

    if (summary.contains('고마운') || earnedTitle == '팬서비스 요정') {
      return [
        '하루 (${fanProfiles['하루']}): 오늘 고맙다고 해준 거 진짜 감동이었어요.',
        '별밤 (${fanProfiles['별밤']}): 우리가 더 고마워요. 오래 봐요.',
        '민트 (${fanProfiles['민트']}): 팬서비스 미쳤다... 오늘 못 잊음 😆',
      ];
    }

    return [
      '하루 (${fanProfiles['하루']}): 오늘 방송 와줘서 고마워요 💖',
      '별밤 (${fanProfiles['별밤']}): 다음 방송도 기다릴게요!',
      '민트 (${fanProfiles['민트']}): 오늘 이야기 재밌었어요 😆',
    ];
  }
}
