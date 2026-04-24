import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/saved_story.dart';

/// Stocke les histoires (texte + metadata) et les chunks audio (Uint8List)
/// dans deux boxes Hive séparées pour éviter de charger l'audio en mémoire
/// lors de l'affichage de la bibliothèque.
class StoryLibraryService {
  static const String _metaBox = 'stories_meta';
  static const String _audioBox = 'stories_audio';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(_metaBox);
    await Hive.openBox<Uint8List>(_audioBox);
  }

  Box<Map> get _meta => Hive.box<Map>(_metaBox);
  Box<Uint8List> get _audio => Hive.box<Uint8List>(_audioBox);

  /// Sauvegarde le texte et les métadonnées de l'histoire.
  Future<void> saveMeta(SavedStory story) async {
    await _meta.put(story.id, story.toMap());
  }

  /// Sauvegarde un chunk audio (WAV 16kHz) pour une histoire.
  Future<void> saveAudioChunk(String storyId, int index, Uint8List wav) async {
    await _audio.put('${storyId}_$index', wav);
    // Met à jour le compteur dans les métadonnées
    final meta = Map<dynamic, dynamic>.from(_meta.get(storyId) ?? {});
    final current = meta['audioChunkCount'] as int? ?? 0;
    if (index >= current) {
      meta['audioChunkCount'] = index + 1;
      await _meta.put(storyId, meta);
    }
  }

  /// Récupère un chunk audio par index.
  Uint8List? getAudioChunk(String storyId, int index) =>
      _audio.get('${storyId}_$index');

  /// Récupère tous les chunks audio d'une histoire dans l'ordre.
  List<Uint8List> getAllAudioChunks(String storyId, int count) {
    final chunks = <Uint8List>[];
    for (int i = 0; i < count; i++) {
      final chunk = _audio.get('${storyId}_$i');
      if (chunk != null) chunks.add(chunk);
    }
    return chunks;
  }

  /// Liste toutes les histoires, triées par date décroissante.
  List<SavedStory> getAll() {
    return _meta.values
        .map((m) => SavedStory.fromMap(m))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Supprime une histoire et tous ses chunks audio.
  Future<void> delete(String storyId) async {
    final story = _meta.get(storyId);
    if (story != null) {
      final count = story['audioChunkCount'] as int? ?? 0;
      for (int i = 0; i < count; i++) {
        await _audio.delete('${storyId}_$i');
      }
    }
    await _meta.delete(storyId);
  }

  int get count => _meta.length;
}

// Instance singleton
final storyLibrary = StoryLibraryService();
