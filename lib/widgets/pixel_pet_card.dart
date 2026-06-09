import 'package:flutter/material.dart';

import '../models/core_fan_profile.dart';
import 'glass_card.dart';

class PixelPetCard extends StatelessWidget {
  final CoreFanProfile profile;

  const PixelPetCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
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
                  child: Text(
                    profile.name.isEmpty ? '?' : profile.name.substring(0, 1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
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
              ],
            ),
          ],
        ),
      ),
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
