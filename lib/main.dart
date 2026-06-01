import 'package:flutter/material.dart';
import 'models/broadcast_record.dart';
import 'screens/character_setup_screen.dart';
import 'screens/home_screen.dart';
import 'services/fanlive_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadFanState();
  await loadBroadcastRecords();
  await loadFanMessages();
  await loadFanAffection();
  await loadCharacter();
  runApp(const FanLiveApp());
}

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

bool hasCharacter() {
  return globalStageName != null &&
      globalFandomName != null &&
      globalStyle != null;
}

class FanLiveApp extends StatelessWidget {
  const FanLiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FANLIVE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: hasCharacter()
          ? HomeScreen(
              stageName: globalStageName!,
              fandomName: globalFandomName!,
              style: globalStyle!,
            )
          : const CharacterSetupScreen(),
    );
  }
}

ButtonStyle fanButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFF4FB8),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
  );
}


