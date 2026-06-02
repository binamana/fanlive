import 'fan_reaction_engine.dart';

class AiFanRequest {
  final String text;
  final String stageName;
  final String fandomName;
  final String themeTitle;
  final List<String> recentComments;
  final Map<String, int> fanAffection;

  const AiFanRequest({
    required this.text,
    required this.stageName,
    required this.fandomName,
    required this.themeTitle,
    required this.recentComments,
    required this.fanAffection,
  });
}

class AiFanResponse {
  final List<String> comments;
  final int viewerDelta;
  final int heartDelta;

  const AiFanResponse({
    required this.comments,
    required this.viewerDelta,
    required this.heartDelta,
  });
}

class AiFanService {
  const AiFanService._();

  static FanReactionResult reactToSpeech({
    required String text,
    required String stageName,
    required String fandomName,
    required String themeTitle,
    List<String>? recentComments,
    Map<String, int>? fanAffection,
  }) {
    final request = AiFanRequest(
      text: text,
      stageName: stageName,
      fandomName: fandomName,
      themeTitle: themeTitle,
      recentComments: List.unmodifiable(recentComments ?? const []),
      fanAffection: Map.unmodifiable(fanAffection ?? const {}),
    );

    // TODO: Send AiFanRequest to a backend endpoint that owns remote AI calls.
    // TODO: Convert the backend AiFanResponse into FanReactionResult.
    return _localFallback(request);
  }

  static FanReactionResult _localFallback(AiFanRequest request) {
    return FanReactionEngine.reactToSpeech(
      text: request.text,
      stageName: request.stageName,
      fandomName: request.fandomName,
      themeTitle: request.themeTitle,
    );
  }
}
