import 'package:flutter/material.dart';
import 'app/fanlive_globals.dart';
import 'screens/character_setup_screen.dart';
import 'screens/home_screen.dart';
import 'services/fanlive_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadFanState();
  await loadBroadcastRecords();
  await loadFanMessages();
  await loadFanAffection();
  await loadCoreFanProfiles();
  await loadCharacter();
  runApp(const FanLiveApp());
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


