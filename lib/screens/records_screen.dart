import 'package:flutter/material.dart';

import '../main.dart' show fanButtonStyle;
import '../services/memory_title_service.dart';
import '../widgets/fanlive_background.dart';
import '../widgets/glass_card.dart';

class RecordsScreen extends StatelessWidget {
  final String themeTitle;
  final int viewers;
  final int hearts;
  final String bestMoment;
  final String summary;

  const RecordsScreen({
    super.key,
    required this.themeTitle,
    required this.viewers,
    required this.hearts,
    required this.bestMoment,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final displayTheme = MemoryTitleService.displayRecordTheme(themeTitle);
    final displaySummary = MemoryTitleService.displaySummary(summary);

    return FanLiveBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '하루 기록',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '픽셀 룸에서 남은 생활 기억이 쌓여요.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 28),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${now.year}.${now.month}.${now.day}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displayTheme,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('방 반응: $viewers'),
                    Text('감정 에너지: $hearts'),
                    Text('관계 변화: +${viewers ~/ 8}'),
                    const SizedBox(height: 16),
                    const Text(
                      '오늘의 순간',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 6),
                    Text('“$bestMoment”'),
                    const SizedBox(height: 16),
                    const Text(
                      '생활 요약',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 6),
                    Text(displaySummary),
                  ],
                ),
              ),
              const Spacer(),
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
