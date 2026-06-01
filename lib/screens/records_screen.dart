import 'package:flutter/material.dart';

import '../main.dart' show fanButtonStyle;
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

    return FanLiveBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '방송 기록',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '내 캐릭터의 활동 기록이 쌓여요.',
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
                      themeTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('최고 시청자: $viewers명'),
                    Text('총 하트: $hearts개'),
                    const Text('신규 팬: +24명'),
                    const SizedBox(height: 16),
                    const Text(
                      '오늘의 순간',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 6),
                    Text('“$bestMoment”'),
                    const SizedBox(height: 16),
                    const Text(
                      '요약',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 6),
                    Text(summary),
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
