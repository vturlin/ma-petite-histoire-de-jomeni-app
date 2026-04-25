import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/saved_story.dart';
import 'user_profile_service.dart';

class StoryLibraryService {
  static const String _metaBox = 'stories_meta';
  static const String _audioBox = 'stories_audio';

  static Future<void> init() async {
    await Hive.openBox<Map>(_metaBox);
    await Hive.openBox<Uint8List>(_audioBox);
  }

  Box<Map> get _meta => Hive.box<Map>(_metaBox);
  Box<Uint8List> get _audio => Hive.box<Uint8List>(_audioBox);

  /// Préfixe toutes les clés avec l'ID du profil actif.
  String _key(String storyId) {
    final profileId = userProfileService.currentProfile?.id ?? 'default';
    return '${profileId}_$storyId';
  }

  String _audioKey(String storyId, int index) {
    final profileId = userProfileService.currentProfile?.id ?? 'default';
    return '${profileId}_${storyId}_$index';
  }

  Future<void> saveMeta(SavedStory story) async {
    await _meta.put(_key(story.id), story.toMap());
  }

  Future<void> saveAudioChunk(String storyId, int index, Uint8List wav) async {
    await _audio.put(_audioKey(storyId, index), wav);
    final key = _key(storyId);
    final meta = Map<dynamic, dynamic>.from(_meta.get(key) ?? {});
    final current = meta['audioChunkCount'] as int? ?? 0;
    if (index >= current) {
      meta['audioChunkCount'] = index + 1;
      await _meta.put(key, meta);
    }
  }

  Uint8List? getAudioChunk(String storyId, int index) =>
      _audio.get(_audioKey(storyId, index));

  List<Uint8List> getAllAudioChunks(String storyId, int count) {
    final chunks = <Uint8List>[];
    for (int i = 0; i < count; i++) {
      final chunk = _audio.get(_audioKey(storyId, i));
      if (chunk != null) chunks.add(chunk);
    }
    return chunks;
  }

  /// Retourne uniquement les histoires du profil actif.
  List<SavedStory> getAll() {
    final profileId = userProfileService.currentProfile?.id ?? 'default';
    final prefix = '${profileId}_';
    return _meta.keys
        .where((k) => k.toString().startsWith(prefix))
        .map((k) => SavedStory.fromMap(_meta.get(k)!))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> delete(String storyId) async {
    final story = _meta.get(_key(storyId));
    if (story != null) {
      final count = story['audioChunkCount'] as int? ?? 0;
      for (int i = 0; i < count; i++) {
        await _audio.delete(_audioKey(storyId, i));
      }
    }
    await _meta.delete(_key(storyId));
  }

  int get count {
    final profileId = userProfileService.currentProfile?.id ?? 'default';
    final prefix = '${profileId}_';
    return _meta.keys.where((k) => k.toString().startsWith(prefix)).length;
  }
}

final storyLibrary = StoryLibraryService();
