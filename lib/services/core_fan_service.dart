import '../models/core_fan_profile.dart';

class CoreFanService {
  const CoreFanService._();

  static List<CoreFanProfile> createDefaultProfiles() {
    return [
      CoreFanProfile(
        name: '하루',
        personality: 'caring, emotional, slightly worried, long-time fan',
        affection: 0,
        mood: 'calm',
        neglect: 0,
        favoriteThemes: const [
          '새벽 감성 방송',
          '새벽 고민 상담',
          '100일 기념 방송',
        ],
        dislikedThemes: const [],
      ),
      CoreFanProfile(
        name: '별밤',
        personality:
            'calm, realistic, grounded, sometimes gentle fact-check',
        affection: 0,
        mood: 'calm',
        neglect: 0,
        favoriteThemes: const [
          '작업실 비하인드',
          '앨범 발매 전 라방',
          '컴백 직전 방송',
        ],
        dislikedThemes: const [],
      ),
      CoreFanProfile(
        name: '민트',
        personality: 'playful, quick chat style, meme/heart energy',
        affection: 0,
        mood: 'calm',
        neglect: 0,
        favoriteThemes: const [
          '팬 수다 방송',
          '생일 기념 라방',
          '팬미팅 전야제',
        ],
        dislikedThemes: const [],
      ),
    ];
  }

  static CoreFanProfile? findByName(
    List<CoreFanProfile> profiles,
    String name,
  ) {
    for (final profile in profiles) {
      if (profile.name == name) {
        return profile;
      }
    }

    return null;
  }

  static void applyThemeAffinity(
    List<CoreFanProfile> profiles,
    String themeTitle,
  ) {
    for (final profile in profiles) {
      if (profile.favoriteThemes.contains(themeTitle)) {
        profile.affection += 2;
        profile.mood = _improveMood(profile.mood);
      } else if (profile.dislikedThemes.contains(themeTitle)) {
        profile.neglect += 1;
      }
    }
  }

  static void syncFromLegacyFanAffection(
    List<CoreFanProfile> profiles,
    Map<String, int> fanAffection,
  ) {
    for (final profile in profiles) {
      final legacyAffection = fanAffection[profile.name];

      if (legacyAffection != null) {
        profile.affection = legacyAffection;
      }
    }
  }

  static void syncToLegacyFanAffection(
    List<CoreFanProfile> profiles,
    Map<String, int> fanAffection,
  ) {
    for (final profile in profiles) {
      fanAffection[profile.name] = profile.affection;
    }
  }

  static String _improveMood(String mood) {
    switch (mood) {
      case 'hurt':
        return 'calm';
      case 'calm':
        return 'warm';
      case 'warm':
        return 'happy';
      default:
        return mood;
    }
  }
}
