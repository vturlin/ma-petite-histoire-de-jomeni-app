import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story_config.dart';
import '../services/gemini_service.dart';
import '../services/gemini_tts_service.dart';
import '../theme/app_theme.dart';

class StoryScreen extends StatefulWidget {
  final StoryConfig config;
  final String apiKey;

  const StoryScreen({super.key, required this.config, required this.apiKey});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final AudioPlayer _player = AudioPlayer();

  // --- Texte ---
  String _fullStory = '';
  String _displayedStory = '';
  String _promptUsed = '';
  bool _isLoading = true;
  bool _isTyping = false;
  bool _showPrompt = false;
  String? _error;

  Timer? _typingTimer;
  int _typingIndex = 0;

  // --- TTS / Lecture ---
  // État de lecture : idle | loadingAudio | playing | paused
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isLoadingAudio = false;
  String _audioStatus = '';
  String? _ttsError;

  // Chunking : un paragraphe à la fois
  List<String> _chunks = [];
  int _currentChunk = 0;
  final Map<int, Uint8List> _audioCache = {}; // audio pré-généré par index
  bool _isPregenerating = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) => _onChunkComplete());
    _generateStory();
  }

  // ─── Génération de l'histoire ────────────────────────────────────────────

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
    });

    try {
      final service = GeminiService(widget.apiKey);
      _promptUsed = service.buildPrompt(widget.config);

      String story;
      if (kIsWeb) {
        story = await service.generateStory(widget.config);
      } else {
        final buffer = StringBuffer();
        await for (final chunk in service.generateStoryStream(widget.config)) {
          buffer.write(chunk);
        }
        story = buffer.toString();
      }

      _fullStory = story;
      _chunks = _splitIntoChunks(_fullStory);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_story', _fullStory);
      await prefs.setString('last_prompt', _promptUsed);
      await prefs.setString('last_story_title', widget.config.storyTitle);

      setState(() => _isLoading = false);
      _startTypewriter();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erreur Gemini : $e';
      });
    }
  }

  /// Découpe l'histoire en paragraphes d'environ 400-600 caractères.
  List<String> _splitIntoChunks(String text) {
    final rawParagraphs = text
        .split(RegExp(r'\n\n+'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    // Fusionne les paragraphes trop courts pour atteindre ~400 chars
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
    debugPrint('TTS chunks : ${chunks.length} (tailles : ${chunks.map((c) => c.length).join(', ')})');
    return chunks.isEmpty ? [text] : chunks;
  }

  // ─── Animation machine à écrire ──────────────────────────────────────────

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

  // ─── Lecture TTS ─────────────────────────────────────────────────────────

  Future<void> _handlePlayButton() async {
    if (_isPlaying) {
      // → Pause (garde la position dans le chunk)
      await _player.pause();
      setState(() { _isPlaying = false; _isPaused = true; });
    } else if (_isPaused) {
      // → Reprise exactement où on s'était arrêté
      await _player.resume();
      setState(() { _isPlaying = true; _isPaused = false; });
    } else {
      // → Démarrage depuis le début
      _startPlayback();
    }
  }

  Future<void> _startPlayback() async {
    _currentChunk = 0;
    _audioCache.clear();
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
        debugPrint('TTS chunk $index : depuis le cache');
      } else {
        final tts = GeminiTtsService(widget.apiKey);
        audio = await tts.generateAudio(_chunks[index]);
        _audioCache[index] = audio;
      }

      if (!mounted) return;
      setState(() {
        _isLoadingAudio = false;
        _isPlaying = true;
        _isPaused = false;
        _audioStatus = 'Partie ${index + 1}/${_chunks.length}';
      });

      await _player.play(BytesSource(audio));

      // Pré-génère le chunk suivant en arrière-plan pendant la lecture
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

  /// Pré-génère un chunk en arrière-plan sans bloquer la lecture.
  Future<void> _pregenerateChunk(int index) async {
    if (index >= _chunks.length || _audioCache.containsKey(index) || _isPregenerating) {
      return;
    }
    _isPregenerating = true;
    try {
      final tts = GeminiTtsService(widget.apiKey);
      final audio = await tts.generateAudio(_chunks[index]);
      if (mounted) _audioCache[index] = audio;
      debugPrint('TTS chunk $index pré-généré (${audio.length} bytes)');
    } catch (e) {
      debugPrint('TTS pré-génération chunk $index échouée : $e');
    } finally {
      _isPregenerating = false;
    }
  }

  /// Appelé automatiquement quand un chunk se termine.
  void _onChunkComplete() {
    if (!mounted || !_isPlaying) return;
    _currentChunk++;
    _playChunk(_currentChunk);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  // ─── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_showPrompt && _promptUsed.isNotEmpty) _buildPromptRecap(),
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
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: Text(
                  _ttsError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                ),
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
              if (mounted) context.go('/');
            },
            icon: const Icon(Icons.home, color: Colors.white70),
          ),
          Expanded(
            child: Text(
              widget.config.storyTitle.isEmpty ? 'Mon histoire' : widget.config.storyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showPrompt = !_showPrompt),
            tooltip: 'Voir le prompt envoyé',
            icon: Icon(
              Icons.code,
              color: _showPrompt ? AppTheme.accent : Colors.white38,
              size: 20,
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
              const Text(
                'Prompt envoyé à Gemini',
                style: TextStyle(
                  color: AppTheme.accent, fontSize: 11,
                  fontWeight: FontWeight.bold, letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                '${_chunks.length} partie${_chunks.length > 1 ? 's' : ''} audio',
                style: const TextStyle(color: Colors.white30, fontSize: 10),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 12),
          Text(
            _promptUsed,
            style: const TextStyle(
              color: Colors.white60, fontSize: 11, height: 1.6, fontFamily: 'monospace',
            ),
          ),
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
            '${widget.config.theme?.emoji ?? ''} ${widget.config.theme?.label ?? ''} · 🪄 ${widget.config.magicObject}',
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
    // Icône et couleur du bouton central selon l'état
    final bool inactive = _isTyping;
    final IconData playIcon = _isPlaying ? Icons.pause : Icons.play_arrow;
    final Color btnColor = inactive
        ? Colors.white12
        : _isPlaying
            ? AppTheme.secondary
            : _isPaused
                ? AppTheme.primary
                : AppTheme.accent;

    return Column(
      children: [
        // Indicateur de progression audio
        if (_audioStatus.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              _audioStatus,
              style: TextStyle(
                color: _isPlaying ? AppTheme.accent : Colors.white38,
                fontSize: 11,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _playerButton(icon: Icons.refresh, label: 'Nouvelle', onTap: () async {
                await _player.stop();
                if (mounted) context.go('/');
              }),
              // Bouton lecture central
              GestureDetector(
                onTap: inactive ? null : _handlePlayButton,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: btnColor,
                    boxShadow: inactive ? [] : [
                      BoxShadow(
                        color: btnColor.withValues(alpha: 0.45),
                        blurRadius: 14, spreadRadius: 2,
                      ),
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
                icon: Icons.casino,
                label: 'Recréer',
                onTap: (inactive || _isPlaying || _isPaused) ? null : () async {
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
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.cardBg,
        foregroundColor: onTap == null ? Colors.white30 : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(fontSize: 13),
      ),
    );
  }
}
