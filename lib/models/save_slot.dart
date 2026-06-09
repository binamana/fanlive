import 'broadcast_record.dart';
import 'core_fan_profile.dart';

class SaveSlot {
  final int slotIndex;
  final DateTime savedAt;
  final String stageName;
  final String fandomName;
  final String style;
  final int fanCount;
  final int level;
  final List<String> fanMessages;
  final Map<String, int> fanAffection;
  final List<CoreFanProfile> coreFanProfiles;
  final List<BroadcastRecord> broadcastRecords;

  const SaveSlot({
    required this.slotIndex,
    required this.savedAt,
    required this.stageName,
    required this.fandomName,
    required this.style,
    required this.fanCount,
    required this.level,
    required this.fanMessages,
    required this.fanAffection,
    required this.coreFanProfiles,
    required this.broadcastRecords,
  });

  Map<String, Object> toJson() {
    return {
      'slotIndex': slotIndex,
      'savedAt': savedAt.toIso8601String(),
      'stageName': stageName,
      'fandomName': fandomName,
      'style': style,
      'fanCount': fanCount,
      'level': level,
      'fanMessages': fanMessages,
      'fanAffection': fanAffection,
      'coreFanProfiles': coreFanProfiles
          .map((profile) => profile.toJson())
          .toList(),
      'broadcastRecords': broadcastRecords
          .map((record) => record.toJson())
          .toList(),
    };
  }

  factory SaveSlot.fromJson(Map<String, dynamic> json) {
    return SaveSlot(
      slotIndex: _intValue(json['slotIndex']),
      savedAt:
          DateTime.tryParse(_stringValue(json['savedAt'])) ?? DateTime.now(),
      stageName: _stringValue(json['stageName']),
      fandomName: _stringValue(json['fandomName']),
      style: _stringValue(json['style']),
      fanCount: _intValue(json['fanCount']),
      level: _intValue(json['level'], fallback: 1),
      fanMessages: _stringListValue(json['fanMessages']),
      fanAffection: _intMapValue(json['fanAffection']),
      coreFanProfiles: _coreFanProfileListValue(json['coreFanProfiles']),
      broadcastRecords: _broadcastRecordListValue(json['broadcastRecords']),
    );
  }

  static String _stringValue(Object? value) {
    return value is String ? value : '';
  }

  static int _intValue(Object? value, {int fallback = 0}) {
    return value is num ? value.toInt() : fallback;
  }

  static List<String> _stringListValue(Object? value) {
    if (value is! List) return [];

    return value.whereType<String>().toList();
  }

  static Map<String, int> _intMapValue(Object? value) {
    if (value is! Map) return {};

    return value.map(
      (key, mapValue) =>
          MapEntry(key.toString(), mapValue is num ? mapValue.toInt() : 0),
    );
  }

  static List<CoreFanProfile> _coreFanProfileListValue(Object? value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map(
          (profileJson) =>
              CoreFanProfile.fromJson(Map<String, dynamic>.from(profileJson)),
        )
        .toList();
  }

  static List<BroadcastRecord> _broadcastRecordListValue(Object? value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map(
          (recordJson) =>
              BroadcastRecord.fromJson(Map<String, dynamic>.from(recordJson)),
        )
        .toList();
  }
}
