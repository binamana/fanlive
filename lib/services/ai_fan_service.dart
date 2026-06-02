import 'dart:convert';

import 'package:http/http.dart' as http;

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

  Map<String, Object> toJson() {
    return {
      'text': text,
      'stageName': stageName,
      'fandomName': fandomName,
      'themeTitle': themeTitle,
      'recentComments': recentComments,
      'fanAffection': fanAffection,
    };
  }
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

  factory AiFanResponse.fromJson(Map<String, dynamic> json) {
    final rawComments = json['comments'];
    final rawViewerDelta = json['viewerDelta'];
    final rawHeartDelta = json['heartDelta'];

    if (rawComments is! List ||
        rawViewerDelta is! num ||
        rawHeartDelta is! num) {
      throw const FormatException('Invalid AI fan response shape.');
    }

    final comments = <String>[];
    for (final comment in rawComments) {
      if (comment is! String) {
        throw const FormatException('Invalid AI fan comment value.');
      }
      comments.add(comment);
    }

    return AiFanResponse(
      comments: comments,
      viewerDelta: rawViewerDelta.toInt(),
      heartDelta: rawHeartDelta.toInt(),
    );
  }

  FanReactionResult toFanReactionResult() {
    return FanReactionResult(
      comments: comments,
      viewerDelta: viewerDelta,
      heartDelta: heartDelta,
    );
  }
}

class AiFanService {
  const AiFanService._();

  static final _fanReactionEndpoint = Uri.parse(
    'http://localhost:3000/fan-reaction',
  );
  static const _requestTimeout = Duration(seconds: 2);

  static Future<FanReactionResult> reactToSpeech({
    required String text,
    required String stageName,
    required String fandomName,
    required String themeTitle,
    List<String>? recentComments,
    Map<String, int>? fanAffection,
  }) async {
    final request = AiFanRequest(
      text: text,
      stageName: stageName,
      fandomName: fandomName,
      themeTitle: themeTitle,
      recentComments: List.unmodifiable(recentComments ?? const []),
      fanAffection: Map.unmodifiable(fanAffection ?? const {}),
    );

    try {
      final response = await http
          .post(
            _fanReactionEndpoint,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        return _localFallback(request);
      }

      final decodedBody = jsonDecode(response.body);

      if (decodedBody is! Map<String, dynamic>) {
        return _localFallback(request);
      }

      return AiFanResponse.fromJson(decodedBody).toFanReactionResult();
    } catch (_) {
      return _localFallback(request);
    }
  }

  static FanReactionResult _localFallback(AiFanRequest request) {
    // TODO: Keep this fallback available even after the remote AI path ships.
    // TODO: The backend will own future OpenAI Responses API calls.
    return FanReactionEngine.reactToSpeech(
      text: request.text,
      stageName: request.stageName,
      fandomName: request.fandomName,
      themeTitle: request.themeTitle,
    );
  }
}
