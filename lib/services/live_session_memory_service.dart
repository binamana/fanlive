class LiveSessionMemoryService {
  static const _maxRecentUserSpeech = 5;

  String? _mainTopic;
  String? _emotionalTone;
  String? _unresolvedConcern;
  String? _positiveTurn;
  String _latestMeaningfulUserSpeech = '';
  final _recentUserSpeech = <String>[];

  String get memory {
    final parts = <String>[
      if (_mainTopic != null) 'mainTopic: $_mainTopic',
      if (_emotionalTone != null) 'emotionalTone: $_emotionalTone',
      if (_unresolvedConcern != null)
        'unresolvedConcern: $_unresolvedConcern',
      if (_positiveTurn != null) 'positiveTurn: $_positiveTurn',
      if (_latestMeaningfulUserSpeech.isNotEmpty)
        'latestMeaningfulUserSpeech: $_latestMeaningfulUserSpeech',
      if (_recentUserSpeech.isNotEmpty)
        'recentUserSpeech: ${_recentUserSpeech.join(' / ')}',
    ];

    return parts.join('\n');
  }

  List<String> get recentUserSpeech => List.unmodifiable(_recentUserSpeech);

  String get conversationDigest {
    final parts = <String>[
      if (_mainTopic != null) _mainTopic!,
      if (_emotionalTone != null) _emotionalTone!,
      if (_unresolvedConcern != null) _unresolvedConcern!,
      if (_positiveTurn != null) _positiveTurn!,
    ];

    if (parts.isNotEmpty) {
      return parts.join(' · ');
    }

    return _latestMeaningfulUserSpeech.isEmpty
        ? ''
        : '최근 발화: $_latestMeaningfulUserSpeech';
  }

  void updateFromUserSpeech(String text) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    if (_isMeaningfulSpeech(trimmedText)) {
      _latestMeaningfulUserSpeech = _shorten(trimmedText);
      _rememberRecentSpeech(_latestMeaningfulUserSpeech);
    }

    _updateTopic(trimmedText);
    _updateEmotion(trimmedText);
    _updateConcern(trimmedText);
    _updatePositiveTurn(trimmedText);
  }

  void reset() {
    _mainTopic = null;
    _emotionalTone = null;
    _unresolvedConcern = null;
    _positiveTurn = null;
    _latestMeaningfulUserSpeech = '';
    _recentUserSpeech.clear();
  }

  void _updateTopic(String text) {
    if (_containsAny(text, ['수업', '학생', '강의'])) {
      _mainTopic = _containsAny(text, ['조용', '반응'])
          ? '수업/학생 반응'
          : '수업/강의 이야기';
      return;
    }

    if (_containsAny(text, ['작업', '앨범', '곡', '컴백', '발매', '노래'])) {
      _mainTopic = _containsAny(text, ['앨범', '컴백', '발매'])
          ? '앨범/컴백 준비'
          : '작업/음악 이야기';
      return;
    }

    if (_containsAny(text, ['팬미팅', '생일', '100일'])) {
      _mainTopic = '팬 이벤트/기념일 준비';
    }
  }

  void _updateEmotion(String text) {
    if (_containsAny(text, ['힘들', '지쳤', '멘탈', '위축'])) {
      _emotionalTone = '힘듦/위축';
      return;
    }

    if (_containsAny(text, ['피곤', '졸려'])) {
      _emotionalTone = '피곤함';
      return;
    }

    if (_containsAny(text, ['속상', '외롭', '서운'])) {
      _emotionalTone = '속상함/외로움';
      return;
    }

    if (_containsAny(text, ['고민', '걱정', '불안', '신경'])) {
      _emotionalTone ??= '걱정/고민';
    }
  }

  void _updateConcern(String text) {
    if (_isClassTomorrowWorry(text)) {
      _unresolvedConcern = '내일 수업에서도 학생들이 조용할까 봐 걱정함';
      return;
    }

    if (_hasClassTopic && _containsAny(text, ['조용', '반응', '망한'])) {
      _unresolvedConcern = '학생들이 조용해서 수업이 잘 안 된 것처럼 느껴짐';
      return;
    }

    if (_hasClassTopic && _containsAny(text, ['걱정', '신경', '불안'])) {
      _unresolvedConcern = '수업/학생 반응이 계속 신경 쓰임';
      return;
    }

    if (_hasMusicTopic && _containsAny(text, ['고민', '어떻게', '컨셉'])) {
      _unresolvedConcern = '작업이나 앨범 방향을 팬들과 정리하고 싶어 함';
      return;
    }

    if (_isVagueFollowUpWorry(text)) {
      _unresolvedConcern = _mainTopic == null
          ? '앞서 말한 일 때문에 계속 신경 쓰이고 걱정함'
          : '앞서 말한 $_mainTopic 때문에 계속 신경 쓰이고 걱정함';
    }
  }

  void _updatePositiveTurn(String text) {
    if (_containsAny(text, ['팬']) &&
        _containsAny(text, ['덕분', '낫', '나아', '고마워', '감사'])) {
      _positiveTurn = '팬들과 대화하면서 조금 나아짐';
      return;
    }

    if (_isVagueImprovement(text)) {
      _positiveTurn = _hasFanContext
          ? '팬들과 대화하면서 조금 나아짐'
          : '앞서 말한 일에 대해 그래도 조금 나아짐';
    }
  }

  void _rememberRecentSpeech(String speech) {
    _recentUserSpeech.remove(speech);
    _recentUserSpeech.add(speech);

    while (_recentUserSpeech.length > _maxRecentUserSpeech) {
      _recentUserSpeech.removeAt(0);
    }
  }

  bool get _hasClassTopic {
    return _mainTopic != null &&
        (_mainTopic!.contains('수업') || _mainTopic!.contains('학생'));
  }

  bool get _hasMusicTopic {
    return _mainTopic != null &&
        (_mainTopic!.contains('작업') ||
            _mainTopic!.contains('앨범') ||
            _mainTopic!.contains('음악'));
  }

  bool get _hasFanContext {
    return _positiveTurn != null ||
        _recentUserSpeech.any((speech) => speech.contains('팬'));
  }

  bool _isClassTomorrowWorry(String text) {
    return _hasClassTopic &&
        _containsAny(text, ['내일']) &&
        _containsAny(text, ['걱정', '신경', '불안']);
  }

  bool _isVagueFollowUpWorry(String text) {
    return _containsAny(text, ['그게', '그거', '그 일', '내일', '계속', '아직']) &&
        _containsAny(text, ['걱정', '신경', '불안']);
  }

  bool _isVagueImprovement(String text) {
    return _containsAny(text, ['그래도', '조금', '좀']) &&
        _containsAny(text, ['낫', '나아', '괜찮']);
  }

  bool _isMeaningfulSpeech(String text) {
    if (text.length <= 2) return false;
    return !_containsAnyOnly(text, ['ㅋ', 'ㅎ', 'ㅠ', 'ㅜ', 'ㅇ']);
  }

  bool _containsAny(String text, List<String> triggers) {
    return triggers.any(text.contains);
  }

  bool _containsAnyOnly(String text, List<String> characters) {
    final compactText = text.replaceAll(RegExp(r'\s+'), '');

    if (compactText.isEmpty) return false;

    return compactText.runes.every(
      (rune) => characters.contains(String.fromCharCode(rune)),
    );
  }

  String _shorten(String text) {
    const maxLength = 80;
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
