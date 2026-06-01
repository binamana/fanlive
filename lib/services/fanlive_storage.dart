import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../app/fanlive_globals.dart' as app;
import '../models/broadcast_record.dart';

Future<void> saveFanState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('fanCount', app.globalFanCount);
  await prefs.setInt('level', app.globalLevel);
}

Future<void> loadFanState() async {
  final prefs = await SharedPreferences.getInstance();
  app.globalFanCount = prefs.getInt('fanCount') ?? 124;
  app.globalLevel = prefs.getInt('level') ?? 1;
}

Future<void> saveBroadcastRecords() async {
  final prefs = await SharedPreferences.getInstance();

  final recordsJson = app.globalBroadcastRecords
      .map((record) => jsonEncode(record.toJson()))
      .toList();

  await prefs.setStringList('broadcastRecords', recordsJson);
}

Future<void> saveFanMessages() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('fanMessages', app.globalFanMessages);
}

Future<void> loadFanMessages() async {
  final prefs = await SharedPreferences.getInstance();
  app.globalFanMessages = prefs.getStringList('fanMessages') ?? [];
}

Future<void> saveFanAffection() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setInt('affection_haru', app.fanAffection['하루'] ?? 0);
  await prefs.setInt('affection_byeolbam', app.fanAffection['별밤'] ?? 0);
  await prefs.setInt('affection_mint', app.fanAffection['민트'] ?? 0);
}

Future<void> loadFanAffection() async {
  final prefs = await SharedPreferences.getInstance();

  app.fanAffection['하루'] = prefs.getInt('affection_haru') ?? 0;
  app.fanAffection['별밤'] = prefs.getInt('affection_byeolbam') ?? 0;
  app.fanAffection['민트'] = prefs.getInt('affection_mint') ?? 0;
}

Future<void> loadBroadcastRecords() async {
  final prefs = await SharedPreferences.getInstance();

  final recordsJson = prefs.getStringList('broadcastRecords') ?? [];

  app.globalBroadcastRecords = recordsJson.map((recordString) {
    final json = jsonDecode(recordString);
    return BroadcastRecord.fromJson(json);
  }).toList();
}

Future<void> saveCharacter() async {
  final prefs = await SharedPreferences.getInstance();

  if (app.globalStageName != null) {
    await prefs.setString('stageName', app.globalStageName!);
  }

  if (app.globalFandomName != null) {
    await prefs.setString('fandomName', app.globalFandomName!);
  }

  if (app.globalStyle != null) {
    await prefs.setString('style', app.globalStyle!);
  }
}

Future<void> loadCharacter() async {
  final prefs = await SharedPreferences.getInstance();

  app.globalStageName = prefs.getString('stageName');
  app.globalFandomName = prefs.getString('fandomName');
  app.globalStyle = prefs.getString('style');
}
