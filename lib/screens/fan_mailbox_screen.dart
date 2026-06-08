import 'package:flutter/material.dart';

import '../app/fanlive_globals.dart'
    show
        fanAffection,
        globalCoreFanProfiles,
        globalFanMessages,
        globalFandomName,
        globalStageName;
import '../main.dart' show fanButtonStyle;
import '../models/core_fan_profile.dart';
import '../widgets/fanlive_background.dart';
import '../widgets/glass_card.dart';
import 'one_on_one_live_screen.dart';

class FanMailboxScreen extends StatelessWidget {
  const FanMailboxScreen({super.key});

  void startOneOnOneLive(
    BuildContext context,
    CoreFanProfile profile,
    int affection,
  ) {
    final fanWithParticle = fanNameWithParticle(profile.name);

    if (affection < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$fanWithParticle 더 친해지면 1:1 라방을 열 수 있어요.'),
        ),
      );
      return;
    }

    if (globalStageName == null || globalFandomName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('캐릭터 정보를 먼저 설정해 주세요.')),
      );
      return;
    }

    profile.affection = affection;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OneOnOneLiveScreen(
          fanProfile: profile,
          stageName: globalStageName!,
          fandomName: globalFandomName!,
        ),
      ),
    );
  }

  String fanNameWithParticle(String fanName) {
    return fanName == '별밤' ? '$fanName과' : '$fanName와';
  }

  String coreFanLabel(String fanName) {
    switch (fanName) {
      case '하루':
        return '다정한 오래된 팬';
      case '별밤':
        return '현실적인 조언 팬';
      case '민트':
        return '장난 많은 리액션 팬';
      default:
        return '코어 팬';
    }
  }

  String favoriteThemeSummary(CoreFanProfile profile) {
    if (profile.favoriteThemes.isEmpty) {
      return '아직 없음';
    }

    if (profile.favoriteThemes.length <= 2) {
      return profile.favoriteThemes.join(', ');
    }

    return '${profile.favoriteThemes.take(2).join(', ')} 외 ${profile.favoriteThemes.length - 2}개';
  }

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
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '도착한 팬 메시지 ${globalFanMessages.length}개',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Text(
                '팬 관계',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 330,
                child: ListView.separated(
                  itemCount: globalCoreFanProfiles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final profile = globalCoreFanProfiles[index];
                    final affection =
                        fanAffection[profile.name] ?? profile.affection;
                    final remainingAffection = 20 - affection;
                    final isUnlocked = affection >= 20;

                    return GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  profile.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                coreFanLabel(profile.name),
                                style: const TextStyle(color: Colors.white60),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '호감도 $affection · 기분 ${profile.mood} · 서운함 ${profile.neglect}',
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '좋아하는 라방: ${favoriteThemeSummary(profile)}',
                            style: const TextStyle(color: Colors.white60),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isUnlocked
                                ? '1:1 라방 가능'
                                : '1:1 라방까지 $remainingAffection 호감도 남음',
                            style: TextStyle(
                              color: isUnlocked
                                  ? const Color(0xFFFF8FD2)
                                  : Colors.white54,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isUnlocked
                                    ? Colors.white
                                    : Colors.white60,
                                side: BorderSide(
                                  color: isUnlocked
                                      ? const Color(0xFFFF8FD2)
                                      : Colors.white24,
                                ),
                              ),
                              onPressed: () {
                                startOneOnOneLive(
                                  context,
                                  profile,
                                  affection,
                                );
                              },
                              child: Text(
                                isUnlocked
                                    ? '${fanNameWithParticle(profile.name)} 1:1 라방 열기'
                                    : '${fanNameWithParticle(profile.name)} 1:1 라방',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
                          style: const TextStyle(fontSize: 16),
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
