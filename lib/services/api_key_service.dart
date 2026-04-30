import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Fournit la clé Gemini depuis le fichier .env.
String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
