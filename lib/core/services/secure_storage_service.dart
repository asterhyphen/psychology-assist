import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((_) {
  return const FlutterSecureStorage();
});

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const _geminiKey = 'GEMINI_API_KEY';
  static const _ollamaEndpoint = 'OLLAMA_ENDPOINT';
  static const _ollamaModel = 'OLLAMA_MODEL';

  Future<void> saveGeminiKey(String key) async {
    await _storage.write(key: _geminiKey, value: key);
  }

  Future<String?> readGeminiKey() async {
    return await _storage.read(key: _geminiKey);
  }

  Future<void> deleteGeminiKey() async {
    await _storage.delete(key: _geminiKey);
  }

  Future<void> saveOllamaEndpoint(String endpoint) async {
    await _storage.write(key: _ollamaEndpoint, value: endpoint);
  }

  Future<String?> readOllamaEndpoint() async {
    return await _storage.read(key: _ollamaEndpoint);
  }

  Future<void> deleteOllamaEndpoint() async {
    await _storage.delete(key: _ollamaEndpoint);
  }

  Future<void> saveOllamaModel(String model) async {
    await _storage.write(key: _ollamaModel, value: model);
  }

  Future<String?> readOllamaModel() async {
    return await _storage.read(key: _ollamaModel);
  }

  Future<void> deleteOllamaModel() async {
    await _storage.delete(key: _ollamaModel);
  }
}

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final storage = ref.read(secureStorageProvider);
  return SecureStorageService(storage);
});
