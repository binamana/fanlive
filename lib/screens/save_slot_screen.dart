import 'package:flutter/material.dart';

import '../models/save_slot.dart';
import '../services/save_slot_service.dart';
import '../widgets/fanlive_background.dart';
import '../widgets/glass_card.dart';
import 'home_screen.dart';

enum SaveSlotMode { load, save }

class SaveSlotScreen extends StatefulWidget {
  final SaveSlotMode mode;

  const SaveSlotScreen({super.key, required this.mode});

  @override
  State<SaveSlotScreen> createState() => _SaveSlotScreenState();
}

class _SaveSlotScreenState extends State<SaveSlotScreen> {
  late Future<List<SaveSlot?>> slotsFuture;

  bool get isLoadMode => widget.mode == SaveSlotMode.load;

  @override
  void initState() {
    super.initState();
    slotsFuture = SaveSlotService.loadSlots();
  }

  Future<void> loadSlot(SaveSlot? slot) async {
    if (slot == null) {
      showMessage('저장된 데이터가 없어요.');
      return;
    }

    if (slot.stageName.isEmpty ||
        slot.fandomName.isEmpty ||
        slot.style.isEmpty) {
      showMessage('이 슬롯은 불러올 수 없어요.');
      return;
    }

    await SaveSlotService.loadSlot(slot);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          stageName: slot.stageName,
          fandomName: slot.fandomName,
          style: slot.style,
        ),
      ),
      (route) => false,
    );
  }

  Future<void> saveSlot(int slotIndex) async {
    try {
      await SaveSlotService.saveCurrentToSlot(slotIndex);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장했어요.')));
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      showMessage('저장할 현재 데이터가 없어요.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
              Text(
                isLoadMode ? '이어하기' : '저장하기',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLoadMode
                    ? '불러올 저장 슬롯을 선택해 주세요.'
                    : '현재 상태는 저장 버튼을 눌러야 슬롯에 저장돼요.',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<SaveSlot?>>(
                  future: slotsFuture,
                  builder: (context, snapshot) {
                    final slots =
                        snapshot.data ??
                        List<SaveSlot?>.filled(SaveSlotService.maxSlots, null);

                    return ListView.separated(
                      itemCount: SaveSlotService.maxSlots,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final slotIndex = index + 1;
                        final slot = slots[index];

                        return _SaveSlotCard(
                          slotIndex: slotIndex,
                          slot: slot,
                          isLoadMode: isLoadMode,
                          onLoad: () => loadSlot(slot),
                          onSave: () => saveSlot(slotIndex),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.12),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
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

class _SaveSlotCard extends StatelessWidget {
  final int slotIndex;
  final SaveSlot? slot;
  final bool isLoadMode;
  final VoidCallback onLoad;
  final VoidCallback onSave;

  const _SaveSlotCard({
    required this.slotIndex,
    required this.slot,
    required this.isLoadMode,
    required this.onLoad,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final currentSlot = slot;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '슬롯 $slotIndex',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (currentSlot == null)
            const Text('빈 슬롯', style: TextStyle(color: Colors.white54))
          else ...[
            Text(
              currentSlot.stageName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${currentSlot.fandomName} · Lv.${currentSlot.level} · 생활 점수 ${currentSlot.fanCount}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              '저장: ${formatSavedAt(currentSlot.savedAt)}',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoadMode && currentSlot == null
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFFFF4FB8),
                foregroundColor: Colors.white,
              ),
              onPressed: isLoadMode ? onLoad : onSave,
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }

  String get buttonLabel {
    if (isLoadMode) return '이어서 하기';

    return slot == null ? '여기에 저장' : '덮어쓰기';
  }

  String formatSavedAt(DateTime savedAt) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${savedAt.year}.${twoDigits(savedAt.month)}.${twoDigits(savedAt.day)} '
        '${twoDigits(savedAt.hour)}:${twoDigits(savedAt.minute)}';
  }
}
