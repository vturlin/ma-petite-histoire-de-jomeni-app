import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Service bêta : génération via gemini-3-flash-preview.
/// Utilise le streaming HTTP classique (plus stable que WebSocket Live).
class GeminiLiveService {
  final String apiKey;

  static const String _model = 'gemini-3-flash-preview';

  static const String _system =
      'Tu es un auteur de contes pour enfants. '
      'Ton but est de produire un récit fleuri, vivant et immersif. '
      'Ne résume jamais l\'histoire : raconte-la avec des détails sensoriels, '
      'des dialogues simples et des images poétiques. '
      'L\'histoire doit toujours comporter une introduction, une aventure '
      'avec l\'objet magique, et une fin douce et positive. '
      'Vocabulaire adapté à l\'âge indiqué. Pas de violence, pas de peur excessive. '
      'IMPORTANT : le texte sera lu à voix haute par un moteur TTS. '
      'Soigne la ponctuation pour une lecture naturelle. '
      'Écris uniquement le récit, sans titre ni introduction de ta part.';

  GeminiLiveService(this.apiKey);

  Stream<String> generateStoryStream(String prompt) async* {
    debugPrint('Beta → modèle : $_model');

    final model = GenerativeModel(
      model: _model,
      apiKey: apiKey,
      systemInstruction: Content.system(_system),
      generationConfig: GenerationConfig(
        temperature: 0.9,
        maxOutputTokens: 2048,
      ),
    );

    final response = model.generateContentStream([Content.text(prompt)]);
    await for (final chunk in response) {
      final text = chunk.text;
      if (text != null && text.isNotEmpty) yield text;
    }
  }
}
