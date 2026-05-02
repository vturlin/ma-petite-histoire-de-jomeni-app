import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Service bêta : génération via Gemini Live API (WebSocket bidirectionnel).
class GeminiLiveService {
  final String apiKey;

  // Modèles à tester dans l'ordre — on prend le premier qui répond setupComplete
  static const List<String> _candidates = [
    'models/gemini-2.5-flash',
    'models/gemini-2.0-flash',
    'models/gemini-2.0-flash-001',
  ];

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
    String? lastError;

    for (final model in _candidates) {
      debugPrint('Live API → tentative avec $model');
      try {
        var hasContent = false;
        await for (final chunk in _tryModel(model, prompt)) {
          hasContent = true;
          yield chunk;
        }
        if (hasContent) return; // succès
      } catch (e) {
        debugPrint('Live API ✗ $model : $e');
        lastError = e.toString();
      }
    }

    throw Exception('Live API : aucun modèle disponible. Dernière erreur : $lastError');
  }

  Stream<String> _tryModel(String model, String prompt) async* {
    final uri = Uri.parse(
      'wss://generativelanguage.googleapis.com/ws/'
      'google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent'
      '?key=$apiKey',
    );

    final channel = WebSocketChannel.connect(uri);
    await channel.ready;

    // Setup
    channel.sink.add(jsonEncode({
      'setup': {
        'model': model,
        'systemInstruction': {
          'parts': [
            {'text': _system}
          ],
        },
        'generationConfig': {
          'responseModalities': ['TEXT'],
          'temperature': 0.9,
          'maxOutputTokens': 2048,
        },
      },
    }));

    bool setupDone = false;

    await for (final raw in channel.stream) {
      Map<String, dynamic> data;
      try {
        data = jsonDecode(raw as String) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }

      debugPrint('← ${raw.toString().substring(0, raw.toString().length.clamp(0, 150))}');

      // Erreur serveur
      if (data.containsKey('error')) {
        await channel.sink.close();
        throw Exception(data['error'].toString());
      }

      // Phase setup
      if (!setupDone) {
        if (data.containsKey('setupComplete')) {
          setupDone = true;
          channel.sink.add(jsonEncode({
            'clientContent': {
              'turns': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': prompt}
                  ],
                }
              ],
              'turnComplete': true,
            },
          }));
        }
        continue;
      }

      // Phase contenu
      final sc = data['serverContent'] as Map<String, dynamic>?;
      if (sc == null) continue;

      final modelTurn = sc['modelTurn'] as Map<String, dynamic>?;
      if (modelTurn != null) {
        final parts = modelTurn['parts'] as List? ?? [];
        for (final part in parts) {
          final text = (part as Map<String, dynamic>)['text'] as String?;
          if (text != null && text.isNotEmpty) yield text;
        }
      }

      if (sc['turnComplete'] == true) break;
    }

    await channel.sink.close();

    if (!setupDone) {
      throw Exception('setupComplete non reçu pour $model');
    }
  }
}
