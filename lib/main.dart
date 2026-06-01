import 'package:flutter/material.dart';
import 'models/broadcast_record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'screens/character_setup_screen.dart';
import 'screens/home_screen.dart';

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

Future<void> saveFanState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('fanCount', globalFanCount);
  await prefs.setInt('level', globalLevel);
}

Future<void> loadFanState() async {
  final prefs = await SharedPreferences.getInstance();
  globalFanCount = prefs.getInt('fanCount') ?? 124;
  globalLevel = prefs.getInt('level') ?? 1;
}

Future<void> saveBroadcastRecords() async {
  final prefs = await SharedPreferences.getInstance();

  final recordsJson = globalBroadcastRecords
      .map((record) => jsonEncode(record.toJson()))
      .toList();

  await prefs.setStringList('broadcastRecords', recordsJson);
}

Future<void> saveFanMessages() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('fanMessages', globalFanMessages);
}

Future<void> loadFanMessages() async {
  final prefs = await SharedPreferences.getInstance();
  globalFanMessages = prefs.getStringList('fanMessages') ?? [];
}

Future<void> saveFanAffection() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt('affection_haru', fanAffection['하루'] ?? 0);
  await prefs.setInt('affection_byeolbam', fanAffection['별밤'] ?? 0);
  await prefs.setInt('affection_mint', fanAffection['민트'] ?? 0);
}

Future<void> loadFanAffection() async {
  final prefs = await SharedPreferences.getInstance();

  fanAffection['하루'] = prefs.getInt('affection_haru') ?? 0;
  fanAffection['별밤'] = prefs.getInt('affection_byeolbam') ?? 0;
  fanAffection['민트'] = prefs.getInt('affection_mint') ?? 0;
}

Future<void> loadBroadcastRecords() async {
  final prefs = await SharedPreferences.getInstance();

  final recordsJson = prefs.getStringList('broadcastRecords') ?? [];

  globalBroadcastRecords = recordsJson.map((recordString) {
    final json = jsonDecode(recordString);
    return BroadcastRecord.fromJson(json);
  }).toList();
}

Future<void> saveCharacter() async {
  final prefs = await SharedPreferences.getInstance();

  if (globalStageName != null) {
    await prefs.setString('stageName', globalStageName!);
  }

  if (globalFandomName != null) {
    await prefs.setString('fandomName', globalFandomName!);
  }

  if (globalStyle != null) {
    await prefs.setString('style', globalStyle!);
  }
}

Future<void> loadCharacter() async {
  final prefs = await SharedPreferences.getInstance();

  globalStageName = prefs.getString('stageName');
  globalFandomName = prefs.getString('fandomName');
  globalStyle = prefs.getString('style');
}

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


