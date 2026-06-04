class LiveSessionMemoryService {
  static const _maxNotes = 6;

  final memoryNotes = <String>[];
  String _latestUserSpeech = '';

  String get memory {
    final parts = <String>[];

    if (memoryNotes.isNotEmpty) {
      parts.add(memoryNotes.join(' '));
    }

    if (_latestUserSpeech.isNotEmpty) {
      parts.add('최근 발화: $_latestUserSpeech');
    }

    return parts.join(' ');
  }

  void updateFromUserSpeech(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    _latestUserSpeech = _shorten(trimmedText);

    if (_isClassTomorrowWorry(trimmedText)) {
      _remember(
        '사용자가 앞서 말한 수업/학생 반응 때문에 내일도 걱정하고 있다.',
        replaceIfContains: ['내일도 걱정'],
      );
    } else if (_containsAny(trimmedText, ['수업', '학생', '강의'])) {
      final note = _containsAny(trimmedText, ['조용'])
          ? '사용자가 수업에서 학생들이 너무 조용해서 힘들었다고 말했다.'
          : '사용자가 수업/학생/강의 상황에 대해 이야기했다.';
      _remember(note, replaceIfContains: ['수업', '학생', '강의']);
    } else if (_isVagueFollowUpWorry(trimmedText)) {
      _remember(
        '사용자가 앞서 말한 일 때문에 계속 신경 쓰이고 걱정된다고 말했다.',
        replaceIfContains: ['걱정', '신경'],
      );
    }

    if (_containsAny(trimmedText, ['힘들', '피곤', '속상', '고민'])) {
      _remember(
        '사용자가 피곤하거나 힘든 상태라고 말했다.',
        replaceIfContains: ['피곤', '힘든', '속상', '고민'],
      );
    }

    if (_containsAny(trimmedText, ['작업', '앨범', '곡', '컴백', '발매'])) {
      _remember(
        '사용자가 앨범/곡/작업 이야기를 했다.',
        replaceIfContains: ['앨범', '곡', '작업', '컴백', '발매'],
      );
    }

    if (_containsAny(trimmedText, ['고마워', '감사', '팬'])) {
      final note = _containsAny(trimmedText, ['덕분', '낫', '좋아'])
          ? '사용자가 팬들 덕분에 낫다고 말했다.'
          : '사용자가 팬들에게 고마움을 표현했다.';
      _remember(
        note,
        replaceIfContains: ['팬들 덕분', '팬들에게 고마움', '고마움'],
      );
    }

    if (_containsAny(trimmedText, ['팬미팅', '생일', '100일'])) {
      _remember(
        '사용자가 팬미팅/생일/100일 같은 예정 이벤트를 언급했다.',
        replaceIfContains: ['팬미팅', '생일', '100일', '이벤트'],
      );
    }

    if (_isVagueImprovement(trimmedText)) {
      _remember(
        '사용자가 앞서 말한 일에 대해 그래도 조금 나아졌다고 말했다.',
        replaceIfContains: ['나아졌', '낫다', '낫다고'],
      );
    }
  }

  void reset() {
    memoryNotes.clear();
    _latestUserSpeech = '';
  }

  void _remember(String note, {List<String> replaceIfContains = const []}) {
    memoryNotes.removeWhere(
      (existingNote) =>
          existingNote == note ||
          replaceIfContains.any(existingNote.contains),
    );

    memoryNotes.add(note);

    while (memoryNotes.length > _maxNotes) {
      memoryNotes.removeAt(0);
    }
  }

  bool _isClassTomorrowWorry(String text) {
    return _containsAny(text, ['내일']) &&
        _containsAny(text, ['걱정', '신경']) &&
        _hasMemoryAbout(['수업', '학생', '강의']);
  }

  bool _isVagueFollowUpWorry(String text) {
    return _containsAny(text, ['그게', '그거', '내일', '계속', '아직']) &&
        _containsAny(text, ['걱정', '신경', '불안']);
  }

  bool _isVagueImprovement(String text) {
    return _containsAny(text, ['그래도', '조금', '좀']) &&
        _containsAny(text, ['낫', '나아', '괜찮']);
  }

  bool _hasMemoryAbout(List<String> keywords) {
    return memoryNotes.any(
      (note) => keywords.any(note.contains),
    );
  }

  bool _containsAny(String text, List<String> triggers) {
    return triggers.any(text.contains);
  }

  String _shorten(String text) {
    const maxLength = 60;
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
