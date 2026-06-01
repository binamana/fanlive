import 'package:flutter/material.dart';

import '../app/fanlive_globals.dart' show globalBroadcastRecords;
import '../main.dart' show fanButtonStyle;
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
                '방송 기록',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '지금까지의 라방 기록이 여기에 쌓여요.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: globalBroadcastRecords.isEmpty
                    ? const Center(
                        child: Text(
                          '아직 방송 기록이 없어요.\n첫 라방을 시작해보세요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.separated(
                        itemCount: globalBroadcastRecords.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final record = globalBroadcastRecords[index];
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
                                  record.themeTitle,
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text('최고 시청자: ${record.viewers}명'),
                                Text('총 하트: ${record.hearts}개'),
                                Text('신규 팬: +${record.viewers ~/ 8}명'),
                                Text('획득 칭호: ${record.earnedTitle}'),
                                const SizedBox(height: 12),
                                Text(
                                  record.summary,
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
