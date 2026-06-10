import 'package:flutter/material.dart';

import '../app/fanlive_globals.dart'
    show globalFandomName, globalStageName, globalStyle;
import '../main.dart' show fanButtonStyle;
import '../services/memory_title_service.dart';
import '../widgets/fanlive_background.dart';
import '../widgets/glass_card.dart';
import 'home_screen.dart';
import 'records_screen.dart';

class LiveSummaryScreen extends StatelessWidget {
  final String themeTitle;
  final int viewers;
  final int hearts;
  final String bestMoment;
  final String summary;
  final String earnedTitle;

  const LiveSummaryScreen({
    super.key,
    required this.themeTitle,
    required this.viewers,
    required this.hearts,
    required this.bestMoment,
    required this.summary,
    required this.earnedTitle,
  });

  @override
  Widget build(BuildContext context) {
    final displayTheme = MemoryTitleService.displayRecordTheme(themeTitle);
    final displaySummary = MemoryTitleService.displaySummary(summary);
    final displayTitle = MemoryTitleService.displayTitle(earnedTitle);

    return FanLiveBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '오늘의 방 기록',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 28),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '기억 배경: $displayTheme',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 18),
                    Text('방 반응: $viewers'),
                    Text('감정 에너지: $hearts'),
                    Text('관계 변화: +${viewers ~/ 8}'),

                    const SizedBox(height: 18),
                    const Text(
                      '오늘의 순간',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '“$bestMoment”',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      '생활 요약',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 6),
                    Text(displaySummary),

                    const SizedBox(height: 18),
                    Text(
                      '기억 칭호: $displayTitle',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
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
                        builder: (_) => RecordsScreen(
                          themeTitle: themeTitle,
                          viewers: viewers,
                          hearts: hearts,
                          bestMoment: bestMoment,
                          summary: summary,
                        ),
                      ),
                    );
                  },
                  child: const Text('생활 기록 보기'),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: fanButtonStyle(),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                          stageName: globalStageName!,
                          fandomName: globalFandomName!,
                          style: globalStyle!,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('홈으로 돌아가기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
