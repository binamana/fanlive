import 'package:flutter/material.dart';

import '../main.dart' show fanButtonStyle;
import '../services/save_slot_service.dart';
import '../widgets/fanlive_background.dart';
import '../widgets/glass_card.dart';
import 'character_setup_screen.dart';
import 'save_slot_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FanLiveBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                'FANLIVE',
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '세 명의 사이버 동거인과 사는 AI 룸 라이프',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 28),
              const GlassCard(
                child: Text(
                  '새로 시작하면 내 방과 동거인 관계를 준비해요.\n이어하기는 저장된 사이버 방을 불러옵니다.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
              ),
              const SizedBox(height: 28),
              _MenuButton(
                label: '새로 시작',
                onPressed: () async {
                  await SaveSlotService.startNewGame();

                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CharacterSetupScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _MenuButton(
                label: '이어하기',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SaveSlotScreen(mode: SaveSlotMode.load),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _MenuButton(
                label: '설정',
                secondary: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('설정은 곧 추가될 예정이에요.')),
                  );
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool secondary;

  const _MenuButton({
    required this.label,
    required this.onPressed,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: secondary
            ? ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.12),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              )
            : fanButtonStyle(),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
