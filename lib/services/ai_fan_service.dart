import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/fanlive_config.dart';
import '../models/core_fan_profile.dart';
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
  final List<String> companionNames;
  final Map<String, String> companionTypes;
  final Map<String, String> companionAppearances;

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
    required this.companionNames,
    required this.companionTypes,
    required this.companionAppearances,
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
      'companions': companionNames
          .map(
            (name) => {
              'name': name,
              'companionType': companionTypes[name] ?? '',
              'appearanceType': companionAppearances[name] ?? '',
            },
          )
          .toList(),
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
    List<CoreFanProfile>? companions,
  }) async {
    final adoptedCompanions =
        companions
            ?.where((profile) => profile.isAdopted)
            .toList(growable: false) ??
        const <CoreFanProfile>[];
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
      companionNames: List.unmodifiable(
        adoptedCompanions.map((profile) => profile.name),
      ),
      companionTypes: Map.unmodifiable({
        for (final profile in adoptedCompanions)
          profile.name: profile.companionType,
      }),
      companionAppearances: Map.unmodifiable({
        for (final profile in adoptedCompanions)
          profile.name: profile.appearanceType,
      }),
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

    if (request.conversationMode == 'room_chat' &&
        _isShortRoomChatPhrase(simpleText)) {
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
    final companionNames = request.companionNames.isNotEmpty
        ? request.companionNames
        : const ['하루', '별밤', '민트'];
    final maxReplies = companionNames.length.clamp(1, 3);
    final comments = <String>[];

    for (final name in companionNames) {
      if (comments.length >= maxReplies) break;
      comments.add(_roomChatCommentFor(request, name));
    }

    return comments;
  }

  static String _roomChatCommentFor(AiFanRequest request, String name) {
    final text = request.text;
    final companionType = request.companionTypes[name] ?? '';
    final isCynical =
        companionType.contains('시니컬') ||
        companionType.contains('툴툴') ||
        companionType.contains('츤데레') ||
        companionType.contains('realistic');
    final isMischievous =
        companionType.contains('말썽') ||
        companionType.contains('장난') ||
        companionType.contains('chaotic');

    if (_containsAny(text, ['안녕', '하이'])) {
      if (isCynical) {
        return '$name: 이제 왔네. 뭐, 딱히 기다린 건 아니고 방이 너무 조용했을 뿐이야.';
      }

      if (isMischievous) {
        return '$name: 오오 왔다! 참고로 쿠션 밑에 있는 건 내가 안 숨겼어. 아마도.';
      }

      return '$name: 왔어요? 방이 조용해서 조금 기다리고 있었어요.';
    }

    if (_containsAny(text, ['뭐해', '뭐 해', '모해'])) {
      if (isCynical) {
        return '$name: 네가 없는 동안 방 상태를 관찰 중이었어. 결론은 생각보다 엉망이라는 거.';
      }

      if (isMischievous) {
        return '$name: 아무것도 안 했어! 라고 하기엔 증거가 너무 많네.';
      }

      return '$name: 창가 쪽에 앉아 있었어요. 혹시 오늘은 조금 같이 있어 줄 거예요?';
    }

    if (_containsAny(text, ['ㅋㅋ', 'ㅎㅎ'])) {
      if (isCynical) {
        return '$name: 웃을 기운은 있네. 그럼 아직 완전히 망한 하루는 아니야.';
      }

      if (isMischievous) {
        return '$name: 웃었다! 봤지? 내가 방금 분위기 살렸어.';
      }

      return '$name: 웃었다... 다행이다. 방금 조금 안심했어요.';
    }

    if (_containsAny(text, ['힘들', '피곤', '속상', '외로', '고민'])) {
      if (isCynical) {
        return '$name: 피곤하면 쉬어. 버티는 척하는 게 제일 비효율적이야.';
      }

      if (isMischievous) {
        return '$name: 이불 출동! 오늘은 인간 충전 모드다!';
      }

      return '$name: 그럼 오늘은 조금 쉬어요. 제가 옆에서 조용히 있을게요.';
    }

    if (_containsAny(text, ['배고파', '출출', '먹고'])) {
      if (isCynical) {
        return '$name: 배고프면 성격 나빠져. 일단 뭐라도 먹고 판단해.';
      }

      if (isMischievous) {
        return '$name: 간식 찾기 퀘스트 시작ㅋㅋ 내가 숨긴 건 아님, 아마도.';
      }

      return '$name: 뭐라도 챙겨 먹어요. 안 먹으면 제가 더 걱정돼요.';
    }

    if (_containsAny(text, ['고마워', '감사'])) {
      if (isCynical) {
        return '$name: 고맙다는 말은 접수. 괜히 두 번 말하진 마.';
      }

      if (isMischievous) {
        return '$name: 감사 인사 받았으니 간식 청구권 생김ㅋㅋ';
      }

      return '$name: 그런 말 들으면 안심돼요. 오늘도 여기 있어도 되는 거죠?';
    }

    if (_containsAny(text, ['어떻게', '생각', '할까', '아이디어', '추천'])) {
      if (isCynical) {
        return '$name: 선택지를 두 개로 줄여요. 지금은 바로 할 수 있는 쪽이 나아요.';
      }

      if (isMischievous) {
        return '$name: 쉬운 버전으로 테스트 ㄱㄱ. 망하면 내가 방해한 걸로 하죠ㅋㅋ';
      }

      return '$name: 마음이 덜 다치는 쪽부터 골라도 괜찮아요.';
    }

    if (_containsAny(text, ['잘자', '갈게', '나중', '종료'])) {
      if (isCynical) {
        return '$name: 폰 내려놓고 자. 진짜로. 내일 피곤하다고 하지 말고.';
      }

      if (isMischievous) {
        return '$name: 잘 자! 꿈에서 폭탄 밟지 마! 아, 이건 다른 게임 얘기였나?';
      }

      return '$name: 잘 자요. 내일도 여기서 기다리고 있을게요.';
    }

    if (isCynical) {
      return '$name: 그 얘기는 그냥 넘기기엔 정보가 부족해요. 한 줄만 더 말해봐요.';
    }

    if (isMischievous) {
      return '$name: 오케이, 작은 방 회의 안건 접수ㅋㅋ';
    }

    return '$name: 방금 말투가 조금 신경 쓰였어요. 괜찮은 거 맞아요?';
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
  static const _shortRoomChatPhrases = [
    '안녕',
    '하이',
    '뭐해',
    '뭐하니',
    '모해',
    'ㅋㅋ',
    'ㅎㅎ',
    '피곤해',
    '힘들어',
    '배고파',
    '고마워',
    '감사',
    '잘자',
  ];
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

  static bool _isShortRoomChatPhrase(String text) {
    if (_shortRoomChatPhrases.contains(text)) {
      return true;
    }

    return text.length <= 5 &&
        _containsAny(text, ['안녕', '뭐해', 'ㅋㅋ', 'ㅎㅎ', '피곤', '배고', '고마', '잘자']);
  }
}
