import 'package:flutter/material.dart';

import '../services/live_theme_service.dart';
import '../widgets/fanlive_background.dart';
import '../widgets/glass_card.dart';
import 'live_room_screen.dart';

class ThemeSelectScreen extends StatefulWidget {
  final String stageName;
  final String fandomName;
  final String style;

  const ThemeSelectScreen({
    super.key,
    required this.stageName,
    required this.fandomName,
    required this.style,
  });

  @override
  State<ThemeSelectScreen> createState() => _ThemeSelectScreenState();
}

class _ThemeSelectScreenState extends State<ThemeSelectScreen> {
  final customConceptController = TextEditingController();

  @override
  void dispose() {
    customConceptController.dispose();
    super.dispose();
  }

  void startCustomConceptLive() {
    final customConcept = customConceptController.text.trim();

    if (customConcept.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('컨셉을 입력해 주세요.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveRoomScreen(
          stageName: widget.stageName,
          fandomName: widget.fandomName,
          themeTitle: '직접 입력 컨셉',
          customConcept: customConcept,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themes = LiveThemeService.getThemes();

    return FanLiveBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '오늘 어떤 라방을 할까요?',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '방송 테마에 따라 팬들의 반응이 달라져요.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView(
                  children: [
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '직접 컨셉 입력',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: customConceptController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '예: 수업 끝나고 지친 교수 컨셉',
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.08),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF4FB8),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: startCustomConceptLive,
                              child: const Text('이 컨셉으로 시작하기'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final theme in themes) ...[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LiveRoomScreen(
                                stageName: widget.stageName,
                                fandomName: widget.fandomName,
                                themeTitle: theme.title,
                              ),
                            ),
                          );
                        },
                        child: GlassCard(
                          child: Row(
                            children: [
                              Text(
                                theme.emoji,
                                style: const TextStyle(fontSize: 34),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      theme.title,
                                      style: const TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      theme.description,
                                      style: const TextStyle(
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
