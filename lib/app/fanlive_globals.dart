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
  '하루': '의존적이고 착한 사이버 동거인',
  '별밤': '시니컬한 츤데레 동거인',
  '민트': '말썽쟁이 장난꾸러기 동거인',
};

Map<String, int> fanAffection = createDefaultFanAffection();

List<CoreFanProfile> globalCoreFanProfiles =
    CoreFanService.createDefaultProfiles()..forEach((profile) {
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
  globalCoreFanProfiles = CoreFanService.createDefaultProfiles();
  CoreFanService.syncToLegacyFanAffection(globalCoreFanProfiles, fanAffection);

  if (clearCharacter) {
    globalStageName = null;
    globalFandomName = null;
    globalStyle = null;
  }
}
