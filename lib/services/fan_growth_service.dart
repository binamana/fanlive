class FanGrowthService {
  const FanGrowthService._();

  static int calculateNewFans(int viewers) {
    return viewers ~/ 8;
  }

  static int calculateLevel(int fanCount) {
    if (fanCount >= 3000) {
      return 5;
    }

    if (fanCount >= 1500) {
      return 4;
    }

    if (fanCount >= 800) {
      return 3;
    }

    if (fanCount >= 300) {
      return 2;
    }

    return 1;
  }

  static void applyAffectionGrowth(Map<String, int> fanAffection) {
    fanAffection['하루'] = (fanAffection['하루'] ?? 0) + 3;
    fanAffection['별밤'] = (fanAffection['별밤'] ?? 0) + 2;
    fanAffection['민트'] = (fanAffection['민트'] ?? 0) + 4;
  }
}
