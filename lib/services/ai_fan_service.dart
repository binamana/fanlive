import 'fan_reaction_engine.dart';

class AiFanService {
  const AiFanService._();

  static FanReactionResult reactToSpeech({
    required String text,
    required String stageName,
    required String fandomName,
    required String themeTitle,
  }) {
    return FanReactionEngine.reactToSpeech(
      text: text,
      stageName: stageName,
      fandomName: fandomName,
      themeTitle: themeTitle,
    );
  }
}
