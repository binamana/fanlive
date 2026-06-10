import 'package:flutter/material.dart';

import '../models/core_fan_profile.dart';
import 'glass_card.dart';

class PixelPetCard extends StatelessWidget {
  final CoreFanProfile profile;

  const PixelPetCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    if (!profile.isAdopted) {
      return const SizedBox(
        width: 220,
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '빈 룸펫 자리',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                '나중에 새 룸펫을 입양할 수 있어요.',
                style: TextStyle(color: Colors.white70, height: 1.35),
              ),
              SizedBox(height: 12),
              Text('잠김', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: 220,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4FB8).withOpacity(0.22),
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _buildPetVisual(profile),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        profile.companionType,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              profile.currentActivity,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, height: 1.35),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _MiniStat(label: '기분', value: profile.mood),
                _MiniStat(label: '친밀', value: '${profile.affection}'),
                _MiniStat(label: '에너지', value: '${profile.energy}'),
                _MiniStat(label: '모습', value: profile.appearanceType),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _appearanceIcon(CoreFanProfile profile) {
    if (profile.appearanceType.contains('유령')) {
      return '👻';
    }

    switch (profile.appearanceType) {
      case '고양이형 디지털 펫':
        return '🐱';
      case '로봇형 미니 친구':
        return '🤖';
      default:
        return profile.name.isEmpty ? '?' : profile.name.substring(0, 1);
    }
  }

  Widget _buildPetVisual(CoreFanProfile profile) {
    final assetPath = profile.imageAssetPath;

    if (assetPath == null || assetPath.isEmpty) {
      return Text(
        _appearanceIcon(profile),
        style: const TextStyle(fontSize: 20),
      );
    }

    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      errorBuilder: (_, __, ___) {
        return Text(
          _appearanceIcon(profile),
          style: const TextStyle(fontSize: 20),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label $value',
      style: const TextStyle(color: Colors.white54, fontSize: 12),
    );
  }
}
