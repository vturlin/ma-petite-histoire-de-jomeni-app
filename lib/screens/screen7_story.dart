import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story_config.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';

class StoryScreen extends StatefulWidget {
  final StoryConfig config;
  final String apiKey;

  const StoryScreen({super.key, required this.config, required this.apiKey});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final FlutterTts _tts = FlutterTts();

  String _fullStory = '';
  String _displayedStory = '';
  String _promptUsed = '';
  bool _isLoading = true;
  bool _isTyping = false;
  bool _isPlaying = false;
  bool _showPrompt = false;
  String? _error;

  Timer? _typingTimer;
  int _typingIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupTts();
    _generateStory();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(kIsWeb ? 0.9 : 0.55);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05);

    // Sur mobile : sélectionne la meilleure voix française disponible
    if (!kIsWeb) {
      final voices = await _tts.getVoices;
      if (voices != null) {
        final frVoices = (voices as List)
            .where((v) => v['locale']?.toString().startsWith('fr') ?? false)
            .toList();
        if (frVoices.isNotEmpty) {
          await _tts.setVoice({
            'name': frVoices.first['name'],
            'locale': 'fr-FR',
          });
        }
      }
    }

    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  Future<void> _generateStory() async {
    setState(() {
      _isLoading = true;
      _fullStory = '';
      _displayedStory = '';
      _error = null;
      _typingIndex = 0;
    });

    try {
      final service = GeminiService(widget.apiKey);
      _promptUsed = service.buildPrompt(widget.config);

      String story;

      if (kIsWeb) {
        // Web : génération complète en un seul appel
        story = await service.generateStory(widget.config);
      } else {
        // Mobile : streaming natif
        final buffer = StringBuffer();
        await for (final chunk in service.generateStoryStream(widget.config)) {
          buffer.write(chunk);
        }
        story = buffer.toString();
      }

      _fullStory = story;

      // Mise en cache locale
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

  void _startTypewriter() {
    _typingTimer?.cancel();
    _typingIndex = 0;
    setState(() => _isTyping = true);

    // 25 caractères toutes les 25ms ≈ 1000 car/s → histoire complète en ~2s
    _typingTimer = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
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

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _tts.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      await _tts.speak(_fullStory);
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

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
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home, color: Colors.white70),
          ),
          Expanded(
            child: Text(
              widget.config.storyTitle.isEmpty
                  ? 'Mon histoire'
                  : widget.config.storyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Bouton prompt recap
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.35),
        ),
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
                  color: AppTheme.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                kIsWeb ? 'Web · génération complète' : 'Mobile · streaming',
                style: const TextStyle(color: Colors.white30, fontSize: 10),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 12),
          Text(
            _promptUsed,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
              height: 1.6,
              fontFamily: 'monospace',
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
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              color: AppTheme.accent,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '✨ Gemini écrit ton histoire...',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
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
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: _displayedStory,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.85,
                ),
                strong: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                em: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            if (_isTyping)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '▊',
                  style: TextStyle(color: AppTheme.accent, fontSize: 16),
                ),
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
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _generateStory,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _playerButton(
            icon: Icons.refresh,
            label: 'Nouvelle',
            onTap: () => context.go('/'),
          ),
          // Bouton lecture central
          GestureDetector(
            onTap: _isTyping ? null : _togglePlayback,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isTyping
                    ? Colors.white12
                    : _isPlaying
                        ? AppTheme.secondary
                        : AppTheme.accent,
                boxShadow: _isTyping
                    ? []
                    : [
                        BoxShadow(
                          color: (_isPlaying
                                  ? AppTheme.secondary
                                  : AppTheme.accent)
                              .withValues(alpha: 0.45),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
              ),
              child: Icon(
                _isTyping
                    ? Icons.hourglass_top
                    : _isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                color: _isTyping ? Colors.white30 : AppTheme.background,
                size: 30,
              ),
            ),
          ),
          _playerButton(
            icon: Icons.casino,
            label: 'Recréer',
            onTap: _isTyping ? null : _generateStory,
          ),
        ],
      ),
    );
  }

  Widget _playerButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
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
