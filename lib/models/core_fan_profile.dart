class CoreFanProfile {
  static const allowedMoods = {'hurt', 'calm', 'warm', 'happy'};

  final String name;
  final String personality;
  int affection;
  String mood;
  int neglect;
  final List<String> favoriteThemes;
  final List<String> dislikedThemes;
  String companionType;
  String currentActivity;
  int energy;
  int curiosity;
  int stress;
  String appearanceType;
  String? imageAssetPath;
  bool isAdopted;

  CoreFanProfile({
    required this.name,
    required this.personality,
    required this.affection,
    required this.mood,
    required this.neglect,
    required this.favoriteThemes,
    required this.dislikedThemes,
    String? companionType,
    String? currentActivity,
    int energy = 60,
    int curiosity = 50,
    int stress = 20,
    String? appearanceType,
    this.imageAssetPath,
    bool isAdopted = true,
  }) : companionType = companionType ?? _defaultCompanionType(name),
       currentActivity = currentActivity ?? _defaultActivity(name),
       energy = _clampPercent(energy),
       curiosity = _clampPercent(curiosity),
       stress = _clampPercent(stress),
       appearanceType = appearanceType ?? _defaultAppearanceType(name),
       isAdopted = isAdopted;

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'personality': personality,
      'affection': _clampNonNegative(affection),
      'mood': allowedMoods.contains(mood) ? mood : 'calm',
      'neglect': _clampNonNegative(neglect),
      'favoriteThemes': favoriteThemes,
      'dislikedThemes': dislikedThemes,
      'companionType': companionType,
      'currentActivity': currentActivity,
      'energy': _clampPercent(energy),
      'curiosity': _clampPercent(curiosity),
      'stress': _clampPercent(stress),
      'appearanceType': appearanceType,
      'imageAssetPath': imageAssetPath,
      'isAdopted': isAdopted,
    };
  }

  factory CoreFanProfile.fromJson(Map<String, dynamic> json) {
    final name = _stringValue(json['name']);

    return CoreFanProfile(
      name: name,
      personality: _stringValue(json['personality']),
      affection: _intValue(json['affection']),
      mood: _moodValue(json['mood']),
      neglect: _intValue(json['neglect']),
      favoriteThemes: _stringListValue(json['favoriteThemes']),
      dislikedThemes: _stringListValue(json['dislikedThemes']),
      companionType: _stringValue(
        json['companionType'],
        fallback: _defaultCompanionType(name),
      ),
      currentActivity: _stringValue(
        json['currentActivity'],
        fallback: _defaultActivity(name),
      ),
      energy: _percentValue(json['energy'], fallback: _defaultEnergy(name)),
      curiosity: _percentValue(
        json['curiosity'],
        fallback: _defaultCuriosity(name),
      ),
      stress: _percentValue(json['stress'], fallback: _defaultStress(name)),
      appearanceType: _stringValue(
        json['appearanceType'],
        fallback: _defaultAppearanceType(name),
      ),
      imageAssetPath: _nullableStringValue(json['imageAssetPath']),
      isAdopted: _boolValue(json['isAdopted'], fallback: true),
    );
  }

  static String _stringValue(Object? value, {String fallback = ''}) {
    if (value is String && value.isNotEmpty) {
      return value;
    }

    return fallback;
  }

  static int _intValue(Object? value) {
    return value is num ? _clampNonNegative(value.toInt()) : 0;
  }

  static int _percentValue(Object? value, {required int fallback}) {
    return value is num ? _clampPercent(value.toInt()) : fallback;
  }

  static String? _nullableStringValue(Object? value) {
    return value is String && value.isNotEmpty ? value : null;
  }

  static bool _boolValue(Object? value, {required bool fallback}) {
    return value is bool ? value : fallback;
  }

  static String _moodValue(Object? value) {
    return value is String && allowedMoods.contains(value) ? value : 'calm';
  }

  static List<String> _stringListValue(Object? value) {
    if (value is! List) {
      return [];
    }

    return value.whereType<String>().toList();
  }

  static int _clampNonNegative(int value) {
    return value < 0 ? 0 : value;
  }

  static int _clampPercent(int value) {
    if (value < 0) return 0;
    if (value > 100) return 100;
    return value;
  }

  static String _defaultCompanionType(String name) {
    switch (name) {
      case '하루':
        return '기다림이 많은 다정한 룸펫';
      case '별밤':
        return '툴툴대는 츤데레 룸펫';
      case '민트':
        return '말썽 많은 장난꾸러기 룸펫';
      default:
        return '룸펫';
    }
  }

  static String _defaultActivity(String name) {
    switch (name) {
      case '하루':
        return '문소리가 날 때마다 조용히 돌아보는 중';
      case '별밤':
        return '책상 끝에서 방 상태를 시니컬하게 관찰하는 중';
      case '민트':
        return '소파 밑에 뭔가 숨기고 모른 척하는 중';
      default:
        return '방 안에서 천천히 적응하는 중';
    }
  }

  static int _defaultEnergy(String name) {
    switch (name) {
      case '별밤':
        return 55;
      case '민트':
        return 80;
      default:
        return 60;
    }
  }

  static int _defaultCuriosity(String name) {
    switch (name) {
      case '별밤':
        return 70;
      case '민트':
        return 75;
      default:
        return 45;
    }
  }

  static int _defaultStress(String name) {
    switch (name) {
      case '별밤':
        return 15;
      case '민트':
        return 10;
      default:
        return 20;
    }
  }

  static String _defaultAppearanceType(String name) {
    switch (name) {
      case '별밤':
        return '로봇형 미니 친구';
      case '민트':
        return '고양이형 디지털 펫';
      default:
        return '둥근 픽셀 생명체';
    }
  }
}
