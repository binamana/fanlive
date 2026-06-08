import 'dart:async';

import 'package:flutter/material.dart';

import '../app/fanlive_globals.dart'
    show fanAffection, globalCoreFanProfiles, globalFanMessages;
import '../main.dart' show fanButtonStyle;
import '../models/core_fan_profile.dart';
import '../services/ai_fan_service.dart';
import '../services/core_fan_service.dart';
import '../services/fanlive_storage.dart'
    show saveCoreFanProfiles, saveFanAffection, saveFanMessages;
import '../widgets/fanlive_background.dart';
import '../widgets/glass_card.dart';

class OneOnOneLiveScreen extends StatefulWidget {
  final CoreFanProfile fanProfile;
  final String stageName;
  final String fandomName;

  const OneOnOneLiveScreen({
    super.key,
    required this.fanProfile,
    required this.stageName,
    required this.fandomName,
  });

  @override
  State<OneOnOneLiveScreen> createState() => _OneOnOneLiveScreenState();
}

class _OneOnOneLiveScreenState extends State<OneOnOneLiveScreen> {
  static const _typingComment = '팬이 입력 중...';

  final messageController = TextEditingController();
  final messageFocusNode = FocusNode();
  final comments = <String>[];

  int _responseVersion = 0;
  int _userMessageCount = 0;
  String? _lastUserMessage;
  bool _hasEnded = false;

  @override
  void initState() {
    super.initState();
    comments.add('${widget.fanProfile.name}: ${initialFanMessage()}');
  }

  @override
  void dispose() {
    messageFocusNode.dispose();
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty) {
      messageFocusNode.requestFocus();
      return;
    }

    _responseVersion += 1;
    final responseVersion = _responseVersion;
    final recentComments = latestComments(10);

    setState(() {
      comments.add('나: $text');
      _userMessageCount += 1;
      _lastUserMessage = text;
      messageController.clear();

      if (!comments.contains(_typingComment)) {
        comments.add(_typingComment);
      }
    });

    messageFocusNode.requestFocus();

    final reaction = await AiFanService.reactToSpeech(
      text: text,
      stageName: widget.stageName,
      fandomName: widget.fandomName,
      themeTitle: '1:1 라방',
      customConcept: '${fanNameWithParticle(widget.fanProfile.name)} 1:1 라방',
      recentComments: recentComments,
      fanAffection: {widget.fanProfile.name: widget.fanProfile.affection},
      conversationMode: 'one_on_one',
      targetFanName: widget.fanProfile.name,
      targetFanPersonality: widget.fanProfile.personality,
      targetFanMood: widget.fanProfile.mood,
      targetFanAffection: widget.fanProfile.affection,
      targetFanNeglect: widget.fanProfile.neglect,
    );

    if (!mounted || responseVersion != _responseVersion) return;

    setState(() {
      comments.remove(_typingComment);
    });

    final responseComments = selectedFanComments(reaction.comments);

    for (var index = 0; index < responseComments.length; index += 1) {
      await Future.delayed(oneOnOneResponseDelay(text, index));

      if (!mounted || responseVersion != _responseVersion) return;

      setState(() {
        comments.add(responseComments[index]);
      });
    }

    messageFocusNode.requestFocus();
  }

  List<String> latestComments(int count) {
    final chatContext = comments
        .where((comment) => comment != _typingComment)
        .toList(growable: false);
    final startIndex = chatContext.length > count
        ? chatContext.length - count
        : 0;

    return chatContext.sublist(startIndex);
  }

  List<String> selectedFanComments(List<String> responseComments) {
    final fanPrefix = '${widget.fanProfile.name}:';
    final selectedComments = <String>[];

    for (final comment in responseComments) {
      if (comment.trimLeft().startsWith(fanPrefix)) {
        selectedComments.add(comment);
      }
    }

    if (selectedComments.isNotEmpty) {
      return selectedComments;
    }

    if (responseComments.isNotEmpty) {
      final responseText = responseComments.first.replaceFirst(
        RegExp(r'^[^:]+:\s*'),
        '',
      );

      return ['$fanPrefix $responseText'];
    }

    return ['$fanPrefix 지금 천천히 듣고 있어요.'];
  }

  Future<void> endOneOnOneLive() async {
    if (_hasEnded) {
      return;
    }

    _hasEnded = true;
    _responseVersion += 1;

    if (_userMessageCount > 0 && _lastUserMessage != null) {
      final profile = CoreFanService.findByName(
            globalCoreFanProfiles,
            widget.fanProfile.name,
          ) ??
          widget.fanProfile;
      final previousMood = profile.mood;
      final previousNeglect = profile.neglect;

      CoreFanService.applyOneOnOneLiveResult(
        profile,
        userMessageCount: _userMessageCount,
      );
      widget.fanProfile.affection = profile.affection;
      widget.fanProfile.mood = profile.mood;
      widget.fanProfile.neglect = profile.neglect;
      fanAffection[profile.name] = profile.affection;

      final followUpMessage = CoreFanService.generateOneOnOneFollowUpMessage(
        profile,
        userMessageCount: _userMessageCount,
        previousMood: previousMood,
        previousNeglect: previousNeglect,
      );

      if (followUpMessage != null) {
        globalFanMessages.insert(0, followUpMessage);
        await saveFanMessages();
      }

      await saveCoreFanProfiles();
      await saveFanAffection();
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  Duration oneOnOneResponseDelay(String text, int index) {
    final seed = text.codeUnits.fold<int>(
      widget.fanProfile.name.codeUnits.fold<int>(0, (sum, code) => sum + code),
      (sum, code) => sum + code,
    );

    if (index == 0) {
      return Duration(milliseconds: 450 + seed % 451);
    }

    return Duration(milliseconds: 650 + (seed + index * 97) % 551);
  }

  String initialFanMessage() {
    switch (widget.fanProfile.name) {
      case '하루':
        return '오늘은 둘이서 천천히 얘기해요. 무슨 말부터 듣고 싶어요?';
      case '별밤':
        return '1:1이면 조금 더 솔직하게 얘기해도 괜찮을 것 같아요.';
      case '민트':
        return '오 1:1 라방 입장 완료ㅋㅋ 오늘 뭐부터 얘기할까요? 💖';
      default:
        return '오늘은 둘이서 얘기해요.';
    }
  }

  String fanNameWithParticle(String fanName) {
    return fanName == '별밤' ? '$fanName과' : '$fanName와';
  }

  @override
  Widget build(BuildContext context) {
    return FanLiveBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${fanNameWithParticle(widget.fanProfile.name)} 1:1 라방',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Text(
                  '기분: ${widget.fanProfile.mood} · 호감도: ${widget.fanProfile.affection} · 서운함: ${widget.fanProfile.neglect}',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[comments.length - 1 - index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        child: Text(comment),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      focusNode: messageFocusNode,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: '${widget.fanProfile.name}에게 말하기...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.32),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: fanButtonStyle(),
                    onPressed: sendMessage,
                    child: const Text('전송'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: fanButtonStyle(),
                  onPressed: endOneOnOneLive,
                  child: const Text('끝내기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
