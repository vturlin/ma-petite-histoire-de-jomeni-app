import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Service bêta : génération de texte via gemini-3-flash-preview.
/// Même architecture que GeminiService, modèle plus récent.
/// L'audio TTS reste identique à la version normale.
class GeminiLiveService {
  static const String model = 'gemini-3-flash-preview';

  late final GenerativeModel _model;

  GeminiLiveService(String apiKey) {
    _model = GenerativeModel(
      model: model,
      apiKey: apiKey,
      systemInstruction: Content.system(
        'Tu es un auteur de contes pour enfants. '
        'Ton but est de produire un récit fleuri, vivant et immersif. '
        'Ne résume jamais l\'histoire : raconte-la avec des détails sensoriels, '
        'des dialogues simples et des images poétiques. '
        'L\'histoire doit toujours comporter une introduction, une aventure '
        'avec l\'objet magique, et une fin douce et positive. '
        'Vocabulaire adapté à l\'âge indiqué. Pas de violence, pas de peur excessive. '
        'IMPORTANT : le texte sera lu à voix haute par un moteur TTS. '
        'Soigne la ponctuation pour une lecture naturelle. '
        'Écris uniquement le récit, sans titre ni introduction de ta part.',
      ),
      generationConfig: GenerationConfig(
        temperature: 0.9,
        maxOutputTokens: 2048,
      ),
    );
  }

  Stream<String> generateStoryStream(String prompt) async* {
    debugPrint('Bêta → $model');
    final response = _model.generateContentStream([Content.text(prompt)]);
    await for (final chunk in response) {
      final text = chunk.text;
      if (text != null && text.isNotEmpty) yield text;
    }
  }
}
