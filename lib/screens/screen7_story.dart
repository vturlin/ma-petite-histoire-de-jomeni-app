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
import 'package:flutter_tts/flutter_tts.dart';
import '../services/app_settings_service.dart';
import '../services/voice_guide_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

class StoryScreen extends StatefulWidget {
  final StoryConfig? config;
  final String apiKey;
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
  final FlutterTts _nativeTts = FlutterTts();

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

  // ─── Sauvegarde ───────────────────────────────────────────────────────────
  bool _isSaved = false;
  bool _isSaving = false;
  String _saveStatus = '';
  String? _storyId;

  @override
  void initState() {
    super.initState();
    _player.setVolume(appSettings.audioVolume);
    _player.onPlayerComplete.listen((_) => _onChunkComplete());
    _nativeTts.setCompletionHandler(() => _onChunkComplete());
    if (widget.isLibraryMode) {
      _loadFromLibrary();
    } else {
      _generateStory();
    }
  }

  void _loadFromLibrary() {
    final saved = widget.savedStory!;
    _fullStory = saved.text;
    _storyId = saved.id;
    _isSaved = true;
    _chunks = _splitIntoChunks(_fullStory);
    for (int i = 0; i < saved.audioChunkCount; i++) {
      final wav = storyLibrary.getAudioChunk(saved.id, i);
      if (wav != null) _audioCache[i] = wav;
    }
    setState(() {
      _isLoading = false;
      _displayedStory = _fullStory;
    });
  }

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
        _error = 'Impossible de créer l\'histoire.\n\nVérifie ta connexion et réessaie.\n\n($e)';
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

  // Lecture depuis bibliothèque = audio Gemini sauvegardé (audioplayers)
  // Lecture en direct        = TTS natif (instantané, sans API)
  bool get _useGeminiAudio => widget.isLibraryMode;

  Future<void> _handlePlayButton() async {
    if (_useGeminiAudio) {
      // Bibliothèque : pause/reprise possible sur l'audio Gemini
      if (_isPlaying) {
        await _player.pause();
        setState(() { _isPlaying = false; _isPaused = true; });
      } else if (_isPaused) {
        await _player.resume();
        setState(() { _isPlaying = true; _isPaused = false; });
      } else {
        _currentChunk = 0;
        await _playChunk(0);
      }
    } else {
      // Lecture en direct : TTS natif (stop = seule option de pause sur Android)
      if (_isPlaying) {
        await _nativeTts.stop();
        setState(() { _isPlaying = false; _isPaused = false; });
      } else {
        _currentChunk = 0;
        await _playChunk(0);
      }
    }
  }

  Future<void> _playChunk(int index) async {
    if (index >= _chunks.length) {
      setState(() { _isPlaying = false; _isPaused = false; _audioStatus = ''; });
      return;
    }

    // ── TTS natif (lecture en direct) ───────────────────────────────────────
    if (!_useGeminiAudio) {
      setState(() {
        _isPlaying = true;
        _isPaused = false;
        _audioStatus = 'Partie ${index + 1}/${_chunks.length}';
        _ttsError = null;
      });
      try {
        await voiceGuide.stop();
        final name   = appSettings.voiceName;
        final locale = appSettings.voiceLocale;
        await _nativeTts.setLanguage(locale ?? 'fr-FR');
        if (name != null && locale != null) {
          await _nativeTts.setVoice({'name': name, 'locale': locale});
        }
        await _nativeTts.setSpeechRate(appSettings.speechRate);
        await _nativeTts.setVolume(appSettings.speechVolume);
        await _nativeTts.setPitch(appSettings.speechPitch);
        await _nativeTts.speak(_chunks[index]);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isPlaying = false;
          _ttsError = '🎙️ Erreur voix native : $e';
          _audioStatus = '';
        });
      }
      return;
    }

    // ── Audio Gemini sauvegardé (bibliothèque) ──────────────────────────────
    setState(() {
      _isLoadingAudio = true;
      _ttsError = null;
      _audioStatus = 'Chargement ${index + 1}/${_chunks.length}...';
    });

    try {
      final audio = _audioCache[index];
      if (audio == null) throw Exception('Audio introuvable pour ce chunk.');

      if (!mounted) return;
      setState(() {
        _isLoadingAudio = false;
        _isPlaying = true;
        _isPaused = false;
        _audioStatus = 'Partie ${index + 1}/${_chunks.length}';
      });

      await _player.setVolume(appSettings.audioVolume);
      await _player.play(BytesSource(audio));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingAudio = false;
        _isPlaying = false;
        _ttsError = '🎙️ Lecture impossible. $e';
        _audioStatus = '';
      });
    }
  }

  void _onChunkComplete() {
    if (!mounted || !_isPlaying) return;
    _currentChunk++;
    _playChunk(_currentChunk);
  }

  Future<void> _saveStory() async {
    if (_isSaved || _isSaving || _fullStory.isEmpty) return;

    setState(() {
      _isSaving = true;
      _saveStatus = 'Génération audio en cours...';
    });

    final tts = GeminiTtsService(widget.apiKey);
    for (int i = 0; i < _chunks.length; i++) {
      if (!_audioCache.containsKey(i)) {
        setState(() => _saveStatus = 'Audio ${i + 1}/${_chunks.length}...');
        try {
          if (i > 0) {
            for (int s = 22; s > 0; s--) {
              if (!mounted) return;
              setState(() => _saveStatus = 'Audio ${i + 1}/${_chunks.length} (attente ${s}s...)');
              await Future.delayed(const Duration(seconds: 1));
            }
          }
          if (!mounted) return;
          setState(() => _saveStatus = 'Audio ${i + 1}/${_chunks.length}...');
          final audio = await tts.generateAudio(_chunks[i]);
          _audioCache[i] = audio;
        } catch (e) {
          if (!mounted) return;
          final msg = e.toString();
          setState(() {
            _isSaving = false;
            _ttsError = msg.contains('429') || msg.contains('RESOURCE_EXHAUSTED')
                ? '⏳ Quota audio dépassé. Réessaie dans 1 minute.'
                : '🎙️ Génération audio échouée. Réessaie.';
            _saveStatus = '';
          });
          return;
        }
      }
    }

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
        content: const Text('✅ Histoire sauvegardée !'),
        backgroundColor: AppColors.accent2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.all(AppRadius.md)),
      ),
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _player.dispose();
    _nativeTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            if (_isSaving)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s20, vertical: AppSpacing.s4),
                child: ClipRRect(
                  borderRadius: AppRadius.all(4),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: AppColors.paper2,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent2),
                  ),
                ),
              ),
            if (_saveStatus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s4),
                child: Text(_saveStatus, style: AppText.bodySmall),
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
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s8),
                child: Text(_ttsError!,
                    textAlign: TextAlign.center,
                    style: AppText.bodySmall
                        .copyWith(color: const Color(0xFFB3261E))),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final title = widget.isLibraryMode
        ? (widget.savedStory!.title.isEmpty ? 'Mon histoire' : widget.savedStory!.title)
        : (widget.config!.storyTitle.isEmpty ? 'Mon histoire' : widget.config!.storyTitle);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, AppSpacing.s8),
      child: Row(
        children: [
          _RoundBtn(
            icon: Icons.arrow_back,
            onTap: () async {
              await _player.stop();
              if (mounted) context.pop();
            },
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!widget.isLibraryMode)
            _RoundBtn(
              icon: _showPrompt ? Icons.code_off : Icons.code,
              onTap: () => setState(() => _showPrompt = !_showPrompt),
              active: _showPrompt,
            )
          else
            const SizedBox(width: AppSize.iconBtnTopbar),
          const SizedBox(width: AppSpacing.s8),
          if (!widget.isLibraryMode)
            _RoundBtn(
              icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
              onTap: (_isSaved || _isSaving || _isLoading) ? null : _saveStory,
              active: _isSaved,
            )
          else
            const SizedBox(width: AppSize.iconBtnTopbar),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110, height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accentSoft, AppColors.accent1],
              ),
              boxShadow: AppShadows.cta,
            ),
            child: const Center(
              child: Text('📖', style: TextStyle(fontSize: 52)),
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          Text('Gemini écrit ton histoire…', style: AppText.headlineMedium),
          const SizedBox(height: AppSpacing.s8),
          Text(
            '${widget.config?.theme?.emoji ?? ''} ${widget.config?.theme?.label ?? ''}',
            style: AppText.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.s32),
          const CircularProgressIndicator(color: AppColors.accent2, strokeWidth: 3),
        ],
      ),
    );
  }

  Widget _buildStory() {
    return Column(
      children: [
        if (_showPrompt && _promptUsed.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(
                AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s8),
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: AppRadius.all(AppRadius.md),
              border: Border.all(color: AppColors.accent2, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.psychology_alt,
                      color: AppColors.accent2, size: 14),
                  const SizedBox(width: AppSpacing.s4),
                  Text('Prompt Gemini',
                      style: AppText.bodySmall
                          .copyWith(color: AppColors.accentInk,
                              fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: AppSpacing.s4),
                Text(_promptUsed,
                    style: AppText.bodySmall
                        .copyWith(fontFamily: 'monospace')),
              ],
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20, 0, AppSpacing.s20, AppSpacing.s8),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.all(AppRadius.xl),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: _displayedStory,
                    styleSheet: MarkdownStyleSheet(
                      p: AppText.bodyLarge.copyWith(height: 1.85),
                      strong: AppText.bodyLarge.copyWith(
                          color: AppColors.accentInk,
                          fontWeight: FontWeight.w700),
                      em: AppText.bodyLarge.copyWith(
                          color: AppColors.inkSoft,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                  if (_isTyping)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.s4),
                      child: Text('▊',
                          style: AppText.bodyLarge
                              .copyWith(color: AppColors.accent2)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.s16),
            Text(_error!,
                textAlign: TextAlign.center, style: AppText.bodyMedium),
            const SizedBox(height: AppSpacing.s24),
            Container(
              decoration: BoxDecoration(
                  borderRadius: AppRadius.all(AppRadius.xl),
                  boxShadow: AppShadows.cta),
              child: ElevatedButton(
                  onPressed: _generateStory,
                  child: const Text('Réessayer')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    final bool inactive = _isTyping;
    final IconData playIcon =
        _isPlaying ? Icons.pause : Icons.play_arrow;
    final Color btnColor = inactive
        ? AppColors.line
        : _isPlaying
            ? AppColors.sky
            : _isPaused
                ? AppColors.accent1
                : AppColors.accent2;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.s16),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s20, vertical: AppSpacing.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.all(AppRadius.xl),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8, vertical: 3),
                decoration: BoxDecoration(
                  color: _useGeminiAudio ? AppColors.accentSoft : AppColors.mint,
                  borderRadius: AppRadius.all(AppRadius.xs),
                ),
                child: Text(
                  _useGeminiAudio ? '🤖 Audio Gemini' : '📱 Voix native',
                  style: AppText.bodySmall
                      .copyWith(color: AppColors.accentInk),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          if (_audioStatus.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s8),
              child: Text(_audioStatus,
                  style: AppText.bodySmall.copyWith(
                      color: _isPlaying
                          ? AppColors.accent2
                          : AppColors.inkMute)),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _playerBtn(
                icon: Icons.home_outlined,
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
                  width: AppSize.iconBtnPlay,
                  height: AppSize.iconBtnPlay,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: btnColor,
                    boxShadow: inactive ? [] : AppShadows.cta,
                  ),
                  child: _isLoadingAudio
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white),
                        )
                      : Icon(
                          inactive ? Icons.hourglass_top : playIcon,
                          color: inactive
                              ? AppColors.inkMute
                              : Colors.white,
                          size: 32,
                        ),
                ),
              ),
              _playerBtn(
                icon: widget.isLibraryMode
                    ? Icons.list_outlined
                    : Icons.casino_outlined,
                label: widget.isLibraryMode ? 'Biblio.' : 'Recréer',
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
        ],
      ),
    );
  }

  Widget _playerBtn({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: enabled ? AppColors.accentSoft : AppColors.paper2,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: enabled ? AppColors.accent2 : AppColors.inkMute,
                size: 22),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(label,
              style: AppText.bodySmall.copyWith(
                  color: enabled ? AppColors.ink : AppColors.inkMute)),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;

  const _RoundBtn({required this.icon, this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSize.iconBtnTopbar,
        height: AppSize.iconBtnTopbar,
        decoration: BoxDecoration(
          color: active ? AppColors.accentSoft : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? AppColors.accent2 : AppColors.line,
            width: 1.5,
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Icon(icon,
            color: active ? AppColors.accent2 : AppColors.ink, size: 18),
      ),
    );
  }
}
