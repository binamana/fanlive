import '../models/broadcast_record.dart';
import '../models/core_fan_profile.dart';
import '../services/core_fan_service.dart';

List<BroadcastRecord> globalBroadcastRecords = [];

int globalFanCount = 124;
int globalLevel = 1;

String? globalStageName;
String? globalFandomName;
String? globalStyle;
List<String> globalFanMessages = [];

Map<String, String> fanProfiles = {
  '하루': '감성적이고 걱정이 많은 장기팬',
  '별밤': '현실적인 조언을 잘하는 팬',
  '민트': '장난꾸러기이며 하트를 많이 보내는 팬',
};

Map<String, int> fanAffection = {'하루': 0, '별밤': 0, '민트': 0};

List<CoreFanProfile> globalCoreFanProfiles =
    CoreFanService.createDefaultProfiles()
      ..forEach((profile) {
        profile.affection = fanAffection[profile.name] ?? profile.affection;
      });
