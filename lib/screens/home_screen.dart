import 'package:flutter/material.dart';

import '../app/fanlive_globals.dart'
    show globalCoreFanProfiles, globalFanCount, globalFanMessages, globalLevel;
import '../main.dart' show fanButtonStyle;
import '../services/ai_pet_activity_service.dart';
import '../widgets/fanlive_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/pixel_pet_card.dart';
import 'achievements_screen.dart';
import 'fan_mailbox_screen.dart';
import 'records_list_screen.dart';
import 'save_slot_screen.dart';
import 'theme_select_screen.dart';

class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final companionProfiles = AiPetActivityService.updateActivitiesForHomeView(
      globalCoreFanProfiles,
    );

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
                  'FANLIVE',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 28),
                GlassCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: const Color(0xFFFF4FB8),
                        child: Text(
                          stageName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stageName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$fandomName · $style',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '팬 ${globalFanCount}명 · Lv.$globalLevel',
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'AI 펫 하우스',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  '하루, 별밤, 민트가 각자 시간을 보내고 있어요.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 205,
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
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '팬덤 성장',
                        style: TextStyle(color: Colors.white54),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: (globalFanCount % 300) / 300,
                        backgroundColor: Colors.white12,
                        color: const Color(0xFFFF4FB8),
                      ),
                      const SizedBox(height: 10),
                      Text('다음 레벨까지 ${300 - (globalFanCount % 300)} 팬'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '오늘의 팬 메시지',
                        style: TextStyle(color: Colors.white54),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        globalFanMessages.isNotEmpty
                            ? '“${globalFanMessages.first}”'
                            : '“오늘도 라방 켜줄 거죠?”',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: fanButtonStyle(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ThemeSelectScreen(
                            stageName: stageName,
                            fandomName: fandomName,
                            style: style,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      '방송 시작하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.12),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SaveSlotScreen(
                                  mode: SaveSlotMode.save,
                                ),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.12),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RecordsListScreen(),
                              ),
                            );
                          },
                          child: const Text('방송 기록 보기'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.12),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AchievementsScreen(),
                        ),
                      );
                    },
                    child: const Text('업적 / 칭호 보기'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.12),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FanMailboxScreen(),
                        ),
                      );
                    },
                    child: Text('💌 팬 우편함 (${globalFanMessages.length})'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
