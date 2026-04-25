import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiTtsService {
  final String apiKey;

  static const String _voice = 'Aoede';
  static const Duration _timeout = Duration(seconds: 90);

  GeminiTtsService(this.apiKey);

  Future<Uint8List> generateAudio(String text, {int maxRetries = 5}) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      'gemini-3.1-flash-tts-preview:generateContent?key=$apiKey',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [{'text': text}],
        }
      ],
      'generationConfig': {
        'responseModalities': ['AUDIO'],
        'speechConfig': {
          'voiceConfig': {
            'prebuiltVoiceConfig': {'voiceName': _voice},
          },
        },
      },
    });

    http.Response? response;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      debugPrint('TTS → tentative $attempt/$maxRetries (${text.length} chars)...');
      try {
        response = await http
            .post(url, headers: {'Content-Type': 'application/json'}, body: body)
            .timeout(_timeout);
      } on TimeoutException {
        throw Exception('TTS timeout (>${_timeout.inSeconds}s)');
      }

      debugPrint('TTS → HTTP ${response.statusCode}');

      if (response.statusCode == 200) {
        // Succès — on sort de la boucle
        break;
      }

      if (response.statusCode == 429) {
        // Rate limit : on lit le délai suggéré par l'API
        final retryDelay = _parseRetryDelay(response.body);
        debugPrint('TTS → 429 rate limit, attente ${retryDelay}s...');
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: retryDelay));
          continue;
        }
      }

      // Erreur non récupérable
      throw Exception('TTS HTTP ${response.statusCode}: ${response.body}');
    }

    if (response == null || response.statusCode != 200) {
      throw Exception('TTS : échec après $maxRetries tentatives.');
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('TTS réponse JSON invalide : $e');
    }

    final candidate = (data['candidates'] as List?)?.firstOrNull;
    if (candidate == null) {
      throw Exception('TTS : aucun candidat dans la réponse.\n${response.body}');
    }

    final parts = (candidate['content']?['parts'] as List?);
    if (parts == null || parts.isEmpty) {
      throw Exception('TTS : aucune partie audio dans la réponse.');
    }

    final inlineData = parts.first['inlineData'] as Map<String, dynamic>?;
    if (inlineData == null) {
      throw Exception('TTS : inlineData absent — modèle non supporté ?');
    }

    final mimeType = inlineData['mimeType'] as String;
    final base64Audio = inlineData['data'] as String;
    final pcmBytes = base64Decode(base64Audio);

    final rateMatch = RegExp(r'rate=(\d+)').firstMatch(mimeType);
    final originalRate = int.parse(rateMatch?.group(1) ?? '24000');

    // Downsample 24kHz → 16kHz : -50% de taille, qualité largement suffisante
    final pcmFinal = originalRate == 24000
        ? _downsample24to16kHz(pcmBytes)
        : pcmBytes;
    const targetRate = 16000;

    debugPrint(
      'TTS → OK : ${pcmBytes.length} bytes @ ${originalRate}Hz '
      '→ ${pcmFinal.length} bytes @ ${targetRate}Hz',
    );

    return _pcmToWav(pcmFinal, sampleRate: targetRate);
  }

  /// Extrait le délai de retry suggéré par l'API (en secondes) depuis le body 429.
  int _parseRetryDelay(String body) {
    try {
      final match = RegExp(r'retry in (\d+(?:\.\d+)?)s').firstMatch(body);
      if (match != null) {
        return (double.parse(match.group(1)!) + 1).ceil();
      }
    } catch (_) {}
    return 25; // délai par défaut si non parseable
  }

  /// Downsample PCM 16-bit mono de 24kHz à 16kHz (ratio 2/3).
  /// Garde 2 samples sur 3, sans filtre anti-repliement (suffisant pour la voix).
  Uint8List _downsample24to16kHz(Uint8List pcm24) {
    final builder = BytesBuilder(copy: false);
    for (int i = 0; i + 1 < pcm24.length; i += 6) {
      // Garde les 2 premiers samples (4 bytes), saute le 3ème (2 bytes)
      final end = (i + 4).clamp(0, pcm24.length);
      builder.add(pcm24.sublist(i, end));
    }
    return builder.toBytes();
  }

  Uint8List _pcmToWav(Uint8List pcm, {int sampleRate = 24000}) {
    const int numChannels = 1;
    const int bitsPerSample = 16;
    final int byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    final int blockAlign = numChannels * bitsPerSample ~/ 8;
    final int dataSize = pcm.length;
    final int fileSize = 36 + dataSize;

    final header = ByteData(44);

    void writeStr(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        header.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    writeStr(0, 'RIFF');
    header.setUint32(4, fileSize, Endian.little);
    writeStr(8, 'WAVE');
    writeStr(12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    writeStr(36, 'data');
    header.setUint32(40, dataSize, Endian.little);

    final wav = Uint8List(44 + pcm.length);
    wav.setAll(0, header.buffer.asUint8List());
    wav.setAll(44, pcm);
    return wav;
  }
}
