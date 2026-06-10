import 'package:flutter/material.dart';

import '../app/fanlive_globals.dart' show globalBroadcastRecords;
import '../main.dart' show fanButtonStyle;
import '../services/memory_title_service.dart';
import '../widgets/fanlive_background.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final earnedTitles = globalBroadcastRecords
        .map((record) => MemoryTitleService.displayTitle(record.earnedTitle))
        .toSet();

    const achievements = [
      _MemoryAchievement(title: '첫 대화', rewardTitle: '이상한 동거의 시작'),
      _MemoryAchievement(title: '방을 저장한 날', rewardTitle: '픽셀 룸의 주인'),
      _MemoryAchievement(title: '괜찮냐고 물어본 날', rewardTitle: '하루가 기다린 사람'),
      _MemoryAchievement(title: '툴툴대는 조언', rewardTitle: '별밤의 관찰 대상'),
      _MemoryAchievement(title: '작은 사고 발생', rewardTitle: '민트의 공범'),
      _MemoryAchievement(title: '같이 버틴 밤', rewardTitle: '새벽을 같이 넘긴 방'),
      _MemoryAchievement(title: '비밀 장소 발견', rewardTitle: '쿠션 아래의 비밀친구'),
      _MemoryAchievement(title: '말썽 수습', rewardTitle: '말썽을 수습한 보호자'),
      _MemoryAchievement(title: '작업실 대화', rewardTitle: '조용한 작업실의 주인'),
      _MemoryAchievement(title: '방 정리 실패', rewardTitle: '혼돈의 방 정리반'),
      _MemoryAchievement(title: '다시 돌아온 날', rewardTitle: '오늘도 돌아온 사람'),
    ];

    return FanLiveBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '기억 조각',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '룸펫과 쌓은 관계 칭호와 작은 방의 기억이 여기에 모여요.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: achievements.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    final unlocked = earnedTitles.contains(
                      achievement.rewardTitle,
                    );

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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  achievement.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: unlocked
                                        ? Colors.white
                                        : Colors.white38,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '관계 칭호: ${achievement.rewardTitle}',
                                  style: TextStyle(
                                    color: unlocked
                                        ? Colors.white70
                                        : Colors.white30,
                                  ),
                                ),
                              ],
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

class _MemoryAchievement {
  final String title;
  final String rewardTitle;

  const _MemoryAchievement({required this.title, required this.rewardTitle});
}
