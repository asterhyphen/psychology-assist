import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiConfig {
  const GeminiConfig._();

  static String? get apiKey {
    final value = dotenv.env['GEMINI_API_KEY']?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}
