import 'dart:async';

import 'package:flutter/material.dart';

import '../app/fanlive_globals.dart'
    show
        fanAffection,
        fanProfiles,
        globalBroadcastRecords,
        globalFanCount,
        globalFanMessages,
        globalLevel;
import '../models/broadcast_record.dart';
import '../services/broadcast_summary_service.dart';
import '../services/fan_mail_service.dart';
import '../services/fan_reaction_engine.dart';
import '../services/fanlive_storage.dart'
    show saveBroadcastRecords, saveFanAffection, saveFanMessages, saveFanState;
import '../widgets/floating_heart.dart';
import '../widgets/glass_mini.dart';
import 'live_summary_screen.dart';

class LiveRoomScreen extends StatefulWidget {
  final String stageName;
  final String fandomName;
  final String themeTitle;

  const LiveRoomScreen({
    super.key,
    required this.stageName,
    required this.fandomName,
    required this.themeTitle,
  });

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  int viewers = 124;
  int hearts = 0;
  int floatingHeartKey = 0;

  final speechController = TextEditingController();
  late Timer autoChatTimer;

  final comments = <String>[
    '하루: 드디어 왔다!',
    '별밤: 오늘 분위기 좋다',
    '민트: LIVE 켜줘서 고마워요',
    '모찌: 오늘 분위기 좋다',
  ];
  final userSpeechHistory = <String>[];

  @override
  void initState() {
    super.initState();
    startAutoChat();
  }

  @override
  void dispose() {
    autoChatTimer.cancel();
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

  void sendSpeech() {
    final text = speechController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      comments.add('나: $text');
      userSpeechHistory.add(text);

      final reaction = FanReactionEngine.reactToSpeech(
        text: text,
        stageName: widget.stageName,
        fandomName: widget.fandomName,
      );

      comments.addAll(reaction.comments);
      viewers += reaction.viewerDelta;
      hearts += reaction.heartDelta;

      speechController.clear();
    });
  }

  void startAutoChat() {
    autoChatTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final autoMessages = [
        '하루: 오늘 텐션 좋다',
        '별밤: 이 시간 라방 너무 좋음',
        '민트: 채팅 분위기 따뜻하다',
        '모찌: ${widget.stageName} 오늘 말투 좋네',
        '루나틱: ${widget.fandomName} 출석 완료',
        '새벽이: 조명 분위기 미쳤다',
        '하트요정: 하트 누르고 갑니다 💖',
      ];

      setState(() {
        comments.add(
          autoMessages[DateTime.now().millisecond % autoMessages.length],
        );

        if (viewers < 999) {
          viewers += DateTime.now().second % 3;
        }

        hearts += DateTime.now().second % 5;
      });
    });
  }

  void endLive() {
    final broadcastSummary = BroadcastSummaryService.calculate(
      userSpeechHistory: userSpeechHistory,
      hearts: hearts,
      viewers: viewers,
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
    );

    for (final message in fanMailMessages) {
      globalFanMessages.insert(0, message);
    }

    saveFanMessages();

    fanAffection['하루'] = (fanAffection['하루'] ?? 0) + 3;
    fanAffection['별밤'] = (fanAffection['별밤'] ?? 0) + 2;
    fanAffection['민트'] = (fanAffection['민트'] ?? 0) + 4;

    saveFanAffection();

    globalFanCount += (viewers ~/ 8);

    if (globalFanCount >= 300) {
      globalLevel = 2;
    }

    if (globalFanCount >= 800) {
      globalLevel = 3;
    }

    if (globalFanCount >= 1500) {
      globalLevel = 4;
    }

    if (globalFanCount >= 3000) {
      globalLevel = 5;
    }
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
                          style: const TextStyle(color: Colors.white),
                          onSubmitted: (_) => sendSpeech(),
                          decoration: InputDecoration(
                            hintText: '지금 말하기 테스트...',
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
