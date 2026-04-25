import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeyService {
  String? _selectedKey;

  String get key => _selectedKey ?? dotenv.env['GEMINI_API_KEY'] ?? '';

  void selectProduction() =>
      _selectedKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  void selectTest() =>
      _selectedKey = dotenv.env['GEMINI_API_KEY_TEST'] ?? '';

  bool get isSelected => _selectedKey != null;
}

final apiKeyService = ApiKeyService();
