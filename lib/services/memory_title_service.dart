class MemoryTitleService {
  const MemoryTitleService._();

  static const allTitles = [
    '이상한 동거의 시작',
    '픽셀 룸의 주인',
    '하루가 기다린 사람',
    '별밤의 관찰 대상',
    '민트의 공범',
    '새벽을 같이 넘긴 방',
    '쿠션 아래의 비밀친구',
    '말썽을 수습한 보호자',
    '조용한 작업실의 주인',
    '혼돈의 방 정리반',
    '오늘도 돌아온 사람',
  ];

  static String displayTitle(String title) {
    switch (title) {
      case '첫 데뷔':
        return '이상한 동거의 시작';
      case '감성 방송러':
        return '하루가 기다린 사람';
      case '팬들과 버틴 하루':
        return '새벽을 같이 넘긴 방';
      case '작업 토크 장인':
        return '조용한 작업실의 주인';
      case '팬서비스 요정':
        return '오늘도 돌아온 사람';
      case '하트 폭격':
        return '민트의 공범';
      case '라이징 스타':
        return '픽셀 룸의 주인';
      case '사이버 방의 주인':
        return '픽셀 룸의 주인';
      default:
        return title.isEmpty ? '이상한 동거의 시작' : title;
    }
  }

  static String displayRecordTheme(String themeTitle) {
    switch (themeTitle) {
      case '첫 방송':
        return '첫 입주일';
      case '새벽 감성 방송':
        return '새벽 방 대화';
      case '컴백 직전 방송':
        return '큰일 전날의 방';
      case '팬 수다 방송':
        return '룸펫 수다 시간';
      case '앨범 발매 전 라방':
        return '작업 전날의 방';
      case '생일 기념 라방':
        return '생일 방 파티';
      case '팬미팅 전야제':
        return '약속 전야의 방';
      case '100일 기념 방송':
        return '100일 동거 기록';
      default:
        return themeTitle
            .replaceAll('팬미팅', '약속')
            .replaceAll('팬', '룸펫')
            .replaceAll('라방', '방 기록')
            .replaceAll('방송', '생활 기록');
    }
  }

  static String displaySummary(String summary) {
    return summary
        .replaceAll('팬들과', '룸펫과')
        .replaceAll('팬들에게', '룸펫에게')
        .replaceAll('팬들', '룸펫들')
        .replaceAll('팬', '룸펫')
        .replaceAll('라방', '생활 기록')
        .replaceAll('방송', '방 대화')
        .replaceAll('시청자', '방문 흔적')
        .replaceAll('하트', '감정 에너지');
  }
}
