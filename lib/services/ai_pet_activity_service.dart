import '../models/core_fan_profile.dart';

class AiPetActivityService {
  const AiPetActivityService._();

  static List<CoreFanProfile> updateActivitiesForHomeView(
    List<CoreFanProfile> profiles,
  ) {
    for (final profile in profiles) {
      if (!profile.isAdopted) continue;
      profile.currentActivity = getActivityForProfile(profile);
    }

    return profiles;
  }

  static String getActivityForProfile(CoreFanProfile profile) {
    if (!profile.isAdopted) {
      return '나중에 새 룸펫을 입양할 수 있어요.';
    }

    if (profile.neglect >= 5) {
      return '방 한쪽에서 혼자 조용히 충전하는 중';
    }

    if (profile.stress >= 70) {
      return '작은 담요를 끌어안고 말 걸 타이밍을 보는 중';
    }

    if (profile.energy <= 30) {
      return '쿠션 위에서 거의 방전된 채 졸고 있는 중';
    }

    if (profile.mood == 'happy') {
      return '방 안을 신나게 돌아다니며 존재감을 어필하는 중';
    }

    if (profile.curiosity >= 75) {
      return '새로운 대화 주제가 떨어질지 방을 둘러보는 중';
    }

    if (profile.affection >= 20) {
      return '문 쪽을 힐끔거리며 사용자가 말 걸어주길 기다리는 중';
    }

    return profile.currentActivity.isNotEmpty
        ? profile.currentActivity
        : '방 안에서 천천히 적응하는 중';
  }
}
