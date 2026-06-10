import 'package:flutter/material.dart';

import '../app/fanlive_globals.dart'
    show
        fanAffection,
        globalCoreFanProfiles,
        globalFandomName,
        globalStageName,
        globalStyle;
import '../main.dart' show fanButtonStyle;
import '../services/core_fan_service.dart';
import '../services/save_slot_service.dart';
import '../widgets/fan_input.dart';
import '../widgets/fanlive_background.dart';
import '../widgets/glass_card.dart';
import 'home_screen.dart';

class CharacterSetupScreen extends StatefulWidget {
  const CharacterSetupScreen({super.key});

  @override
  State<CharacterSetupScreen> createState() => _CharacterSetupScreenState();
}

class _CharacterSetupScreenState extends State<CharacterSetupScreen> {
  final userNameController = TextEditingController();
  final roomNameController = TextEditingController();
  final companionNameController = TextEditingController(text: '하루');

  final roomMoods = const [
    '포근한 일상형',
    '새벽 감성형',
    '장난 많은 혼돈형',
    '조용한 작업실형',
    '이상한 실험실형',
  ];

  final companionArchetypes = const [
    '의존적이고 착한 타입',
    '시니컬한 츤데레 타입',
    '말썽쟁이 장난꾸러기 타입',
  ];

  final appearanceTypes = const [
    '둥근 픽셀 생명체',
    '고양이형 디지털 펫',
    '작은 유령형 룸펫',
    '로봇형 미니 친구',
  ];

  String selectedRoomMood = '포근한 일상형';
  String selectedArchetype = '의존적이고 착한 타입';
  String selectedAppearance = '둥근 픽셀 생명체';

  @override
  void dispose() {
    userNameController.dispose();
    roomNameController.dispose();
    companionNameController.dispose();
    super.dispose();
  }

  Future<void> createRoom() async {
    final userName = userNameController.text.trim();
    final roomName = roomNameController.text.trim();
    final companionName = companionNameController.text.trim();

    if (userName.isEmpty || roomName.isEmpty || companionName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내 이름, 방 이름, 첫 룸펫 이름을 입력해줘.')),
      );
      return;
    }

    globalStageName = userName;
    globalFandomName = roomName;
    globalStyle = selectedRoomMood;
    globalCoreFanProfiles = CoreFanService.createStarterProfiles(
      companionName: companionName,
      archetype: selectedArchetype,
      appearanceType: selectedAppearance,
    );

    fanAffection
      ..clear()
      ..addAll({companionName: 0});
    CoreFanService.syncToLegacyFanAffection(
      globalCoreFanProfiles,
      fanAffection,
    );

    await SaveSlotService.persistCurrentLegacyState();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          stageName: userName,
          fandomName: roomName,
          style: selectedRoomMood,
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '픽셀 룸 만들기',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '첫 룸펫을 맞이하고 함께 지낼 작은 방을 만들어 보세요.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 30),
                FanInput(
                  controller: userNameController,
                  label: '내 이름',
                  hint: '예: 상빈, 로빈, 빈',
                ),
                const SizedBox(height: 18),
                FanInput(
                  controller: roomNameController,
                  label: '방 이름',
                  hint: '예: 달빛방, 작은 둥지, 작업실',
                ),
                const SizedBox(height: 24),
                _ChoiceSection(
                  title: '방 분위기',
                  options: roomMoods,
                  selectedValue: selectedRoomMood,
                  onSelected: (value) {
                    setState(() {
                      selectedRoomMood = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                const GlassCard(
                  child: Text(
                    '처음에는 한 마리의 룸펫과 시작해요. 다른 빈 자리는 나중에 열 수 있어요.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ),
                const SizedBox(height: 18),
                FanInput(
                  controller: companionNameController,
                  label: '첫 룸펫 이름',
                  hint: '예: 하루, 루루, 모모, 픽셀',
                ),
                const SizedBox(height: 24),
                _ChoiceSection(
                  title: '첫 룸펫 성향',
                  options: companionArchetypes,
                  selectedValue: selectedArchetype,
                  onSelected: (value) {
                    setState(() {
                      selectedArchetype = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                _ChoiceSection(
                  title: '첫 룸펫 모습',
                  options: appearanceTypes,
                  selectedValue: selectedAppearance,
                  onSelected: (value) {
                    setState(() {
                      selectedAppearance = value;
                    });
                  },
                ),
                const SizedBox(height: 18),
                _AppearancePreview(appearanceType: selectedAppearance),
                const SizedBox(height: 34),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: fanButtonStyle(),
                    onPressed: createRoom,
                    child: const Text(
                      '입주 시작하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const _ChoiceSection({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            final selected = selectedValue == option;

            return ChoiceChip(
              label: Text(option),
              selected: selected,
              selectedColor: const Color(0xFFFF4FB8),
              backgroundColor: Colors.white.withOpacity(0.08),
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (_) => onSelected(option),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AppearancePreview extends StatelessWidget {
  final String appearanceType;

  const _AppearancePreview({required this.appearanceType});

  @override
  Widget build(BuildContext context) {
    final imageAssetPath = CoreFanService.imageAssetPathForAppearance(
      appearanceType,
    );

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4FB8).withOpacity(0.18),
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(8),
            ),
            child: imageAssetPath == null
                ? Text(
                    _emojiForAppearance(appearanceType),
                    style: const TextStyle(fontSize: 26),
                  )
                : Image.asset(
                    imageAssetPath,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    errorBuilder: (_, __, ___) {
                      return Text(
                        _emojiForAppearance(appearanceType),
                        style: const TextStyle(fontSize: 26),
                      );
                    },
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              appearanceType,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _emojiForAppearance(String appearanceType) {
    switch (appearanceType) {
      case '고양이형 디지털 펫':
        return '🐱';
      case '작은 유령형 룸펫':
        return '👻';
      case '로봇형 미니 친구':
        return '🤖';
      default:
        return '●';
    }
  }
}
