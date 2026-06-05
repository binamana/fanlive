import 'package:flutter/material.dart';

import '../app/fanlive_globals.dart'
    show fanAffection, globalCoreFanProfiles, globalFanMessages;
import '../main.dart' show fanButtonStyle;
import '../widgets/fanlive_background.dart';
import '../widgets/glass_card.dart';

class FanMailboxScreen extends StatelessWidget {
  const FanMailboxScreen({super.key});

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
                    for (final profile in globalCoreFanProfiles)
                      Text(
                        '${profile.name} ❤️ ${fanAffection[profile.name] ?? profile.affection} · 기분: ${profile.mood} · 서운함: ${profile.neglect}',
                      ),
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
