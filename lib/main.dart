import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/saved_story.dart';
import 'models/story_config.dart';
import 'screens/screen0_home.dart';
import 'screens/screen1_welcome.dart';
import 'screens/screen2_character.dart';
import 'screens/screen3_hero_name.dart';
import 'screens/screen4_theme.dart';
import 'screens/screen5_story_type.dart';
import 'screens/screen6_magic_object.dart';
import 'screens/screen7_story.dart';
import 'screens/screen_library.dart';
import 'screens/screen_profiles.dart';
import 'screens/screen_settings.dart';
import 'services/api_key_service.dart';
import 'services/app_settings_service.dart';
import 'services/story_library_service.dart';
import 'services/user_profile_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await UserProfileService.init();
  await StoryLibraryService.init();
  appSettings = await AppSettingsService.load();
  if (!kIsWeb) {
    await [
      Permission.microphone,
    ].request();
  }
  runApp(const JomeniApp());
}

class JomeniApp extends StatelessWidget {
  const JomeniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ma petite histoire de Jomeni',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/profiles',
  routes: [
    // Sélection de profil (point d'entrée)
    GoRoute(
      path: '/profiles',
      builder: (context, state) => const ProfilesScreen(),
    ),
    // Accueil (après sélection du profil)
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    // Flux de création
    GoRoute(
      path: '/create',
      builder: (context, state) => WelcomeScreen(config: StoryConfig()),
    ),
    GoRoute(
      path: '/character',
      builder: (context, state) =>
          CharacterScreen(config: state.extra as StoryConfig),
    ),
    GoRoute(
      path: '/hero-name',
      builder: (context, state) =>
          HeroNameScreen(config: state.extra as StoryConfig),
    ),
    GoRoute(
      path: '/theme',
      builder: (context, state) =>
          ThemeScreen(config: state.extra as StoryConfig),
    ),
    GoRoute(
      path: '/story-type',
      builder: (context, state) =>
          StoryTypeScreen(config: state.extra as StoryConfig),
    ),
    GoRoute(
      path: '/magic-object',
      builder: (context, state) =>
          MagicObjectScreen(config: state.extra as StoryConfig),
    ),
    GoRoute(
      path: '/generating',
      builder: (context, state) => StoryScreen(
        config: state.extra as StoryConfig,
        apiKey: apiKeyService.key,
      ),
    ),
    // Réglages
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    // Bibliothèque
    GoRoute(
      path: '/library',
      builder: (context, state) => const LibraryScreen(),
    ),
    GoRoute(
      path: '/play',
      builder: (context, state) => StoryScreen(
        savedStory: state.extra as SavedStory,
        apiKey: apiKeyService.key,
      ),
    ),
  ],
);
