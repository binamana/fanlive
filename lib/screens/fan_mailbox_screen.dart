import 'package:flutter/material.dart';

import '../main.dart' show fanAffection, fanButtonStyle, globalFanMessages;
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
                    Text('하루 ❤️ ${fanAffection['하루'] ?? 0}'),
                    Text('별밤 ❤️ ${fanAffection['별밤'] ?? 0}'),
                    Text('민트 ❤️ ${fanAffection['민트'] ?? 0}'),
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
