import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/fanlive_config.dart';
import 'fan_reaction_engine.dart';

class AiFanRequest {
  final String text;
  final String stageName;
  final String fandomName;
  final String themeTitle;
  final String customConcept;
  final String conversationMode;
  final String targetFanName;
  final String targetFanPersonality;
  final String targetFanMood;
  final int targetFanAffection;
  final int targetFanNeglect;
  final List<String> recentComments;
  final Map<String, int> fanAffection;
  final String sessionMemory;

  const AiFanRequest({
    required this.text,
    required this.stageName,
    required this.fandomName,
    required this.themeTitle,
    required this.customConcept,
    required this.conversationMode,
    required this.targetFanName,
    required this.targetFanPersonality,
    required this.targetFanMood,
    required this.targetFanAffection,
    required this.targetFanNeglect,
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
      'customConcept': customConcept,
      'conversationMode': conversationMode,
      'targetFanName': targetFanName,
      'targetFanPersonality': targetFanPersonality,
      'targetFanMood': targetFanMood,
      'targetFanAffection': targetFanAffection,
      'targetFanNeglect': targetFanNeglect,
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

    if (rawComments.isEmpty || rawComments.length > 3) {
      throw const FormatException('Invalid AI fan comment count.');
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

  static final _fanReactionEndpoint = FanLiveConfig.aiProxyEndpoint(
    '/fan-reaction',
  );
  static const _requestTimeout = Duration(seconds: 8);

  static Future<FanReactionResult> reactToSpeech({
    required String text,
    required String stageName,
    required String fandomName,
    required String themeTitle,
    String? customConcept,
    String? conversationMode,
    String? targetFanName,
    String? targetFanPersonality,
    String? targetFanMood,
    int? targetFanAffection,
    int? targetFanNeglect,
    List<String>? recentComments,
    Map<String, int>? fanAffection,
    String? sessionMemory,
  }) async {
    final request = AiFanRequest(
      text: text,
      stageName: stageName,
      fandomName: fandomName,
      themeTitle: themeTitle,
      customConcept: customConcept?.trim() ?? '',
      conversationMode: _conversationModeValue(conversationMode),
      targetFanName: targetFanName?.trim() ?? '',
      targetFanPersonality: targetFanPersonality?.trim() ?? '',
      targetFanMood: targetFanMood?.trim() ?? '',
      targetFanAffection: targetFanAffection ?? 0,
      targetFanNeglect: targetFanNeglect ?? 0,
      recentComments: List.unmodifiable(recentComments ?? const []),
      fanAffection: Map.unmodifiable(fanAffection ?? const {}),
      sessionMemory: sessionMemory?.trim() ?? '',
    );

    if (!shouldUseRemoteAi(request)) {
      return _localFallback(request);
    }

    _log('remote requested');

    try {
      final response = await http
          .post(
            _fanReactionEndpoint,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        _log('fallback used: status ${response.statusCode}');
        return _localFallback(request);
      }

      final decodedBody = jsonDecode(response.body);

      if (decodedBody is! Map<String, dynamic>) {
        _log('fallback used: invalid json');
        return _localFallback(request);
      }

      final result = AiFanResponse.fromJson(decodedBody).toFanReactionResult();
      _log('remote used');
      return result;
    } catch (error) {
      _log('fallback used: ${error.runtimeType}');
      return _localFallback(request);
    }
  }

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[AiFanService] $message');
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
    if (request.conversationMode == 'one_on_one') {
      return FanReactionResult(
        comments: [_oneOnOneFallbackComment(request)],
        viewerDelta: 1,
        heartDelta: 5,
      );
    }

    if (request.conversationMode == 'room_chat') {
      return _roomChatFallback(request);
    }

    return FanReactionEngine.reactToSpeech(
      text: request.text,
      stageName: request.stageName,
      fandomName: request.fandomName,
      themeTitle: request.themeTitle,
    );
  }

  static String _conversationModeValue(String? value) {
    final mode = value?.trim();

    if (mode == 'one_on_one' || mode == 'room_chat') {
      return mode!;
    }

    return 'group_live';
  }

  static FanReactionResult _roomChatFallback(AiFanRequest request) {
    return FanReactionResult(
      comments: _roomChatComments(request),
      viewerDelta: 0,
      heartDelta: 0,
    );
  }

  static List<String> _roomChatComments(AiFanRequest request) {
    final text = request.text;

    if (_containsAny(text, ['안녕', '하이'])) {
      return [
        '하루: 왔어요? 아까부터 발소리 들릴 때마다 기다렸어요.',
        '별밤: 이제야 오네요. 방은 생각보다 멀쩡해요, 아직은.',
        '민트: 등장 효과음 틀어야 하는 거 아님?ㅋㅋ',
      ];
    }

    if (_containsAny(text, ['힘들', '피곤', '속상', '외로', '고민'])) {
      return [
        '하루: 그런 상태면 혼자 방에 가만히 있지 말고 저한테 기대도 돼요.',
        '별밤: 일단 오늘 할 일 하나는 버려요. 전부 끌고 가면 더 망가져요.',
        '민트: 쿠션 자리 비워놨어요. 눕고 나서 욕 한 번 하자ㅋㅋ',
      ];
    }

    if (_containsAny(text, ['고마워', '감사'])) {
      return [
        '하루: 그런 말 들으면 안심돼요. 오늘도 여기 있어도 되는 거죠?',
        '별밤: 고맙다는 말은 접수. 대신 내일 무리하면 잔소리합니다.',
        '민트: 감사 인사 받았으니 간식 청구권 생김ㅋㅋ',
      ];
    }

    if (_containsAny(text, ['어떻게', '생각', '할까', '아이디어', '추천'])) {
      return [
        '별밤: 선택지를 두 개로 줄여요. 지금은 큰 결론보다 바로 할 수 있는 쪽이 나아요.',
        '하루: 마음이 덜 다치는 쪽을 골라도 괜찮아요. 꼭 완벽하지 않아도 돼요.',
        '민트: 일단 쉬운 버전으로 테스트 ㄱㄱ. 망하면 내가 방해한 걸로 하죠ㅋㅋ',
      ];
    }

    if (_containsAny(text, ['잘자', '갈게', '나중', '종료'])) {
      return [
        '하루: 벌써 가요? 그래도 쉬어야 하니까... 내일 또 말 걸어줘요.',
        '별밤: 불 끄고 폰 내려놓기. 이건 잔소리 아니라 생존 팁이에요.',
        '민트: 잘자요. 내가 몰래 방 정리할 확률은 낮음ㅋㅋ',
      ];
    }

    return [
      '하루: 방금 말투가 조금 신경 쓰였어요. 괜찮은 거 맞아요?',
      '별밤: 그 얘기는 그냥 넘기기엔 정보가 부족해요. 한 줄만 더 말해봐요.',
      '민트: 오케이, 사이버 거실 회의 안건 접수ㅋㅋ',
    ];
  }

  static String _oneOnOneFallbackComment(AiFanRequest request) {
    final fanName = request.targetFanName.isNotEmpty
        ? request.targetFanName
        : '하루';
    final text = request.text;

    if (_containsAny(text, ['힘들', '피곤', '속상', '고민'])) {
      if (fanName == '별밤') {
        return '$fanName: 지금은 답을 크게 잡기보다, 제일 부담되는 것 하나부터 줄여보면 좋겠어요.';
      }

      if (fanName == '민트') {
        return '$fanName: 오늘은 무리 금지예요. 일단 숨 돌리고 작은 것부터 처리하자구요 💖';
      }

      return '$fanName: 그런 마음이면 혼자 버티지 말고 저한테 조금 더 말해줘도 괜찮아요.';
    }

    if (_containsAny(text, ['고마워', '감사'])) {
      return '$fanName: 나한테 이렇게 말해줘서 고마워요. 오늘 얘기 오래 기억할게요.';
    }

    if (_containsAny(text, ['아이디어', '어떻게', '생각'])) {
      if (fanName == '민트') {
        return '$fanName: 일단 부담 없는 버전으로 하나 해보고 반응 좋으면 키우는 거 어때요? 💖';
      }

      if (fanName == '별밤') {
        return '$fanName: 현실적으로는 선택지를 두 개로 줄이면 바로 움직이기 쉬워 보여요.';
      }

      return '$fanName: 너무 완벽하게 하려기보다 마음이 덜 다치는 쪽부터 골라보면 좋겠어요.';
    }

    return '$fanName: 지금 얘기 천천히 듣고 있어요. 조금 더 말해줘도 좋아요.';
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
    '방',
    '동거',
    '외로',
    '정리',
    '청소',
    '잠',
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
