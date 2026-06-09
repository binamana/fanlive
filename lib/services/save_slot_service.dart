import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../app/fanlive_globals.dart' as app;
import '../models/broadcast_record.dart';
import '../models/save_slot.dart';
import 'core_fan_service.dart';
import 'fanlive_storage.dart';

class SaveSlotService {
  static const maxSlots = 3;
  static const _saveSlotsKey = 'fanliveSaveSlots';

  const SaveSlotService._();

  static Future<List<SaveSlot?>> loadSlots() async {
    final prefs = await SharedPreferences.getInstance();
    final slotStrings = prefs.getStringList(_saveSlotsKey) ?? [];
    final slots = List<SaveSlot?>.filled(maxSlots, null);

    for (final slotString in slotStrings) {
      if (slotString.trim().isEmpty) continue;

      try {
        final decodedSlot = jsonDecode(slotString);

        if (decodedSlot is! Map) continue;

        final slot = SaveSlot.fromJson(Map<String, dynamic>.from(decodedSlot));
        final index = slot.slotIndex - 1;

        if (index >= 0 && index < maxSlots && _hasCharacterData(slot)) {
          slots[index] = slot;
        }
      } catch (_) {
        // Ignore corrupt slots and keep the remaining saves available.
      }
    }

    return slots;
  }

  static Future<void> saveCurrentToSlot(int slotIndex) async {
    if (!_hasCurrentCharacter()) {
      throw StateError('No character data to save.');
    }

    final slots = await loadSlots();
    slots[slotIndex - 1] = createSnapshot(slotIndex);
    await _saveSlots(slots);
  }

  static Future<void> loadSlot(SaveSlot slot) async {
    applySlotToGlobals(slot);
    await persistCurrentLegacyState();
  }

  static Future<void> migrateLegacyCurrentDataToFirstSlotIfNeeded() async {
    final slots = await loadSlots();
    final hasAnySlot = slots.any((slot) => slot != null);

    if (hasAnySlot || !_hasCurrentCharacter()) {
      return;
    }

    slots[0] = createSnapshot(1);
    await _saveSlots(slots);
  }

  static Future<void> startNewGame() async {
    app.resetCurrentRunGlobals(clearCharacter: true);
    await persistCurrentLegacyState(clearCharacterData: true);
  }

  static SaveSlot createSnapshot(int slotIndex) {
    return SaveSlot(
      slotIndex: slotIndex,
      savedAt: DateTime.now(),
      stageName: app.globalStageName ?? '',
      fandomName: app.globalFandomName ?? '',
      style: app.globalStyle ?? '',
      fanCount: app.globalFanCount,
      level: app.globalLevel,
      fanMessages: List<String>.from(app.globalFanMessages),
      fanAffection: Map<String, int>.from(app.fanAffection),
      coreFanProfiles: app.globalCoreFanProfiles,
      broadcastRecords: app.globalBroadcastRecords,
    );
  }

  static void applySlotToGlobals(SaveSlot slot) {
    app.globalStageName = slot.stageName;
    app.globalFandomName = slot.fandomName;
    app.globalStyle = slot.style;
    app.globalFanCount = slot.fanCount;
    app.globalLevel = slot.level;
    app.globalFanMessages = List<String>.from(slot.fanMessages);
    app.globalBroadcastRecords = List<BroadcastRecord>.from(
      slot.broadcastRecords,
    );

    app.fanAffection
      ..clear()
      ..addAll(app.createDefaultFanAffection())
      ..addAll(slot.fanAffection);

    final savedProfiles = slot.coreFanProfiles.isEmpty
        ? CoreFanService.createDefaultProfiles()
        : slot.coreFanProfiles;
    app.globalCoreFanProfiles = CoreFanService.mergeWithDefaultProfiles(
      savedProfiles,
    );
    CoreFanService.syncFromLegacyFanAffection(
      app.globalCoreFanProfiles,
      app.fanAffection,
    );
    CoreFanService.syncToLegacyFanAffection(
      app.globalCoreFanProfiles,
      app.fanAffection,
    );
  }

  static Future<void> persistCurrentLegacyState({
    bool clearCharacterData = false,
  }) async {
    if (clearCharacterData) {
      await clearCharacter();
    } else {
      await saveCharacter();
    }

    await saveFanState();
    await saveBroadcastRecords();
    await saveFanMessages();
    await saveFanAffection();
    await saveCoreFanProfiles();
  }

  static Future<void> _saveSlots(List<SaveSlot?> slots) async {
    final prefs = await SharedPreferences.getInstance();
    final slotStrings = slots
        .whereType<SaveSlot>()
        .map((slot) => jsonEncode(slot.toJson()))
        .toList();

    await prefs.setStringList(_saveSlotsKey, slotStrings);
  }

  static bool _hasCurrentCharacter() {
    return app.globalStageName != null &&
        app.globalFandomName != null &&
        app.globalStyle != null;
  }

  static bool _hasCharacterData(SaveSlot slot) {
    return slot.stageName.isNotEmpty &&
        slot.fandomName.isNotEmpty &&
        slot.style.isNotEmpty;
  }
}
