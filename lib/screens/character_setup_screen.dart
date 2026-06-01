import 'package:flutter/material.dart';

import '../main.dart'
    show
        fanButtonStyle,
        globalFandomName,
        globalStageName,
        globalStyle;
import '../services/fanlive_storage.dart' show saveCharacter;
import '../widgets/fan_input.dart';
import '../widgets/fanlive_background.dart';
import 'home_screen.dart';

class CharacterSetupScreen extends StatefulWidget {
  const CharacterSetupScreen({super.key});

  @override
  State<CharacterSetupScreen> createState() => _CharacterSetupScreenState();
}

class _CharacterSetupScreenState extends State<CharacterSetupScreen> {
  final stageNameController = TextEditingController();
  final fandomNameController = TextEditingController();
  String selectedStyle = '감성';

  final styles = ['감성', '아이돌', '배우', '스트리머', '힙한', '몽환'];

  @override
  void dispose() {
    stageNameController.dispose();
    fandomNameController.dispose();
    super.dispose();
  }

  void createCharacter() {
    final stageName = stageNameController.text.trim();
    final fandomName = fandomNameController.text.trim();

    if (stageName.isEmpty || fandomName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('활동명과 팬덤명을 입력해줘.')),
      );
      return;
    }
    globalStageName = stageName;
    globalFandomName = fandomName;
    globalStyle = selectedStyle;
    saveCharacter();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          stageName: stageName,
          fandomName: fandomName,
          style: selectedStyle,
        ),
      ),
    );
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
              const Text(
                '캐릭터 만들기',
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '당신의 가상 방송인 계정을 만들어보세요.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 36),
              FanInput(
                controller: stageNameController,
                label: '활동명',
                hint: '예: LUNA',
              ),
              const SizedBox(height: 18),
              FanInput(
                controller: fandomNameController,
                label: '팬덤명',
                hint: '예: MOONIES',
              ),
              const SizedBox(height: 28),
              const Text(
                '방송 스타일',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: styles.map((style) {
                  final selected = selectedStyle == style;
                  return ChoiceChip(
                    label: Text(style),
                    selected: selected,
                    selectedColor: const Color(0xFFFF4FB8),
                    backgroundColor: Colors.white.withOpacity(0.08),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedStyle = style;
                      });
                    },
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: fanButtonStyle(),
                  onPressed: createCharacter,
                  child: const Text(
                    '캐릭터 생성하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
