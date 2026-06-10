import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../app/fanlive_globals.dart'
    show
        fanAffection,
        fanProfiles,
        globalBroadcastRecords,
        globalCoreFanProfiles,
        globalFanCount,
        globalFanMessages,
        globalLevel;
import '../models/broadcast_record.dart';
import '../services/ai_fan_service.dart';
import '../services/broadcast_summary_service.dart';
import '../services/core_fan_service.dart';
import '../services/fan_mail_service.dart';
import '../services/fan_growth_service.dart';
import '../services/fanlive_storage.dart'
    show
        saveBroadcastRecords,
        saveCoreFanProfiles,
        saveFanAffection,
        saveFanMessages,
        saveFanState;
import '../services/live_session_memory_service.dart';
import '../services/theme_comment_service.dart';
import '../widgets/floating_heart.dart';
import '../widgets/glass_mini.dart';
import 'live_summary_screen.dart';

class LiveRoomScreen extends StatefulWidget {
  final String stageName;
  final String fandomName;
  final String themeTitle;
  final String? customConcept;

  const LiveRoomScreen({
    super.key,
    required this.stageName,
    required this.fandomName,
    required this.themeTitle,
    this.customConcept,
  });

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  static const _typingComment = '생각중';

  int viewers = 124;
  int hearts = 0;
  int floatingHeartKey = 0;
  int _pendingAiResponses = 0;
  int _commentPacingVersion = 0;

  final speechController = TextEditingController();
  final speechFocusNode = FocusNode();
  final speechRecognizer = stt.SpeechToText();

  final comments = <String>[];
  final userSpeechHistory = <String>[];
  final _sessionMemory = LiveSessionMemoryService();
  bool _isSpeechInitialized = false;
  bool _isSpeechAvailable = false;
  bool _isListeningForSpeech = false;
  bool _speechTextCameFromRecognition = false;
  int _speechInputVersion = 0;
  String _speechInputPrefix = '';
  String _speechRecognitionBuffer = '';

  @override
  void initState() {
    super.initState();
    final initialPacingVersion = _commentPacingVersion;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addCommentsWithPacing(
        ThemeCommentService.initialComments(widget.themeTitle),
        version: initialPacingVersion,
      );
    });
  }

  @override
  void dispose() {
    if (_isListeningForSpeech) {
      unawaited(speechRecognizer.stop());
    }
    _sessionMemory.reset();
    speechFocusNode.dispose();
    speechController.dispose();
    super.dispose();
  }

  void addHeart() {
    setState(() {
      hearts += 1;
      floatingHeartKey += 1;

      if (hearts % 5 == 0) viewers += 1;
      comments.add('하트요정: 하트 눌렀어요 💖');
    });
  }

  void sendSpeech() async {
    final text = speechController.text.trim();
    if (text.isEmpty) {
      clearSpeechInputField();
      speechFocusNode.requestFocus();
      return;
    }

    final wasListeningForSpeech = _isListeningForSpeech;
    _commentPacingVersion += 1;
    final responsePacingVersion = _commentPacingVersion;
    final recentComments = _latestComments(10);
    _sessionMemory.updateFromUserSpeech(text);

    setState(() {
      comments.add('나: $text');
      userSpeechHistory.add(text);
      clearSpeechInputField();
      _isListeningForSpeech = false;
      _pendingAiResponses += 1;
      if (!comments.contains(_typingComment)) {
        comments.add(_typingComment);
      }
    });

    if (wasListeningForSpeech) {
      unawaited(stopSpeechInput());
    }

    speechFocusNode.requestFocus();

    final reaction = await AiFanService.reactToSpeech(
      text: text,
      stageName: widget.stageName,
      fandomName: widget.fandomName,
      themeTitle: widget.themeTitle,
      customConcept: widget.customConcept,
      recentComments: recentComments,
      fanAffection: fanAffection,
      sessionMemory: _sessionMemory.memory,
    );

    if (!mounted) return;

    setState(() {
      viewers += reaction.viewerDelta;
      hearts += reaction.heartDelta;
      if (_pendingAiResponses > 0) {
        _pendingAiResponses -= 1;
      }
      if (_pendingAiResponses == 0) {
        comments.remove(_typingComment);
      }
    });

    speechFocusNode.requestFocus();
    final displayedAiComments = await addCommentsWithPacing(
      reaction.comments,
      version: responsePacingVersion,
      targetedFan: _detectTargetedFan(text),
    );
    if (!displayedAiComments) return;
  }

  Future<void> toggleSpeechInput() async {
    if (_isListeningForSpeech) {
      await stopSpeechInput();
      speechFocusNode.requestFocus();
      return;
    }

    final available = await ensureSpeechInitialized();

    if (!mounted) return;

    if (!available) {
      resetSpeechInputState();
      showSpeechUnavailableMessage();
      return;
    }

    final speechInputVersion = prepareSpeechInputSession();

    setState(() {
      _isListeningForSpeech = true;
    });

    try {
      await speechRecognizer.listen(
        localeId: 'ko_KR',
        partialResults: true,
        onResult: (result) {
          updateSpeechInputFromResult(
            result.recognizedWords,
            speechInputVersion,
          );

          if (result.finalResult && mounted) {
            setState(() {
              _isListeningForSpeech = false;
            });
          }
        },
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isListeningForSpeech = false;
      });
      resetSpeechInputState();
      showSpeechUnavailableMessage();
    }
  }

  Future<bool> ensureSpeechInitialized() async {
    if (_isSpeechInitialized) {
      return _isSpeechAvailable;
    }

    final available = await speechRecognizer.initialize(
          onStatus: handleSpeechStatus,
          onError: handleSpeechError,
        );

    if (!mounted) return false;

    _isSpeechInitialized = available;
    _isSpeechAvailable = available;
    return available;
  }

  int prepareSpeechInputSession() {
    _speechInputVersion += 1;
    _speechRecognitionBuffer = '';

    if (speechController.text.trim().isNotEmpty &&
        !_speechTextCameFromRecognition) {
      _speechInputPrefix = speechController.text.trim();
      return _speechInputVersion;
    }

    _speechInputPrefix = '';
    speechController.clear();
    _speechTextCameFromRecognition = false;
    return _speechInputVersion;
  }

  void updateSpeechInputFromResult(String recognizedWords, int inputVersion) {
    if (inputVersion != _speechInputVersion) return;

    final recognizedText = recognizedWords.trim();

    if (!mounted || recognizedText.isEmpty) return;

    _speechRecognitionBuffer = recognizedText;
    final inputText = [
      if (_speechInputPrefix.isNotEmpty) _speechInputPrefix,
      _speechRecognitionBuffer,
    ].join(' ').trim();

    speechController.text = inputText;
    speechController.selection = TextSelection.collapsed(
      offset: speechController.text.length,
    );
    _speechTextCameFromRecognition = true;
    speechFocusNode.requestFocus();
  }

  Future<void> stopSpeechInput() async {
    try {
      await speechRecognizer.stop();
    } catch (_) {
      // Speech plugins can throw on unsupported platforms; the UI already falls
      // back to text input.
    }

    if (!mounted) return;

    setState(() {
      _isListeningForSpeech = false;
    });
  }

  void handleSpeechStatus(String status) {
    if (!mounted) return;

    if (status == 'done' || status == 'notListening') {
      setState(() {
        _isListeningForSpeech = false;
      });
      speechFocusNode.requestFocus();
    }
  }

  void handleSpeechError(dynamic error) {
    if (!mounted) return;

    setState(() {
      _isListeningForSpeech = false;
    });
    resetSpeechInputState();
    showSpeechUnavailableMessage();
  }

  void resetSpeechInputState() {
    _speechInputPrefix = '';
    _speechRecognitionBuffer = '';
    _speechTextCameFromRecognition = false;
  }

  void clearSpeechInputField() {
    _speechInputVersion += 1;
    speechController.value = const TextEditingValue();
    resetSpeechInputState();
  }

  void showSpeechUnavailableMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('음성 인식을 사용할 수 없어요.')),
    );
  }

  List<String> _latestComments(int count) {
    final chatContext = comments
        .where((comment) => comment != _typingComment)
        .toList(growable: false);
    final startIndex = chatContext.length > count
        ? chatContext.length - count
        : 0;
    return chatContext.sublist(startIndex);
  }

  Future<bool> addCommentsWithPacing(
    List<String> newComments, {
    int? version,
    String? targetedFan,
  }) async {
    final commentsToDisplay = _orderCommentsForDisplay(
      newComments,
      targetedFan,
    );

    for (var index = 0; index < commentsToDisplay.length; index += 1) {
      if (_isCommentPacingCancelled(version)) {
        return false;
      }

      await Future.delayed(
        _commentPacingDelay(
          index: index,
          comment: commentsToDisplay[index],
          targetedFan: targetedFan,
        ),
      );

      if (!mounted) return false;

      if (_isCommentPacingCancelled(version)) {
        return false;
      }

      setState(() {
        comments.add(commentsToDisplay[index]);
      });
    }

    return true;
  }

  List<String> _orderCommentsForDisplay(
    List<String> newComments,
    String? targetedFan,
  ) {
    if (targetedFan == null) {
      return List<String>.from(newComments);
    }

    final targetPrefix = '$targetedFan:';
    final targetIndex = newComments.indexWhere(
      (comment) => comment.trimLeft().startsWith(targetPrefix),
    );

    if (targetIndex <= 0) {
      return List<String>.from(newComments);
    }

    return [
      newComments[targetIndex],
      for (var index = 0; index < newComments.length; index += 1)
        if (index != targetIndex) newComments[index],
    ];
  }

  Duration _commentPacingDelay({
    required int index,
    required String comment,
    required String? targetedFan,
  }) {
    final seed = _commentPacingSeed(comment, index, targetedFan);

    if (index == 0) {
      return Duration(milliseconds: 250 + seed % 451);
    }

    if (targetedFan != null) {
      if (index == 1) {
        return Duration(milliseconds: 1000 + seed % 401);
      }

      return Duration(milliseconds: 1250 + seed % 551);
    }

    if (index == 1) {
      return Duration(milliseconds: 700 + seed % 701);
    }

    return Duration(milliseconds: 900 + seed % 901);
  }

  int _commentPacingSeed(String comment, int index, String? targetedFan) {
    var seed = 97 * (index + 1);

    for (final codeUnit in comment.codeUnits) {
      seed = (seed * 31 + codeUnit) & 0x7fffffff;
    }

    for (final codeUnit in (targetedFan ?? '').codeUnits) {
      seed = (seed * 31 + codeUnit) & 0x7fffffff;
    }

    return seed;
  }

  String? _detectTargetedFan(String text) {
    final matchedFans = <String>[
      if (text.contains('하루')) '하루',
      if (text.contains('별밤')) '별밤',
      if (text.contains('민트')) '민트',
    ];

    return matchedFans.length == 1 ? matchedFans.first : null;
  }

  bool _isCommentPacingCancelled(int? version) {
    return version != null && version != _commentPacingVersion;
  }

  void endLive() {
    final sessionMemory = _sessionMemory.memory;
    final conversationDigest = _sessionMemory.conversationDigest;
    final broadcastSummary = BroadcastSummaryService.calculate(
      userSpeechHistory: userSpeechHistory,
      hearts: hearts,
      viewers: viewers,
      sessionMemory: sessionMemory,
      conversationDigest: conversationDigest,
    );
    final bestMoment = broadcastSummary.bestMoment;
    final summary = broadcastSummary.summary;
    final earnedTitle = broadcastSummary.earnedTitle;

    globalBroadcastRecords.insert(
      0,
      BroadcastRecord(
        themeTitle: widget.themeTitle,
        viewers: viewers,
        hearts: hearts,
        bestMoment: bestMoment,
        summary: summary,
        earnedTitle: earnedTitle,
        createdAt: DateTime.now(),
      ),
    );

    saveBroadcastRecords();
    final fanMailMessages = FanMailService.generateMessages(
      summary: summary,
      earnedTitle: earnedTitle,
      fanProfiles: fanProfiles,
      sessionMemory: sessionMemory,
      conversationDigest: conversationDigest,
    );

    for (final message in fanMailMessages) {
      globalFanMessages.insert(0, message);
    }

    FanGrowthService.applyAffectionGrowth(fanAffection);
    CoreFanService.syncFromLegacyFanAffection(
      globalCoreFanProfiles,
      fanAffection,
    );
    CoreFanService.applyThemeAffinity(
      globalCoreFanProfiles,
      widget.themeTitle,
    );
    final relationshipEvents = CoreFanService.generateRelationshipEvents(
      globalCoreFanProfiles,
      widget.themeTitle,
    );
    CoreFanService.syncToLegacyFanAffection(
      globalCoreFanProfiles,
      fanAffection,
    );

    for (final message in relationshipEvents.reversed) {
      globalFanMessages.insert(0, message);
    }

    saveCoreFanProfiles();
    saveFanAffection();
    saveFanMessages();

    globalFanCount += FanGrowthService.calculateNewFans(viewers);

    globalLevel = FanGrowthService.calculateLevel(globalFanCount);
    saveFanState();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LiveSummaryScreen(
          themeTitle: widget.themeTitle,
          viewers: viewers,
          hearts: hearts,
          bestMoment: bestMoment,
          summary: summary,
          earnedTitle: earnedTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09000F),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF24002F),
                      Color(0xFF09000F),
                      Color(0xFF341257),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '카메라 프리뷰 영역',
                    style: TextStyle(color: Colors.white38, fontSize: 22),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFFF4FB8),
                    child: Text(widget.stageName[0].toUpperCase()),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GlassMini(
                      child: Text(
                        '${widget.stageName} · ${widget.fandomName}\n👥 $viewers명',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 86,
              bottom: 92,
              child: SizedBox(
                height: 210,
                child: ListView.builder(
                  reverse: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[comments.length - 1 - index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(comment),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              right: 18,
              bottom: 92,
              child: Column(
                children: [
                  IconButton(
                    onPressed: addHeart,
                    iconSize: 42,
                    icon: const Icon(Icons.favorite, color: Color(0xFFFF4FB8)),
                  ),
                  Text('$hearts'),
                ],
              ),
            ),
            Positioned(
              right: 24,
              bottom: 150,
              child: FloatingHeart(key: ValueKey(floatingHeartKey)),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 22,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: speechController,
                          focusNode: speechFocusNode,
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (_) => sendSpeech(),
                          onChanged: (_) {
                            _speechTextCameFromRecognition = false;
                            _speechRecognitionBuffer = '';
                          },
                          decoration: InputDecoration(
                            hintText: _isListeningForSpeech
                                ? '듣는 중... 말한 뒤 전송을 눌러 주세요'
                                : '지금 말하기 테스트...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.32),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: _isListeningForSpeech ? '음성 입력 중지' : '음성 입력',
                        onPressed: toggleSpeechInput,
                        icon: Icon(
                          _isListeningForSpeech ? Icons.mic : Icons.mic_none,
                          color: _isListeningForSpeech
                              ? const Color(0xFFFF4FB8)
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4FB8),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: sendSpeech,
                        child: const Text('전송'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: endLive,
                        child: const Text('종료'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
