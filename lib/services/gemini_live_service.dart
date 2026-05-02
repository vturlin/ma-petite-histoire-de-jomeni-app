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

  /// Génère l'histoire en streaming via WebSocket.
  /// Prend le prompt déjà construit (réutilise GeminiService.buildPrompt).
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
      throw Exception('Live API : connexion impossible — $e');
    }

    // ── 1. Setup ────────────────────────────────────────────────────────────
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

    // ── 2. Attendre setupComplete ────────────────────────────────────────────
    bool setupDone = false;
    await for (final raw in channel.stream) {
      debugPrint('Live API setup: $raw');
      try {
        final msg = jsonDecode(raw as String) as Map<String, dynamic>;
        if (msg.containsKey('setupComplete')) {
          setupDone = true;
          break;
        }
      } catch (_) {}
    }

    if (!setupDone) {
      await channel.sink.close();
      throw Exception('Live API : setupComplete non reçu.');
    }

    // ── 3. Envoyer le prompt ─────────────────────────────────────────────────
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

    // ── 4. Streamer les chunks de texte ──────────────────────────────────────
    await for (final raw in channel.stream) {
      try {
        final data = jsonDecode(raw as String) as Map<String, dynamic>;
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
      } catch (e) {
        debugPrint('Live API parse error: $e');
      }
    }

    await channel.sink.close();
  }
}
