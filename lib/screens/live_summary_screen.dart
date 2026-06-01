import 'package:flutter/material.dart';

import '../app/fanlive_globals.dart'
    show globalFandomName, globalStageName, globalStyle;
import '../main.dart' show fanButtonStyle;
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
    return FanLiveBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '오늘의 라방 종료',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 28),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '테마: $themeTitle',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 18),
                    Text('최고 시청자: $viewers명'),
                    Text('총 하트: $hearts개'),
                    Text('신규 팬: +${viewers ~/ 8}명'),

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
                      '방송 요약',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 6),
                    Text(summary),

                    const SizedBox(height: 18),
                    Text(
                      '🏆 획득 칭호: $earnedTitle',
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
                  child: const Text('방송 기록 보기'),
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
