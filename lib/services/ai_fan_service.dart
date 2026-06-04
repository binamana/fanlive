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
  final String sessionMemory;

  const AiFanRequest({
    required this.text,
    required this.stageName,
    required this.fandomName,
    required this.themeTitle,
    required this.recentComments,
    required this.fanAffection,
    required this.sessionMemory,
  });

  Map<String, Object> toJson() {
    return {
      'text': text,
      'stageName': stageName,
      'fandomName': fandomName,
      'themeTitle': themeTitle,
      'recentComments': recentComments,
      'fanAffection': fanAffection,
      'sessionMemory': sessionMemory,
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
  static const _requestTimeout = Duration(seconds: 8);

  static Future<FanReactionResult> reactToSpeech({
    required String text,
    required String stageName,
    required String fandomName,
    required String themeTitle,
    List<String>? recentComments,
    Map<String, int>? fanAffection,
    String? sessionMemory,
  }) async {
    final request = AiFanRequest(
      text: text,
      stageName: stageName,
      fandomName: fandomName,
      themeTitle: themeTitle,
      recentComments: List.unmodifiable(recentComments ?? const []),
      fanAffection: Map.unmodifiable(fanAffection ?? const {}),
      sessionMemory: sessionMemory?.trim() ?? '',
    );

    if (!shouldUseRemoteAi(request)) {
      print('[AiFanService] local fallback used (cost-control)');
      return _localFallback(request);
    }

    print('[AiFanService] remote backend requested');

    try {
      final response = await http
          .post(
            _fanReactionEndpoint,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        print(
          '[AiFanService] local fallback used (backend status ${response.statusCode})',
        );
        return _localFallback(request);
      }

      final decodedBody = jsonDecode(response.body);

      if (decodedBody is! Map<String, dynamic>) {
        print('[AiFanService] local fallback used (invalid backend JSON)');
        return _localFallback(request);
      }

      final result = AiFanResponse.fromJson(decodedBody).toFanReactionResult();
      print('[AiFanService] remote backend used');
      return result;
    } catch (error) {
      print(
        '[AiFanService] local fallback used (backend failed: ${error.runtimeType})',
      );
      return _localFallback(request);
    }
  }

  static bool shouldUseRemoteAi(AiFanRequest request) {
    final text = request.text.trim();
    final compactText = text.replaceAll(RegExp(r'\s+'), '');
    final simpleText = compactText.replaceAll(RegExp(r'[.!?~…]+'), '');

    if (text.isEmpty || _isOnlySimpleReaction(simpleText)) {
      return false;
    }

    if (_isSimplePhrase(simpleText, _simpleGreetingPhrases) ||
        _isSimplePhrase(simpleText, _simpleThanksPhrases) ||
        _isSimplePhrase(simpleText, _simpleGoodbyePhrases)) {
      return false;
    }

    if (_containsAny(text, _contextualRemoteTriggers)) {
      return true;
    }

    if (text.length > 8) {
      return true;
    }

    if (_seemsLikeContextualSentence(text)) {
      return true;
    }

    if (compactText.length <= 4) {
      return false;
    }

    return false;
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

  static const _simpleGreetingPhrases = ['안녕', '하이'];
  static const _simpleThanksPhrases = ['고마워', '고마워요', '감사', '감사해요'];
  static const _simpleGoodbyePhrases = ['잘자', '갈게', '종료'];
  static const _contextualRemoteTriggers = [
    '힘들',
    '피곤',
    '속상',
    '고민',
    '수업',
    '작업',
    '앨범',
    '컴백',
    '발매',
    '팬미팅',
    '오늘',
    '요즘',
  ];

  static bool _isOnlySimpleReaction(String text) {
    return RegExp(r'^(ㅋ+|ㅎ+|ㅠ+|ㅜ+|ㅇ+)$').hasMatch(text);
  }

  static bool _isSimplePhrase(String text, List<String> phrases) {
    return phrases.contains(text);
  }

  static bool _containsAny(String text, List<String> triggers) {
    return triggers.any(text.contains);
  }

  static bool _seemsLikeContextualSentence(String text) {
    if (text.length <= 4) {
      return false;
    }

    return text.contains(' ') ||
        text.endsWith('?') ||
        text.endsWith('!') ||
        text.endsWith('요') ||
        text.endsWith('다') ||
        text.endsWith('어') ||
        text.endsWith('해');
  }
}
