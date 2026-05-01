import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';

class UserProfileService {
  static const String _boxName = 'user_profiles';

  // Profil actif pour la session en cours
  UserProfile? currentProfile;

  static Future<void> init() async {
    await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  List<UserProfile> getAll() {
    return _box.values
        .map((m) => UserProfile.fromMap(m))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<UserProfile> create({
    required String name,
    required String emoji,
    required int colorIndex,
    ProfileAge? age,
    ProfileGender? gender,
  }) async {
    final profile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      emoji: emoji,
      colorIndex: colorIndex,
      createdAt: DateTime.now(),
      age: age,
      gender: gender,
    );
    await _box.put(profile.id, profile.toMap());
    return profile;
  }

  Future<void> update(UserProfile profile) async {
    await _box.put(profile.id, profile.toMap());
    if (currentProfile?.id == profile.id) {
      currentProfile = profile;
    }
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  int get count => _box.length;
}

final userProfileService = UserProfileService();
