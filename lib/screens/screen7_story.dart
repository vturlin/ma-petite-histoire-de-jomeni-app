import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_story.dart';
import '../models/story_config.dart';
import '../services/gemini_service.dart';
import '../services/gemini_tts_service.dart';
import '../services/story_library_service.dart';
import '../theme/app_theme.dart';

class StoryScreen extends StatefulWidget {
  /// Mode génération : config + apiKey
  final StoryConfig? config;
  final String apiKey;
  /// Mode bibliothèque : histoire déjà sauvegardée
  final SavedStory? savedStory;

  const StoryScreen({
    super.key,
    this.config,
    required this.apiKey,
    this.savedStory,
  }) : assert(config != null || savedStory != null);

  bool get isLibraryMode => savedStory != null;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final AudioPlayer _player = AudioPlayer();

  // ─── Texte ────────────────────────────────────────────────────────────────
  String _fullStory = '';
  String _displayedStory = '';
  String _promptUsed = '';
  bool _isLoading = true;
  bool _isTyping = false;
  bool _showPrompt = false;
  String? _error;

  Timer? _typingTimer;
  int _typingIndex = 0;

  // ─── Lecture TTS ──────────────────────────────────────────────────────────
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isLoadingAudio = false;
  String _audioStatus = '';
  String? _ttsError;

  List<String> _chunks = [];
  int _currentChunk = 0;
  final Map<int, Uint8List> _audioCache = {};
  bool _isPregenerating = false;

  // ─── Sauvegarde ───────────────────────────────────────────────────────────
  bool _isSaved = false;
  bool _isSaving = false;
  String _saveStatus = '';
  String? _storyId;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) => _onChunkComplete());

    if (widget.isLibraryMode) {
      _loadFromLibrary();
    } else {
      _generateStory();
    }
  }

  // ─── Chargement depuis la bibliothèque ────────────────────────────────────

  void _loadFromLibrary() {
    final saved = widget.savedStory!;
    _fullStory = saved.text;
    _storyId = saved.id;
    _isSaved = true;
    _chunks = _splitIntoChunks(_fullStory);

    // Charge l'audio depuis le cache Hive
    for (int i = 0; i < saved.audioChunkCount; i++) {
      final wav = storyLibrary.getAudioChunk(saved.id, i);
      if (wav != null) _audioCache[i] = wav;
    }

    setState(() {
      _isLoading = false;
      _displayedStory = _fullStory;
    });
  }

  // ─── Génération de l'histoire ─────────────────────────────────────────────

  Future<void> _generateStory() async {
    setState(() {
      _isLoading = true;
      _fullStory = '';
      _displayedStory = '';
      _error = null;
      _typingIndex = 0;
      _chunks = [];
      _currentChunk = 0;
      _audioCache.clear();
      _isSaved = false;
      _storyId = DateTime.now().millisecondsSinceEpoch.toString();
    });

    try {
      final service = GeminiService(widget.apiKey);
      _promptUsed = service.buildPrompt(widget.config!);

      String story;
      if (kIsWeb) {
        story = await service.generateStory(widget.config!);
      } else {
        final buffer = StringBuffer();
        await for (final chunk in service.generateStoryStream(widget.config!)) {
          buffer.write(chunk);
        }
        story = buffer.toString();
      }

      _fullStory = story;
      _chunks = _splitIntoChunks(_fullStory);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_story', _fullStory);
      await prefs.setString('last_prompt', _promptUsed);

      setState(() => _isLoading = false);
      _startTypewriter();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erreur Gemini : $e';
      });
    }
  }

  List<String> _splitIntoChunks(String text) {
    final rawParagraphs = text
        .split(RegExp(r'\n\n+'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    final chunks = <String>[];
    final buffer = StringBuffer();
    for (final para in rawParagraphs) {
      if (buffer.isNotEmpty) buffer.write('\n\n');
      buffer.write(para);
      if (buffer.length >= 400) {
        chunks.add(buffer.toString());
        buffer.clear();
      }
    }
    if (buffer.isNotEmpty) {
      if (chunks.isNotEmpty) {
        chunks[chunks.length - 1] += '\n\n${buffer.toString()}';
      } else {
        chunks.add(buffer.toString());
      }
    }
    return chunks.isEmpty ? [text] : chunks;
  }

  // ─── Typewriter ───────────────────────────────────────────────────────────

  void _startTypewriter() {
    _typingTimer?.cancel();
    _typingIndex = 0;
    setState(() => _isTyping = true);

    _typingTimer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (!mounted) { timer.cancel(); return; }
      final next = (_typingIndex + 25).clamp(0, _fullStory.length);
      setState(() {
        _typingIndex = next;
        _displayedStory = _fullStory.substring(0, next);
      });
      if (next >= _fullStory.length) {
        timer.cancel();
        setState(() => _isTyping = false);
      }
    });
  }

  // ─── Lecture TTS ──────────────────────────────────────────────────────────

  Future<void> _handlePlayButton() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() { _isPlaying = false; _isPaused = true; });
    } else if (_isPaused) {
      await _player.resume();
      setState(() { _isPlaying = true; _isPaused = false; });
    } else {
      _startPlayback();
    }
  }

  Future<void> _startPlayback() async {
    _currentChunk = 0;
    await _playChunk(0);
  }

  Future<void> _playChunk(int index) async {
    if (index >= _chunks.length) {
      setState(() { _isPlaying = false; _isPaused = false; _audioStatus = ''; });
      return;
    }

    setState(() {
      _isLoadingAudio = true;
      _ttsError = null;
      _audioStatus = 'Génération ${index + 1}/${_chunks.length}...';
    });

    try {
      Uint8List audio;
      if (_audioCache.containsKey(index)) {
        audio = _audioCache[index]!;
      } else {
        final tts = GeminiTtsService(widget.apiKey);
        audio = await tts.generateAudio(_chunks[index]);
        _audioCache[index] = audio;
        // Sauvegarde automatique du chunk audio si l'histoire est déjà sauvegardée
        if (_isSaved && _storyId != null) {
          await storyLibrary.saveAudioChunk(_storyId!, index, audio);
        }
      }

      if (!mounted) return;
      setState(() {
        _isLoadingAudio = false;
        _isPlaying = true;
        _isPaused = false;
        _audioStatus = 'Partie ${index + 1}/${_chunks.length}';
      });

      await _player.play(BytesSource(audio));
      _pregenerateChunk(index + 1);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingAudio = false;
        _isPlaying = false;
        _ttsError = 'Erreur audio : $e';
        _audioStatus = '';
      });
    }
  }

  Future<void> _pregenerateChunk(int index) async {
    if (index >= _chunks.length || _audioCache.containsKey(index) || _isPregenerating) return;
    _isPregenerating = true;
    try {
      final tts = GeminiTtsService(widget.apiKey);
      final audio = await tts.generateAudio(_chunks[index]);
      if (!mounted) return;
      _audioCache[index] = audio;
      if (_isSaved && _storyId != null) {
        await storyLibrary.saveAudioChunk(_storyId!, index, audio);
      }
    } catch (_) {
    } finally {
      _isPregenerating = false;
    }
  }

  void _onChunkComplete() {
    if (!mounted || !_isPlaying) return;
    _currentChunk++;
    _playChunk(_currentChunk);
  }

  // ─── Sauvegarde ───────────────────────────────────────────────────────────

  Future<void> _saveStory() async {
    if (_isSaved || _isSaving || _fullStory.isEmpty) return;

    setState(() {
      _isSaving = true;
      _saveStatus = 'Génération audio en cours...';
    });

    // Génère les chunks audio manquants
    final tts = GeminiTtsService(widget.apiKey);
    for (int i = 0; i < _chunks.length; i++) {
      if (!_audioCache.containsKey(i)) {
        setState(() => _saveStatus = 'Audio ${i + 1}/${_chunks.length}...');
        try {
          final audio = await tts.generateAudio(_chunks[i]);
          _audioCache[i] = audio;
        } catch (e) {
          setState(() {
            _isSaving = false;
            _ttsError = 'Erreur génération audio : $e';
            _saveStatus = '';
          });
          return;
        }
      }
    }

    // Sauvegarde en base
    final config = widget.config!;
    final story = SavedStory(
      id: _storyId!,
      title: config.storyTitle.isEmpty ? 'Mon histoire' : config.storyTitle,
      text: _fullStory,
      createdAt: DateTime.now(),
      ageLabel: config.ageCategory?.label ?? '',
      themeEmoji: config.theme?.emoji ?? '✨',
      themeLabel: config.theme?.label ?? '',
      storyTypeLabel: config.storyType?.label ?? '',
      heroName: config.heroName,
      magicObject: config.magicObject,
      audioChunkCount: _chunks.length,
    );

    await storyLibrary.saveMeta(story);
    for (int i = 0; i < _chunks.length; i++) {
      if (_audioCache.containsKey(i)) {
        await storyLibrary.saveAudioChunk(_storyId!, i, _audioCache[i]!);
      }
    }

    if (!mounted) return;
    setState(() {
      _isSaved = true;
      _isSaving = false;
      _saveStatus = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Histoire sauvegardée avec l\'audio !'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  // ─── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_showPrompt && _promptUsed.isNotEmpty) _buildPromptRecap(),
            if (_isSaving)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white12,
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            if (_saveStatus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(_saveStatus,
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ),
            Expanded(
              child: _error != null
                  ? _buildError()
                  : _isLoading
                      ? _buildLoading()
                      : _buildStory(),
            ),
            if (!_isLoading && _fullStory.isNotEmpty) _buildPlayer(),
            if (_ttsError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(_ttsError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              await _player.stop();
              if (mounted) context.pop();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          ),
          Expanded(
            child: Text(
              widget.isLibraryMode
                  ? (widget.savedStory!.title.isEmpty ? 'Mon histoire' : widget.savedStory!.title)
                  : (widget.config!.storyTitle.isEmpty ? 'Mon histoire' : widget.config!.storyTitle),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Bouton prompt (mode génération uniquement)
          if (!widget.isLibraryMode)
            IconButton(
              onPressed: () => setState(() => _showPrompt = !_showPrompt),
              icon: Icon(Icons.code, color: _showPrompt ? AppTheme.accent : Colors.white38, size: 20),
            ),
          // Bouton sauvegarder (mode génération uniquement)
          if (!widget.isLibraryMode)
            IconButton(
              onPressed: (_isSaved || _isSaving || _isLoading) ? null : _saveStory,
              tooltip: _isSaved ? 'Déjà sauvegardée' : 'Sauvegarder',
              icon: Icon(
                _isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: _isSaved ? AppTheme.accent : Colors.white54,
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPromptRecap() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_alt, color: AppTheme.accent, size: 15),
              const SizedBox(width: 6),
              const Text('Prompt Gemini', style: TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${_chunks.length} partie${_chunks.length > 1 ? 's' : ''} audio',
                  style: const TextStyle(color: Colors.white30, fontSize: 10)),
            ],
          ),
          const Divider(color: Colors.white10, height: 12),
          Text(_promptUsed,
              style: const TextStyle(color: Colors.white60, fontSize: 11, height: 1.6, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 72, height: 72,
            child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 3),
          ),
          const SizedBox(height: 24),
          const Text('✨ Gemini écrit ton histoire...', style: TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            '${widget.config?.theme?.emoji ?? ''} ${widget.config?.theme?.label ?? ''} · 🪄 ${widget.config?.magicObject ?? ''}',
            style: const TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: _displayedStory,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(color: Colors.white, fontSize: 16, height: 1.85),
                strong: const TextStyle(color: AppTheme.accent, fontSize: 16, fontWeight: FontWeight.bold),
                em: const TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
            if (_isTyping)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('▊', style: TextStyle(color: AppTheme.accent, fontSize: 16)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _generateStory, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    final bool inactive = _isTyping;
    final IconData playIcon = _isPlaying ? Icons.pause : Icons.play_arrow;
    final Color btnColor = inactive
        ? Colors.white12
        : _isPlaying ? AppTheme.secondary : _isPaused ? AppTheme.primary : AppTheme.accent;

    return Column(
      children: [
        if (_audioStatus.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(_audioStatus,
                style: TextStyle(color: _isPlaying ? AppTheme.accent : Colors.white38, fontSize: 11)),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _playerButton(
                icon: Icons.home,
                label: 'Accueil',
                onTap: () async {
                  await _player.stop();
                  if (mounted) context.go('/');
                },
              ),
              GestureDetector(
                onTap: inactive ? null : _handlePlayButton,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: btnColor,
                    boxShadow: inactive ? [] : [
                      BoxShadow(color: btnColor.withValues(alpha: 0.45), blurRadius: 14, spreadRadius: 2),
                    ],
                  ),
                  child: _isLoadingAudio
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                        )
                      : Icon(
                          inactive ? Icons.hourglass_top : playIcon,
                          color: inactive ? Colors.white30 : AppTheme.background,
                          size: 30,
                        ),
                ),
              ),
              _playerButton(
                icon: widget.isLibraryMode ? Icons.list : Icons.casino,
                label: widget.isLibraryMode ? 'Bibliothèque' : 'Recréer',
                onTap: widget.isLibraryMode
                    ? () async {
                        await _player.stop();
                        if (mounted) context.push('/library');
                      }
                    : (inactive || _isPlaying || _isPaused)
                        ? null
                        : () async {
                            await _player.stop();
                            _generateStory();
                          },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _playerButton({required IconData icon, required String label, VoidCallback? onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.cardBg,
        foregroundColor: onTap == null ? Colors.white30 : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
