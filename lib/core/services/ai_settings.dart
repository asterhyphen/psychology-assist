import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AiMode { auto, calmora, gemini }

final aiModeProvider = StateProvider<AiMode>((ref) => AiMode.auto);

/// Reads the stored Gemini API key from secure storage.
final geminiKeyProvider = FutureProvider<String?>((ref) async {
  final storage = ref.read(secureStorageServiceProvider);
  return await storage.readGeminiKey();
});

/// Reads the stored Ollama endpoint from secure storage, with env fallback.
final ollamaEndpointProvider = FutureProvider<String>((ref) async {
  final storage = ref.read(secureStorageServiceProvider);
  final stored = await storage.readOllamaEndpoint();
  if (stored != null && stored.isNotEmpty) return stored;
  if (!dotenv.isInitialized) {
    await dotenv.load().catchError((_) {});
  }
  return dotenv.env['OLLAMA_ENDPOINT'] ?? 'http://127.0.0.1:8000/chat';
});

/// Reads the stored Ollama model from secure storage, with env/default fallback.
final ollamaModelProvider = FutureProvider<String>((ref) async {
  final storage = ref.read(secureStorageServiceProvider);
  final stored = await storage.readOllamaModel();
  if (stored != null && stored.isNotEmpty) return stored;
  if (!dotenv.isInitialized) {
    await dotenv.load().catchError((_) {});
  }
  return dotenv.env['OLLAMA_MODEL'] ?? 'llama3.2:1b-instruct-q4_K_M';
});

/// True if a Gemini API key exists either in secure storage or in the .env fallback.
final geminiConfiguredProvider = Provider<bool>((ref) {
  final stored = ref.watch(geminiKeyProvider);
  final storedVal = stored.asData?.value;
  final envVal = dotenv.env['GEMINI_API_KEY'];
  return ((storedVal != null && storedVal.isNotEmpty) ||
      (envVal != null && envVal.isNotEmpty));
});

/// Helper to save/remove key
final geminiKeyActionsProvider = Provider((ref) {
  final storage = ref.read(secureStorageServiceProvider);
  return storage;
});
