class CoreFanProfile {
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
}
