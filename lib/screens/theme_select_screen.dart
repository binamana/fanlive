import 'package:flutter/material.dart';

import '../services/live_theme_service.dart';
import '../widgets/fanlive_background.dart';
import '../widgets/glass_card.dart';
import 'live_room_screen.dart';

class ThemeSelectScreen extends StatelessWidget {
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
                child: ListView.separated(
                  itemCount: themes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final theme = themes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LiveRoomScreen(
                              stageName: stageName,
                              fandomName: fandomName,
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
                                    style: const TextStyle(color: Colors.white60),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
