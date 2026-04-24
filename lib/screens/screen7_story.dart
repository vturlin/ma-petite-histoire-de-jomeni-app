import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  String? _story;
  bool _isLoading = true;
  bool _isPlaying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateStory();
    _setupTts();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1);
    _tts.setCompletionHandler(() => setState(() => _isPlaying = false));
  }

  Future<void> _generateStory() async {
    try {
      final service = GeminiService(widget.apiKey);
      final story = await service.generateStory(widget.config);
      setState(() {
        _story = story;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Impossible de créer l\'histoire. Vérifie ta connexion.';
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _tts.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      await _tts.speak(_story!);
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? _buildLoading()
                  : _error != null
                      ? _buildError()
                      : _buildStory(),
            ),
            if (_story != null) _buildPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              color: AppTheme.accent,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '✨ Gemini crée ton histoire...',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'avec ${widget.config.theme?.label ?? ""} et ${widget.config.magicObject}',
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
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
            const Text('😕', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _generateStory();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          _story!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            height: 1.8,
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              context.go('/');
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Nouvelle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cardBg,
            ),
          ),
          GestureDetector(
            onTap: _togglePlayback,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isPlaying ? AppTheme.secondary : AppTheme.accent,
                boxShadow: [
                  BoxShadow(
                    color: (_isPlaying ? AppTheme.secondary : AppTheme.accent)
                        .withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppTheme.background,
                size: 36,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await _tts.stop();
              setState(() {
                _isLoading = true;
                _story = null;
                _isPlaying = false;
              });
              _generateStory();
            },
            icon: const Icon(Icons.casino),
            label: const Text('Recréer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.cardBg,
            ),
          ),
        ],
      ),
    );
  }
}
