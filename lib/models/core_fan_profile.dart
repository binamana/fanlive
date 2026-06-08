class CoreFanProfile {
  static const allowedMoods = {'hurt', 'calm', 'warm', 'happy'};

  final String name;
  final String personality;
  int affection;
  String mood;
  int neglect;
  final List<String> favoriteThemes;
  final List<String> dislikedThemes;

  CoreFanProfile({
    required this.name,
    required this.personality,
    required this.affection,
    required this.mood,
    required this.neglect,
    required this.favoriteThemes,
    required this.dislikedThemes,
  });

  Map<String, Object> toJson() {
    return {
      'name': name,
      'personality': personality,
      'affection': _clampNonNegative(affection),
      'mood': allowedMoods.contains(mood) ? mood : 'calm',
      'neglect': _clampNonNegative(neglect),
      'favoriteThemes': favoriteThemes,
      'dislikedThemes': dislikedThemes,
    };
  }

  factory CoreFanProfile.fromJson(Map<String, dynamic> json) {
    return CoreFanProfile(
      name: _stringValue(json['name']),
      personality: _stringValue(json['personality']),
      affection: _intValue(json['affection']),
      mood: _moodValue(json['mood']),
      neglect: _intValue(json['neglect']),
      favoriteThemes: _stringListValue(json['favoriteThemes']),
      dislikedThemes: _stringListValue(json['dislikedThemes']),
    );
  }

  static String _stringValue(Object? value) {
    return value is String ? value : '';
  }

  static int _intValue(Object? value) {
    return value is num ? _clampNonNegative(value.toInt()) : 0;
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
}
