import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../app/fanlive_globals.dart'
    show
        fanAffection,
        globalCoreFanProfiles,
        globalFanCount,
        globalFanMessages,
        globalLevel;
import '../main.dart' show fanButtonStyle;
import '../models/core_fan_profile.dart';
import '../services/ai_fan_service.dart';
import '../services/ai_pet_activity_service.dart';
import '../widgets/fanlive_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/pixel_pet_card.dart';
import 'achievements_screen.dart';
import 'fan_mailbox_screen.dart';
import 'records_list_screen.dart';
import 'save_slot_screen.dart';

class HomeScreen extends StatefulWidget {
  final String stageName;
  final String fandomName;
  final String style;

  const HomeScreen({
    super.key,
    required this.stageName,
    required this.fandomName,
    required this.style,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _typingComment = '생각중';

  final roomController = TextEditingController();
  final roomFocusNode = FocusNode();
  final speechRecognizer = stt.SpeechToText();
  final roomMessages = <String>[];

  bool _isSpeechInitialized = false;
  bool _isSpeechAvailable = false;
  bool _isListeningForSpeech = false;
  bool _speechTextCameFromRecognition = false;
  int _speechInputVersion = 0;
  int _roomResponseVersion = 0;
  String _speechInputPrefix = '';
  String _speechRecognitionBuffer = '';

  @override
  void initState() {
    super.initState();
    roomMessages.addAll(_initialRoomMessages());
  }

  @override
  void dispose() {
    if (_isListeningForSpeech) {
      unawaited(speechRecognizer.stop());
    }
    roomFocusNode.dispose();
    roomController.dispose();
    super.dispose();
  }

  void sendRoomMessage() async {
    final text = roomController.text.trim();

    if (text.isEmpty) {
      clearRoomInputField();
      roomFocusNode.requestFocus();
      return;
    }

    final wasListeningForSpeech = _isListeningForSpeech;
    _roomResponseVersion += 1;
    final responseVersion = _roomResponseVersion;
    final recentComments = _latestRoomMessages(10);
    final companionProfiles = _adoptedCompanions();
    final roomContext = _roomContext(companionProfiles);

    setState(() {
      roomMessages.add('나: $text');
      clearRoomInputField();
      _isListeningForSpeech = false;

      if (!roomMessages.contains(_typingComment)) {
        roomMessages.add(_typingComment);
      }
    });

    if (wasListeningForSpeech) {
      unawaited(stopSpeechInput());
    }

    roomFocusNode.requestFocus();

    final reaction = await AiFanService.reactToSpeech(
      text: text,
      stageName: widget.stageName,
      fandomName: '룸펫 하우스',
      themeTitle: '픽셀 룸',
      customConcept:
          '작은 픽셀 룸에서 룸펫과 나누는 생활 대화. This is not a livestream. These are room-pets, not fans, viewers, fandom, or chat audience. Use the actual room-pet name and follow its archetype strongly. Do not make cynical or mischievous types generically kind. $roomContext',
      conversationMode: 'room_chat',
      companions: companionProfiles,
      recentComments: recentComments,
      fanAffection: fanAffection,
      sessionMemory: roomContext,
    );

    if (!mounted || responseVersion != _roomResponseVersion) return;

    setState(() {
      roomMessages.remove(_typingComment);
    });

    final replies = _roomSafeReplies(reaction.comments);

    for (var index = 0; index < replies.length; index += 1) {
      await Future.delayed(_roomReplyDelay(index, replies[index]));

      if (!mounted || responseVersion != _roomResponseVersion) return;

      setState(() {
        roomMessages.add(replies[index]);
      });
    }

    roomFocusNode.requestFocus();
  }

  Future<void> toggleSpeechInput() async {
    if (_isListeningForSpeech) {
      await stopSpeechInput();
      roomFocusNode.requestFocus();
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

    if (roomController.text.trim().isNotEmpty &&
        !_speechTextCameFromRecognition) {
      _speechInputPrefix = roomController.text.trim();
      return _speechInputVersion;
    }

    _speechInputPrefix = '';
    roomController.clear();
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

    roomController.text = inputText;
    roomController.selection = TextSelection.collapsed(
      offset: roomController.text.length,
    );
    _speechTextCameFromRecognition = true;
    roomFocusNode.requestFocus();
  }

  Future<void> stopSpeechInput() async {
    try {
      await speechRecognizer.stop();
    } catch (_) {
      // Unsupported platforms can throw; text input remains available.
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
      roomFocusNode.requestFocus();
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

  void clearRoomInputField() {
    _speechInputVersion += 1;
    roomController.value = const TextEditingValue();
    resetSpeechInputState();
  }

  void showSpeechUnavailableMessage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('음성 인식을 사용할 수 없어요.')));
  }

  List<String> _latestRoomMessages(int count) {
    final chatContext = roomMessages
        .where((message) => message != _typingComment)
        .toList(growable: false);
    final startIndex = chatContext.length > count
        ? chatContext.length - count
        : 0;

    return chatContext.sublist(startIndex);
  }

  List<String> _roomSafeReplies(List<String> replies) {
    final companionNames = _adoptedCompanionNames();

    if (replies.isEmpty) {
      return ['${companionNames.first}: 지금 여기서 듣고 있어요. 조금만 더 말해줘요.'];
    }

    final safeReplies = <String>[];

    for (var index = 0; index < replies.length && index < 3; index += 1) {
      final sanitized = _sanitizeRoomReply(replies[index].trim());

      if (sanitized.isEmpty) continue;

      final maxReplies = companionNames.length.clamp(1, 3);

      if (safeReplies.length >= maxReplies) break;

      if (companionNames.any((name) => sanitized.startsWith('$name:'))) {
        safeReplies.add(sanitized);
      } else {
        final replyText = sanitized.replaceFirst(RegExp(r'^[^:]+:\s*'), '');
        safeReplies.add(
          '${companionNames[safeReplies.length % companionNames.length]}: $replyText',
        );
      }
    }

    return safeReplies.isNotEmpty
        ? safeReplies
        : ['${_adoptedCompanionNames().first}: 지금 여기서 듣고 있어요. 조금만 더 말해줘요.'];
  }

  String _sanitizeRoomReply(String reply) {
    return reply
        .replaceAll('시청자', '룸펫')
        .replaceAll('팬들', '룸펫들')
        .replaceAll('팬', '룸펫')
        .replaceAll('라방', '방 대화')
        .replaceAll('방송', '대화');
  }

  Duration _roomReplyDelay(int index, String reply) {
    final seed = reply.codeUnits.fold<int>(97 + index, (sum, code) {
      return (sum * 31 + code) & 0x7fffffff;
    });

    if (index == 0) {
      return Duration(milliseconds: 350 + seed % 351);
    }

    return Duration(milliseconds: 650 + seed % 651);
  }

  String _roomContext(List<CoreFanProfile> profiles) {
    final companionLines = profiles
        .map((profile) {
          return '${profile.name}=룸펫 성향:${profile.companionType}, 모습:${profile.appearanceType}, 기분:${profile.mood}, 친밀도:${profile.affection}, 서운함:${profile.neglect}, 활동:${profile.currentActivity}';
        })
        .join(' / ');

    return '현재 방 상태: $companionLines';
  }

  List<String> _initialRoomMessages() {
    final companions = _adoptedCompanions();

    if (companions.isEmpty) {
      return ['방: 아직 입주한 룸펫이 없어요.'];
    }

    return companions.map(_initialMessageFor).toList();
  }

  String _initialMessageFor(CoreFanProfile profile) {
    if (profile.companionType.contains('시니컬')) {
      return '${profile.name}: 방 상태는 그럭저럭입니다. 네 상태는 아직 판단 보류.';
    }

    if (profile.companionType.contains('장난')) {
      return '${profile.name}: 소파 점령 완료ㅋㅋ 오늘은 뭐 하고 놀까요?';
    }

    return '${profile.name}: 오늘도 여기 있었어요. 괜찮으면 먼저 말 걸어줘요.';
  }

  List<CoreFanProfile> _adoptedCompanions() {
    return globalCoreFanProfiles
        .where((profile) => profile.isAdopted)
        .toList(growable: false);
  }

  List<String> _adoptedCompanionNames() {
    final names = _adoptedCompanions().map((profile) => profile.name).toList();

    return names.isEmpty ? ['룸펫'] : names;
  }

  @override
  Widget build(BuildContext context) {
    final companionProfiles = AiPetActivityService.updateActivitiesForHomeView(
      globalCoreFanProfiles,
    );
    final adoptedNames = _adoptedCompanionNames().join(', ');

    return FanLiveBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  '내 픽셀 룸',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '입주한 룸펫이 오늘도 작은 방에서 자기 방식대로 지내고 있어요.',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '현재 룸펫: $adoptedNames',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 22),
                _buildRoomInfo(),
                const SizedBox(height: 20),
                SizedBox(
                  height: 215,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: companionProfiles.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return PixelPetCard(profile: companionProfiles[index]);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildRoomChat(),
                const SizedBox(height: 20),
                _buildGrowthCard(),
                const SizedBox(height: 20),
                _buildThoughtRecordCard(),
                const SizedBox(height: 24),
                _buildPrimaryActions(),
                const SizedBox(height: 12),
                _buildSecondaryActions(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomInfo() {
    final initial = widget.stageName.isNotEmpty
        ? widget.stageName[0].toUpperCase()
        : '?';

    return GlassCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFFFF4FB8),
            child: Text(
              initial,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.stageName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '방 이름: ${widget.fandomName} · 분위기: ${widget.style}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '룸펫 생활 Lv.$globalLevel · 생활 점수 $globalFanCount',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomChat() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '룸펫과 대화',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _adoptedCompanions().length == 1
                ? '말을 걸면 첫 룸펫이 지금 방 분위기에 맞춰 대답해요.'
                : '말을 걸면 입주한 룸펫들이 지금 방 분위기에 맞춰 대답해요.',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 230,
            child: ListView.builder(
              reverse: true,
              itemCount: roomMessages.length,
              itemBuilder: (context, index) {
                final message = roomMessages[roomMessages.length - 1 - index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(message),
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
                  controller: roomController,
                  focusNode: roomFocusNode,
                  style: const TextStyle(color: Colors.white),
                  onSubmitted: (_) => sendRoomMessage(),
                  onChanged: (_) {
                    _speechTextCameFromRecognition = false;
                    _speechRecognitionBuffer = '';
                  },
                  decoration: InputDecoration(
                    hintText: _isListeningForSpeech
                        ? '듣는 중... 말한 뒤 전송을 눌러 주세요'
                        : '룸펫에게 말하기...',
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
                style: fanButtonStyle(),
                onPressed: sendRoomMessage,
                child: const Text('전송'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCard() {
    final nextLevelRemainder = globalFanCount % 300;
    final remaining = nextLevelRemainder == 0 && globalFanCount > 0
        ? 300
        : 300 - nextLevelRemainder;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('관계 성장', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: nextLevelRemainder / 300,
            backgroundColor: Colors.white12,
            color: const Color(0xFFFF4FB8),
          ),
          const SizedBox(height: 10),
          Text('다음 레벨까지 생활 점수 $remaining'),
        ],
      ),
    );
  }

  Widget _buildThoughtRecordCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('최근 생각 기록', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 10),
          Text(
            globalFanMessages.isNotEmpty
                ? '“${globalFanMessages.first}”'
                : '“아직 남겨진 쪽지가 없어요. 먼저 말을 걸어볼까요?”',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActions() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: fanButtonStyle(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const SaveSlotScreen(mode: SaveSlotMode.save),
                  ),
                );
              },
              child: const Text('저장하기'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: _secondaryButtonStyle(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecordsListScreen()),
                );
              },
              child: const Text('생활 기록 보기'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryActions() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: _secondaryButtonStyle(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                );
              },
              child: const Text('기억 조각 보기'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: _secondaryButtonStyle(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FanMailboxScreen()),
                );
              },
              child: Text('룸펫 쪽지 (${globalFanMessages.length})'),
            ),
          ),
        ),
      ],
    );
  }

  ButtonStyle _secondaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white.withOpacity(0.12),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}
