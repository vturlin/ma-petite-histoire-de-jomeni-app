import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Service de génération d'histoire via la Gemini Live API (WebSocket).
/// Utilisé uniquement en mode bêta — le GeminiService reste le défaut.
class GeminiLiveService {
  final String apiKey;

  static const String _model = 'models/gemini-2.0-flash-live-001';

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

  /// Génère l'histoire en streaming via une seule boucle WebSocket.
  Stream<String> generateStoryStream(String prompt) async* {
    final uri = Uri.parse(
      'wss://generativelanguage.googleapis.com/ws/'
      'google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent'
      '?key=$apiKey',
    );

    WebSocketChannel channel;
    try {
      channel = WebSocketChannel.connect(uri);
      await channel.ready;
    } catch (e) {
      throw Exception('Live API : connexion WebSocket impossible — $e');
    }

    // Envoyer le setup
    channel.sink.add(jsonEncode({
      'setup': {
        'model': _model,
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
    String? serverError;

    // Une seule boucle pour setup + contenu
    await for (final raw in channel.stream) {
      Map<String, dynamic> data;
      try {
        data = jsonDecode(raw as String) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Live API JSON invalide: $raw');
        continue;
      }

      debugPrint('Live API ← ${raw.toString().substring(0, raw.toString().length.clamp(0, 200))}');

      // Erreur serveur
      if (data.containsKey('error')) {
        serverError = data['error'].toString();
        break;
      }

      // Phase setup
      if (!setupDone) {
        if (data.containsKey('setupComplete')) {
          setupDone = true;
          // Envoyer le prompt maintenant que le setup est confirmé
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
        // Ignorer les autres messages avant setupComplete
        continue;
      }

      // Phase contenu — extraire les chunks de texte
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

    if (serverError != null) {
      throw Exception('Live API erreur serveur : $serverError');
    }
    if (!setupDone) {
      throw Exception(
        'Live API : setupComplete non reçu. '
        'Vérifie que ton API key a accès au modèle $_model.',
      );
    }
  }
}
