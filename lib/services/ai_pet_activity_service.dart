import '../models/core_fan_profile.dart';

class AiPetActivityService {
  const AiPetActivityService._();

  static List<CoreFanProfile> updateActivitiesForHomeView(
    List<CoreFanProfile> profiles,
  ) {
    for (final profile in profiles) {
      profile.currentActivity = getActivityForProfile(profile);
    }

    return profiles;
  }

  static String getActivityForProfile(CoreFanProfile profile) {
    if (profile.neglect >= 5) {
      return '방 한쪽에서 조용히 혼자 있는 중';
    }

    if (profile.stress >= 70) {
      return '작은 담요를 끌어안고 쉬는 중';
    }

    if (profile.energy <= 30) {
      return '쿠션 위에서 졸고 있는 중';
    }

    if (profile.mood == 'happy') {
      return '방 안을 신나게 돌아다니는 중';
    }

    if (profile.curiosity >= 75) {
      return '새 가구가 생길지 기대하며 둘러보는 중';
    }

    if (profile.affection >= 20) {
      return '문 쪽을 보며 사용자를 기다리는 중';
    }

    return profile.currentActivity.isNotEmpty
        ? profile.currentActivity
        : '방 안에서 천천히 적응하는 중';
  }
}
