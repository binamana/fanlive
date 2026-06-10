import 'package:flutter/material.dart';

import '../app/fanlive_globals.dart' show globalBroadcastRecords;
import '../main.dart' show fanButtonStyle;
import '../services/memory_title_service.dart';
import '../widgets/fanlive_background.dart';
import '../widgets/glass_card.dart';

class RecordsListScreen extends StatelessWidget {
  const RecordsListScreen({super.key});

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
                '생활 기록',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '룸펫과 보낸 하루 기록이 여기에 쌓여요.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: globalBroadcastRecords.isEmpty
                    ? const Center(
                        child: Text(
                          '아직 생활 기록이 없어요.\n거실에서 먼저 말을 걸어보세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.separated(
                        itemCount: globalBroadcastRecords.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final record = globalBroadcastRecords[index];
                          final displayTheme =
                              MemoryTitleService.displayRecordTheme(
                                record.themeTitle,
                              );
                          final displayTitle = MemoryTitleService.displayTitle(
                            record.earnedTitle,
                          );
                          final displaySummary =
                              MemoryTitleService.displaySummary(record.summary);

                          return GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${record.createdAt.year}.${record.createdAt.month}.${record.createdAt.day}',
                                  style: const TextStyle(color: Colors.white54),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  displayTheme,
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text('방 반응: ${record.viewers}'),
                                Text('감정 에너지: ${record.hearts}'),
                                Text('관계 변화: +${record.viewers ~/ 8}'),
                                Text('관계 칭호: $displayTitle'),
                                const SizedBox(height: 12),
                                Text(
                                  displaySummary,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),
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
