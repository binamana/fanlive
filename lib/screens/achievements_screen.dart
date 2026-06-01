import 'package:flutter/material.dart';

import '../app/fanlive_globals.dart' show globalBroadcastRecords;
import '../main.dart' show fanButtonStyle;
import '../widgets/fanlive_background.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final earnedTitles = globalBroadcastRecords
        .map((record) => record.earnedTitle)
        .toSet()
        .toList();

    final allTitles = [
      '첫 데뷔',
      '감성 방송러',
      '작업 토크 장인',
      '팬서비스 요정',
      '하트 폭격',
      '라이징 스타',
    ];

    return FanLiveBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '업적 / 칭호',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '라방을 하며 얻은 칭호들이 여기에 모여요.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: allTitles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final title = allTitles[index];
                    final unlocked = earnedTitles.contains(title);

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: unlocked
                            ? Colors.white.withOpacity(0.10)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: unlocked
                              ? const Color(0xFFFF4FB8).withOpacity(0.7)
                              : Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            unlocked ? '🏆' : '🔒',
                            style: const TextStyle(fontSize: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: unlocked ? Colors.white : Colors.white38,
                              ),
                            ),
                          ),
                        ],
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
                  onPressed: () => Navigator.pop(context),
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
