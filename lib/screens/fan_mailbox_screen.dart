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
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '팬 호감도',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 10),
                    for (final profile in globalCoreFanProfiles) ...[
                      Text(
                        '${profile.name} ❤️ ${fanAffection[profile.name] ?? profile.affection} · 기분: ${profile.mood} · 서운함: ${profile.neglect}',
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            startOneOnOneLive(
                              context,
                              profile,
                              fanAffection[profile.name] ?? profile.affection,
                            );
                          },
                          child: Text(
                            '${fanNameWithParticle(profile.name)} 1:1 라방',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
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
