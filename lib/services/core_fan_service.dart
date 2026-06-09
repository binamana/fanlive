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
        favoriteThemes: const ['새벽 감성 방송', '새벽 고민 상담', '100일 기념 방송'],
        dislikedThemes: const [],
        companionType: '감정형 AI 펫',
        currentActivity: '창가에서 조용히 기다리는 중',
        energy: 60,
        curiosity: 45,
        stress: 20,
      ),
      CoreFanProfile(
        name: '별밤',
        personality: 'calm, realistic, grounded, sometimes gentle fact-check',
        affection: 0,
        mood: 'calm',
        neglect: 0,
        favoriteThemes: const ['작업실 비하인드', '앨범 발매 전 라방', '컴백 직전 방송'],
        dislikedThemes: const [],
        companionType: '분석형 AI 펫',
        currentActivity: '책상에서 오늘의 대화 메모 정리 중',
        energy: 55,
        curiosity: 70,
        stress: 15,
      ),
      CoreFanProfile(
        name: '민트',
        personality: 'playful, quick chat style, meme/heart energy',
        affection: 0,
        mood: 'calm',
        neglect: 0,
        favoriteThemes: const ['팬 수다 방송', '생일 기념 라방', '팬미팅 전야제'],
        dislikedThemes: const [],
        companionType: '장난형 AI 펫',
        currentActivity: '소파 위에서 뒹굴며 장난칠 기회 찾는 중',
        energy: 80,
        curiosity: 75,
        stress: 10,
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
        profile.affection = _clampNonNegative(profile.affection + 2);
        profile.mood = _improveMood(profile.mood);
      } else if (profile.dislikedThemes.contains(themeTitle)) {
        profile.neglect = _clampNonNegative(profile.neglect + 1);
      }

      _clampProfile(profile);
    }
  }

  static List<String> generateRelationshipEvents(
    List<CoreFanProfile> profiles,
    String themeTitle, {
    int maxMessages = 3,
  }) {
    if (profiles.isEmpty || maxMessages <= 0) {
      return [];
    }

    final events = <String>[];

    for (final profile in profiles) {
      if (events.length >= maxMessages) {
        return events;
      }

      if (profile.favoriteThemes.contains(themeTitle)) {
        events.add(_favoriteThemeEvent(profile.name));
      } else if (profile.dislikedThemes.contains(themeTitle)) {
        events.add('${profile.name}이 오늘 방송에서는 조금 서운했던 것 같아요. 서운함 +1');
      }
    }

    if (events.isEmpty) {
      final profile = profiles[_stableProfileIndex(profiles, themeTitle)];
      events.add(_neutralThemeEvent(profile));
    }

    return events.take(maxMessages).toList();
  }

  static void applyOneOnOneLiveResult(
    CoreFanProfile profile, {
    required int userMessageCount,
  }) {
    if (userMessageCount <= 0) {
      return;
    }

    profile.affection = _clampNonNegative(profile.affection + 3);
    profile.neglect = _clampNonNegative(profile.neglect - 2);
    profile.mood = _improveMood(profile.mood);
    _clampProfile(profile);
  }

  static String? generateOneOnOneFollowUpMessage(
    CoreFanProfile profile, {
    required int userMessageCount,
    String? previousMood,
    int? previousNeglect,
  }) {
    if (userMessageCount <= 0) {
      return null;
    }

    final wasDistant =
        previousMood == 'hurt' ||
        (previousNeglect != null && previousNeglect >= 3);

    if (wasDistant) {
      return _oneOnOneCloserAgainMessage(profile.name);
    }

    switch (profile.name) {
      case '하루':
        return '하루: 오늘 1:1로 얘기해줘서 마음이 조금 놓였어요.';
      case '별밤':
        return '별밤: 오늘 1:1 대화는 꽤 의미 있었어요. 다음엔 더 구체적으로 얘기해봐도 좋겠어요.';
      case '민트':
        return '민트: 1:1 라방 재밌었음ㅋㅋ 다음에도 불러줘요 💖';
      default:
        return '${profile.name}: 오늘 1:1로 얘기해줘서 고마워요.';
    }
  }

  static void syncFromLegacyFanAffection(
    List<CoreFanProfile> profiles,
    Map<String, int> fanAffection,
  ) {
    for (final profile in profiles) {
      final legacyAffection = fanAffection[profile.name];

      if (legacyAffection != null) {
        profile.affection = _clampNonNegative(legacyAffection);
      }

      _clampProfile(profile);
    }
  }

  static void syncToLegacyFanAffection(
    List<CoreFanProfile> profiles,
    Map<String, int> fanAffection,
  ) {
    for (final profile in profiles) {
      _clampProfile(profile);
      fanAffection[profile.name] = profile.affection;
    }
  }

  static List<CoreFanProfile> mergeWithDefaultProfiles(
    List<CoreFanProfile> savedProfiles,
  ) {
    final profiles = createDefaultProfiles();

    for (var index = 0; index < profiles.length; index += 1) {
      final savedProfile = findByName(savedProfiles, profiles[index].name);

      if (savedProfile != null) {
        _clampProfile(savedProfile);
        profiles[index] = savedProfile;
      }
    }

    return profiles;
  }

  static String _improveMood(String mood) {
    switch (mood) {
      case 'hurt':
        return 'calm';
      case 'calm':
        return 'warm';
      case 'warm':
        return 'happy';
      case 'happy':
        return 'happy';
      default:
        return 'calm';
    }
  }

  static void _clampProfile(CoreFanProfile profile) {
    profile.affection = _clampNonNegative(profile.affection);
    profile.neglect = _clampNonNegative(profile.neglect);
    profile.energy = _clampPercent(profile.energy);
    profile.curiosity = _clampPercent(profile.curiosity);
    profile.stress = _clampPercent(profile.stress);

    if (profile.companionType.isEmpty) {
      profile.companionType = 'AI 동거 친구';
    }

    if (profile.currentActivity.isEmpty) {
      profile.currentActivity = '방 안에서 천천히 적응하는 중';
    }

    if (!CoreFanProfile.allowedMoods.contains(profile.mood)) {
      profile.mood = 'calm';
    }
  }

  static int _clampNonNegative(int value) {
    return value < 0 ? 0 : value;
  }

  static int _clampPercent(int value) {
    if (value < 0) return 0;
    if (value > 100) return 100;
    return value;
  }

  static String _favoriteThemeEvent(String name) {
    switch (name) {
      case '하루':
        return '하루가 오늘 방송에 더 가까워진 것 같아요. ❤️ +2';
      case '별밤':
        return '별밤이 오늘 방송을 더 믿고 지켜보게 된 것 같아요. ❤️ +2';
      case '민트':
        return '민트가 오늘 방송에 더 신난 것 같아요. ❤️ +2';
      default:
        return '$name이 오늘 방송에 더 가까워진 것 같아요. ❤️ +2';
    }
  }

  static String _neutralThemeEvent(CoreFanProfile profile) {
    switch (profile.name) {
      case '하루':
        return '하루는 오늘 방송을 조용히 오래 지켜봤어요.';
      case '별밤':
        return '별밤은 오늘 방송을 차분하게 지켜봤어요.';
      case '민트':
        return '민트가 다음 팬 수다 방송을 기다리고 있어요.';
      default:
        return '${profile.name}이 오늘 방송을 지켜봤어요.';
    }
  }

  static String _oneOnOneCloserAgainMessage(String name) {
    switch (name) {
      case '하루':
        return '하루: 오늘 1:1로 얘기하니까 다시 조금 가까워진 것 같아서 마음이 놓였어요.';
      case '별밤':
        return '별밤: 오늘 대화로 거리가 조금 줄어든 느낌이에요. 다음엔 더 편하게 얘기해봐요.';
      case '민트':
        return '민트: 오늘 1:1로 다시 가까워진 느낌ㅋㅋ 다음에도 불러줘요 💖';
      default:
        return '$name: 오늘 1:1로 다시 조금 가까워진 것 같아요.';
    }
  }

  static int _stableProfileIndex(
    List<CoreFanProfile> profiles,
    String themeTitle,
  ) {
    final seed = themeTitle.codeUnits.fold<int>(
      0,
      (sum, codeUnit) => sum + codeUnit,
    );

    return seed % profiles.length;
  }
}
