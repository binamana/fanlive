import '../models/broadcast_record.dart';
import '../models/core_fan_profile.dart';
import '../services/core_fan_service.dart';

List<BroadcastRecord> globalBroadcastRecords = [];

const defaultFanCount = 0;
const defaultLevel = 1;

int globalFanCount = defaultFanCount;
int globalLevel = defaultLevel;

String? globalStageName;
String? globalFandomName;
String? globalStyle;
List<String> globalFanMessages = [];

Map<String, String> fanProfiles = {
  '하루': '기다림이 많은 다정한 룸펫',
  '별밤': '툴툴대는 츤데레 룸펫',
  '민트': '말썽 많은 장난꾸러기 룸펫',
};

Map<String, int> fanAffection = createDefaultFanAffection();

List<CoreFanProfile> globalCoreFanProfiles =
    CoreFanService.createStarterProfiles()..forEach((profile) {
      profile.affection = fanAffection[profile.name] ?? profile.affection;
    });

Map<String, int> createDefaultFanAffection() {
  return {'하루': 0, '별밤': 0, '민트': 0};
}

void resetCurrentRunGlobals({bool clearCharacter = true}) {
  globalBroadcastRecords = [];
  globalFanCount = defaultFanCount;
  globalLevel = defaultLevel;
  globalFanMessages = [];
  fanAffection
    ..clear()
    ..addAll(createDefaultFanAffection());
  globalCoreFanProfiles = CoreFanService.createStarterProfiles();
  CoreFanService.syncToLegacyFanAffection(globalCoreFanProfiles, fanAffection);

  if (clearCharacter) {
    globalStageName = null;
    globalFandomName = null;
    globalStyle = null;
  }
}
