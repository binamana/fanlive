import '../models/live_theme.dart';

class LiveThemeService {
  const LiveThemeService._();

  static List<LiveTheme> getThemes() {
    return const [
      LiveTheme(
        id: 'first_live',
        title: '첫 방송',
        emoji: '✨',
        description: '처음 팬들을 만나는 설렘',
      ),
      LiveTheme(
        id: 'night_talk',
        title: '새벽 감성 방송',
        emoji: '🌙',
        description: '조용하고 따뜻한 분위기',
      ),
      LiveTheme(
        id: 'comeback',
        title: '컴백 직전 방송',
        emoji: '🎤',
        description: '팬들이 스포를 기다리는 방송',
      ),
      LiveTheme(
        id: 'fan_chat',
        title: '팬 수다 방송',
        emoji: '💬',
        description: '팬들과 편하게 대화하기',
      ),
      LiveTheme(
        id: 'album_release_eve',
        title: '앨범 발매 전 라방',
        emoji: '💿',
        description: '새 앨범 이야기를 살짝 들려주는 방송',
      ),
      LiveTheme(
        id: 'birthday_live',
        title: '생일 기념 라방',
        emoji: '🎂',
        description: '팬들과 생일을 함께 축하하는 시간',
      ),
      LiveTheme(
        id: 'fanmeeting_eve',
        title: '팬미팅 전야제',
        emoji: '🎫',
        description: '팬미팅 전날 설렘을 나누는 방송',
      ),
      LiveTheme(
        id: 'dawn_advice',
        title: '새벽 고민 상담',
        emoji: '🌌',
        description: '늦은 밤 팬들의 고민을 들어주는 방송',
      ),
      LiveTheme(
        id: 'studio_behind',
        title: '작업실 비하인드',
        emoji: '🎧',
        description: '작업실에서 들려주는 제작 뒷이야기',
      ),
      LiveTheme(
        id: 'hundred_day_live',
        title: '100일 기념 방송',
        emoji: '💯',
        description: '함께한 100일을 돌아보는 특별 방송',
      ),
    ];
  }
}
