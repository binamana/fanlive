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
    ];
  }
}
