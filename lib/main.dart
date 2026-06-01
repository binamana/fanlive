
import 'package:flutter/material.dart';
import 'dart:async';
import 'models/broadcast_record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'screens/character_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/live_summary_screen.dart';
import 'widgets/fanlive_background.dart';
import 'widgets/glass_card.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadFanState();
  await loadBroadcastRecords();
  await loadFanMessages();
  await loadFanAffection();
  await loadCharacter();
  runApp(const FanLiveApp());
}

List<BroadcastRecord> globalBroadcastRecords = [];

int globalFanCount = 124;
int globalLevel = 1;

String? globalStageName;
String? globalFandomName;
String? globalStyle;
List<String> globalFanMessages = [];

Map<String, String> fanProfiles = {
  '하루': '감성적이고 걱정이 많은 장기팬',
  '별밤': '현실적인 조언을 잘하는 팬',
  '민트': '장난꾸러기이며 하트를 많이 보내는 팬',
};

Map<String, int> fanAffection = {
  '하루': 0,
  '별밤': 0,
  '민트': 0,
};

Future<void> saveFanState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('fanCount', globalFanCount);
  await prefs.setInt('level', globalLevel);
}

Future<void> loadFanState() async {
  final prefs = await SharedPreferences.getInstance();
  globalFanCount = prefs.getInt('fanCount') ?? 124;
  globalLevel = prefs.getInt('level') ?? 1;
}
Future<void> saveBroadcastRecords() async {
  final prefs = await SharedPreferences.getInstance();

  final recordsJson = globalBroadcastRecords
      .map((record) => jsonEncode(record.toJson()))
      .toList();

  await prefs.setStringList('broadcastRecords', recordsJson);
}
Future<void> saveFanMessages() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('fanMessages', globalFanMessages);
}

Future<void> loadFanMessages() async {
  final prefs = await SharedPreferences.getInstance();
  globalFanMessages = prefs.getStringList('fanMessages') ?? [];
}
Future<void> saveFanAffection() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt('affection_haru', fanAffection['하루'] ?? 0);
  await prefs.setInt('affection_byeolbam', fanAffection['별밤'] ?? 0);
  await prefs.setInt('affection_mint', fanAffection['민트'] ?? 0);
}

Future<void> loadFanAffection() async {
  final prefs = await SharedPreferences.getInstance();

  fanAffection['하루'] = prefs.getInt('affection_haru') ?? 0;
  fanAffection['별밤'] = prefs.getInt('affection_byeolbam') ?? 0;
  fanAffection['민트'] = prefs.getInt('affection_mint') ?? 0;
}

Future<void> loadBroadcastRecords() async {
  final prefs = await SharedPreferences.getInstance();

  final recordsJson = prefs.getStringList('broadcastRecords') ?? [];

  globalBroadcastRecords = recordsJson
      .map((recordString) {
        final json = jsonDecode(recordString);
        return BroadcastRecord.fromJson(json);
      })
      .toList();
}
Future<void> saveCharacter() async {
  final prefs = await SharedPreferences.getInstance();

  if (globalStageName != null) {
    await prefs.setString('stageName', globalStageName!);
  }

  if (globalFandomName != null) {
    await prefs.setString('fandomName', globalFandomName!);
  }

  if (globalStyle != null) {
    await prefs.setString('style', globalStyle!);
  }
}

Future<void> loadCharacter() async {
  final prefs = await SharedPreferences.getInstance();

  globalStageName = prefs.getString('stageName');
  globalFandomName = prefs.getString('fandomName');
  globalStyle = prefs.getString('style');
}

bool hasCharacter() {
  return globalStageName != null &&
      globalFandomName != null &&
      globalStyle != null;
}

class FanLiveApp extends StatelessWidget {
  const FanLiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FANLIVE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: hasCharacter()
    ? HomeScreen(
        stageName: globalStageName!,
        fandomName: globalFandomName!,
        style: globalStyle!,
      )
    : const CharacterSetupScreen(),
    );
  }
}

ButtonStyle fanButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFF4FB8),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  );
}
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

      if (text.contains('안녕') || text.contains('하이')) {
        comments.addAll([
          '하루: 왔다 왔다!',
          '별밤: 오늘도 반가워요 💖',
          '민트: ${widget.fandomName} 출석!',
        ]);
        viewers += 8;
        hearts += 20;
      } else if (text.contains('힘들') ||
          text.contains('피곤') ||
          text.contains('속상')) {
        comments.addAll([
          '새벽이: 무슨 일 있었어요ㅠ',
          '모찌: 괜찮아요? 무리하지 말아요',
          '하루: 우리 여기 있어요',
          '별밤: 오늘 와줘서 고마워요',
        ]);
        viewers += 14;
        hearts += 55;
      } else if (text.contains('고마워') || text.contains('감사')) {
        comments.addAll([
          '하트요정: 우리가 더 고마워요',
          '민트: 이래서 못 떠남 진짜',
          '별밤: 평생 응원할게요',
        ]);
        viewers += 12;
        hearts += 70;
      } else {
        comments.addAll([
          '첫방문자: 오늘 분위기 좋다',
          '민트: 방금 말투 귀여움ㅋㅋ',
          '별밤: ${widget.stageName} 라방 은근 중독됨',
        ]);
        viewers += 6;
        hearts += 18;
      }

      speechController.clear();
    });
  }

  void startAutoChat() {
    autoChatTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
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
      },
    );
  }

void endLive() {
  String bestMoment = '첫 인사를 나눈 순간';
  String summary = '팬들과 편안하게 소통한 라방이었어요.';
  String earnedTitle = '첫 데뷔';

  for (final speech in userSpeechHistory) {
    if (speech.contains('힘들') ||
        speech.contains('피곤') ||
        speech.contains('속상')) {
      bestMoment = speech;
      summary = '오늘은 솔직한 감정 이야기를 나누며 팬들과 따뜻한 시간을 보냈어요.';
      earnedTitle = '감성 방송러';
      break;
    }

    if (speech.contains('노래') ||
        speech.contains('곡') ||
        speech.contains('작업') ||
        speech.contains('앨범')) {
      bestMoment = speech;
      summary = '오늘은 음악과 작업 이야기를 중심으로 팬들과 소통했어요.';
      earnedTitle = '작업 토크 장인';
    }

    if (speech.contains('고마워') || speech.contains('감사')) {
      bestMoment = speech;
      summary = '팬들에게 고마운 마음을 전하며 분위기가 따뜻해졌어요.';
      earnedTitle = '팬서비스 요정';
    }
  }

  if (userSpeechHistory.isNotEmpty && bestMoment == '첫 인사를 나눈 순간') {
    bestMoment = userSpeechHistory.last;
  }
  if (hearts >= 100) {
  earnedTitle = '하트 폭격';
  }

if (viewers >= 300) {
  earnedTitle = '라이징 스타';
}

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
if (summary.contains('감정') || earnedTitle == '감성 방송러') {
  globalFanMessages.insert(
    0,
    '하루 (${fanProfiles['하루']}): 오늘은 조금 걱정됐어요. 그래도 와줘서 고마워요 💖',
  );

  globalFanMessages.insert(
    0,
    '별밤 (${fanProfiles['별밤']}): 무리하지 말고 쉬는 시간도 꼭 챙겨요.',
  );

  globalFanMessages.insert(
    0,
    '민트 (${fanProfiles['민트']}): 일단 하트 잔뜩 보내고 갈게요 💖💖💖',
  );
} else if (summary.contains('음악') || earnedTitle == '작업 토크 장인') {
  globalFanMessages.insert(
    0,
    '하루 (${fanProfiles['하루']}): 오늘 작업 이야기 너무 좋았어요. 다음에 또 들려줘요!',
  );

  globalFanMessages.insert(
    0,
    '별밤 (${fanProfiles['별밤']}): 새 곡 이야기 들으니까 진짜 기대돼요.',
  );

  globalFanMessages.insert(
    0,
    '민트 (${fanProfiles['민트']}): 스포 더 주세요... 아니 조금만요 😆',
  );
} else if (summary.contains('고마운') || earnedTitle == '팬서비스 요정') {
  globalFanMessages.insert(
    0,
    '하루 (${fanProfiles['하루']}): 오늘 고맙다고 해준 거 진짜 감동이었어요.',
  );

  globalFanMessages.insert(
    0,
    '별밤 (${fanProfiles['별밤']}): 우리가 더 고마워요. 오래 봐요.',
  );

  globalFanMessages.insert(
    0,
    '민트 (${fanProfiles['민트']}): 팬서비스 미쳤다... 오늘 못 잊음 😆',
  );
} else {
  globalFanMessages.insert(
    0,
    '하루 (${fanProfiles['하루']}): 오늘 방송 와줘서 고마워요 💖',
  );

  globalFanMessages.insert(
    0,
    '별밤 (${fanProfiles['별밤']}): 다음 방송도 기다릴게요!',
  );

  globalFanMessages.insert(
    0,
    '민트 (${fanProfiles['민트']}): 오늘 이야기 재밌었어요 😆',
  );
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
class GlassMini extends StatelessWidget {
  final Widget child;

  const GlassMini({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: child,
    );
  }
}
class FloatingHeart extends StatefulWidget {
  const FloatingHeart({super.key});

  @override
  State<FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<FloatingHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> moveUp;
  late Animation<double> fadeOut;
  late Animation<double> scaleUp;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    moveUp = Tween<double>(begin: 0, end: -90).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );

    scaleUp = Tween<double>(begin: 0.7, end: 1.35).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticOut),
    );

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, moveUp.value),
          child: Opacity(
            opacity: fadeOut.value,
            child: Transform.scale(
              scale: scaleUp.value,
              child: const Text(
                '💖',
                style: TextStyle(fontSize: 42),
              ),
            ),
          ),
        );
      },
    );
  }
}
class FanMailboxScreen extends StatelessWidget {
  const FanMailboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FanLiveBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '💌 팬 우편함',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '도착한 팬 메시지 ${globalFanMessages.length}개',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
GlassCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        '팬 호감도',
        style: TextStyle(color: Colors.white54),
      ),
      const SizedBox(height: 10),
      Text('하루 ❤️ ${fanAffection['하루'] ?? 0}'),
      Text('별밤 ❤️ ${fanAffection['별밤'] ?? 0}'),
      Text('민트 ❤️ ${fanAffection['민트'] ?? 0}'),
    ],
  ),
),
              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  itemCount: globalFanMessages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        child: Text(
                          globalFanMessages[index],
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: fanButtonStyle(),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('돌아가기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
