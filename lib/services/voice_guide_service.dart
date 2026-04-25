import 'package:flutter_tts/flutter_tts.dart';

class VoiceGuideService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.82);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.1);
    _initialized = true;
  }

  Future<void> speak(String text) async {
    await _init();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async => _tts.stop();
}

final voiceGuide = VoiceGuideService();
