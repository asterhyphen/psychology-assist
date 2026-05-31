import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ollama_service.dart';
import 'ai_settings.dart';

enum AiBackend { ollama, gemini }

/// Lightweight adapter interface for AI backends used by the app.
abstract class AiService {
  Future<String> generate(String prompt, {Duration timeout});
  Future<bool> isAvailable({Duration timeout});
}

class OllamaAdapter implements AiService {
  final Uri endpoint;
  final String model;

  OllamaAdapter(
      {required this.endpoint,
      this.model = OllamaService.defaultQuantizedModel});

  @override
  Future<String> generate(String prompt,
      {Duration timeout = const Duration(seconds: 60)}) async {
    if (kDebugMode) {
      debugPrint('OllamaAdapter.generate: endpoint=$endpoint, model=$model');
    }
    final ollama = OllamaService(endpoint: endpoint, model: model);
    return ollama.summarize(prompt: prompt, timeout: timeout);
  }

  @override
  Future<bool> isAvailable(
      {Duration timeout = const Duration(seconds: 6)}) async {
    try {
      final client = HttpClient()..connectionTimeout = timeout;
      final req = await client.getUrl(endpoint);
      final resp = await req.close().timeout(timeout);
      client.close(force: true);
      return resp.statusCode >= 200 && resp.statusCode < 500;
    } catch (_) {
      return false;
    }
  }
}

class GeminiAdapter implements AiService {
  final String? apiKey;
  final String apiKeySource;
  final Uri? endpoint;

  List<String>? _discoveredModels;

  GeminiAdapter(
      {required this.apiKey, required this.apiKeySource, this.endpoint});

  String _extractTextFromGeminiResponse(dynamic rawData) {
    if (rawData is Map<String, dynamic>) {
      if (rawData['text'] is String) {
        return (rawData['text'] as String).trim();
      }

      if (rawData['output'] is Map<String, dynamic>) {
        final output = rawData['output'] as Map<String, dynamic>;
        if (output['text'] is String) {
          return (output['text'] as String).trim();
        }

        final content = output['content'];
        if (content is String) return content.trim();
        if (content is List && content.isNotEmpty) {
          for (final item in content) {
            if (item is Map<String, dynamic>) {
              if (item['text'] is String) {
                return (item['text'] as String).trim();
              }
              if (item['content'] is String) {
                return (item['content'] as String).trim();
              }
            }
            if (item is String) return item.trim();
          }
        }
      }

      if (rawData['candidates'] is List) {
        for (final candidate in rawData['candidates'] as List) {
          if (candidate is Map<String, dynamic>) {
            final candContent = candidate['content'];
            if (candContent is Map<String, dynamic>) {
              final parts = candContent['parts'];
              if (parts is List && parts.isNotEmpty) {
                final part0 = parts[0];
                if (part0 is Map<String, dynamic> && part0['text'] is String) {
                  return (part0['text'] as String).trim();
                }
              }
            }
            if (candidate['content'] is String) {
              return (candidate['content'] as String).trim();
            }
            if (candidate['text'] is String) {
              return (candidate['text'] as String).trim();
            }
            if (candidate['output'] is Map<String, dynamic>) {
              final output = candidate['output'] as Map<String, dynamic>;
              if (output['text'] is String) {
                return (output['text'] as String).trim();
              }
              final content = output['content'];
              if (content is String) return content.trim();
              if (content is List && content.isNotEmpty) {
                for (final item in content) {
                  if (item is Map<String, dynamic> && item['text'] is String) {
                    return (item['text'] as String).trim();
                  }
                  if (item is String) return item.trim();
                }
              }
            }
          }
        }
      }
    }

    return '';
  }

  String _parseGeminiResponse(String body) {
    try {
      final data = jsonDecode(body);
      final extracted = _extractTextFromGeminiResponse(data);
      return extracted.isNotEmpty ? extracted : body.trim();
    } catch (_) {
      return body.trim();
    }
  }

  Future<List<String>> _discoverAvailableModels(HttpClient client, Duration timeout) async {
    if (_discoveredModels != null) return _discoveredModels!;
    if (apiKey == null || apiKey!.isEmpty) return [];

    final listUri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models');
    
    Future<List<String>> _parseModels(String body) async {
      try {
        final data = jsonDecode(body);
        final List<String> extracted = [];
        if (data is Map<String, dynamic> && data['models'] is List) {
          for (final m in data['models']) {
            if (m is Map<String, dynamic> && m['name'] is String) {
              final name = m['name'] as String;
              final modelId = name.startsWith('models/') ? name.substring(7) : name;
              extracted.add(modelId);
            }
          }
        }
        return extracted;
      } catch (_) {
        return [];
      }
    }

    // Try header auth
    try {
      final req = await client.getUrl(listUri);
      req.headers.set('x-goog-api-key', apiKey ?? '');
      final resp = await req.close().timeout(timeout);
      final body = await resp.transform(utf8.decoder).join();
      if (kDebugMode) {
        debugPrint('GeminiAdapter.discoverModels: HTTP ${resp.statusCode} from $listUri. Sourced from $apiKeySource.');
      }
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        _discoveredModels = await _parseModels(body);
        return _discoveredModels!;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GeminiAdapter.discoverModels: header attempt exception: ${e.toString()}');
      }
    }

    // Try query-param auth
    try {
      final uriWithKey = listUri.replace(
          queryParameters: {...listUri.queryParameters, 'key': apiKey ?? ''});
      final req = await client.getUrl(uriWithKey);
      final resp = await req.close().timeout(timeout);
      final body = await resp.transform(utf8.decoder).join();
      if (kDebugMode) {
        debugPrint('GeminiAdapter.discoverModels: HTTP ${resp.statusCode} from $uriWithKey. Sourced from $apiKeySource.');
      }
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        _discoveredModels = await _parseModels(body);
        return _discoveredModels!;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('GeminiAdapter.discoverModels: query-param attempt exception: ${e.toString()}');
      }
    }

    return [];
  }

  @override
  Future<String> generate(String prompt,
      {Duration timeout = const Duration(seconds: 30)}) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw StateError('Gemini API key not configured');
    }
    final client = HttpClient()..connectionTimeout = timeout;

    // Determine candidate models (env override via GEMINI_MODEL) unless explicit endpoint provided
    final env = dotenv.isInitialized ? dotenv.env : <String, String>{};
    final envModel = env['GEMINI_MODEL']?.trim();
    
    List<String> candidateModels;
    if (endpoint != null) {
      candidateModels = [];
    } else if (envModel != null && envModel.isNotEmpty) {
      candidateModels = [envModel];
    } else {
      // Run startup diagnostic models.list
      final discovered = await _discoverAvailableModels(client, const Duration(seconds: 5));
      if (kDebugMode && discovered.isNotEmpty) {
        debugPrint('GeminiAdapter STARTUP DIAGNOSTIC: Available Gemini models returned by Google:');
        for (final m in discovered) {
          debugPrint('  - $m');
        }
      }
      
      String? firstFlashModel;
      for (final m in discovered) {
        if (m.toLowerCase().contains('flash')) {
          firstFlashModel = m;
          break;
        }
      }
      
      final baseCandidates = [
        'gemini-flash-latest',
        'gemini-1.5-flash',
        'gemini-1.5-pro',
      ];
      
      candidateModels = [];
      if (firstFlashModel != null) {
        candidateModels.add(firstFlashModel);
      }
      for (final model in baseCandidates) {
        if (model != firstFlashModel) {
          candidateModels.add(model);
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
          'GeminiAdapter.generate: apiKeySource=$apiKeySource endpoint=${endpoint?.toString() ?? 'fallback models'} candidateModels=$candidateModels');
    }

    Future<HttpClientResponse> _postTo(Uri uri,
        {Map<String, String>? headers}) async {
      final request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      headers?.forEach((k, v) => request.headers.set(k, v));
      request.write(jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.6,
          'maxOutputTokens': 512,
        }
      }));
      return await request.close().timeout(timeout);
    }

    if (kDebugMode) {
      debugPrint(
          'GeminiAdapter.generate: keyPresent=${apiKey != null && apiKey!.isNotEmpty}');
    }

    Future<String> _attemptUri(Uri baseUri, String modelName) async {
      // Header auth attempt
      try {
        if (kDebugMode) {
          debugPrint('GeminiAdapter: attempting header auth for model $modelName to $baseUri using API key from $apiKeySource');
        }
        final resp =
            await _postTo(baseUri, headers: {'x-goog-api-key': apiKey ?? ''});
        final body = await resp.transform(utf8.decoder).join();
        if (kDebugMode) {
          debugPrint(
              'GeminiAdapter: HTTP status ${resp.statusCode} for model $modelName at $baseUri. Sourced from $apiKeySource. Body: ${body.trim()}');
        }
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          if (kDebugMode) {
            debugPrint('GeminiAdapter: header auth success for model $modelName at $baseUri');
          }
          return _parseGeminiResponse(body);
        }
        if (resp.statusCode == 429) {
          final errorMsg = 'Gemini Quota Exceeded (429 RESOURCE_EXHAUSTED): Quota exceeded for model $modelName at $baseUri. Sourced from $apiKeySource. Response: ${body.trim()}';
          if (kDebugMode) {
            debugPrint(errorMsg);
          }
          return errorMsg; // Return quota message directly to avoid fallback conversion
        }
        if (resp.statusCode == 404) {
          if (kDebugMode) {
            debugPrint(
                'GeminiAdapter: model $modelName not found at $baseUri (404). Sourced from $apiKeySource. Body: ${body.trim()}');
          }
          throw HttpException('Model not found');
        }
        if (resp.statusCode == 401 || resp.statusCode == 403) {
          if (kDebugMode) {
            debugPrint(
                'GeminiAdapter: header auth unauthorized (${resp.statusCode}) for model $modelName at $baseUri. Sourced from $apiKeySource. Body: ${body.trim()}');
          }
          throw HttpException('Unauthorized');
        }
        throw HttpException('Gemini error ${resp.statusCode}: $body');
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
              'GeminiAdapter: header attempt exception for model $modelName at $baseUri: ${e.toString()}');
        }
        if (e is HttpException) rethrow;
      }

      // Query-param auth attempt
      try {
        final uriWithKey = baseUri.replace(
            queryParameters: {...baseUri.queryParameters, 'key': apiKey ?? ''});
        if (kDebugMode) {
          debugPrint(
              'GeminiAdapter: attempting query-param auth for model $modelName to $uriWithKey using API key from $apiKeySource');
        }
        final resp2 = await _postTo(uriWithKey);
        final body2 = await resp2.transform(utf8.decoder).join();
        if (kDebugMode) {
          debugPrint(
              'GeminiAdapter: HTTP status ${resp2.statusCode} for model $modelName at $uriWithKey. Sourced from $apiKeySource. Body: ${body2.trim()}');
        }
        if (resp2.statusCode >= 200 && resp2.statusCode < 300) {
          if (kDebugMode) {
            debugPrint(
                'GeminiAdapter: query-param auth success for model $modelName at $uriWithKey');
          }
          return _parseGeminiResponse(body2);
        }
        if (resp2.statusCode == 429) {
          final errorMsg2 = 'Gemini Quota Exceeded (429 RESOURCE_EXHAUSTED): Quota exceeded for model $modelName at $uriWithKey. Sourced from $apiKeySource. Response: ${body2.trim()}';
          if (kDebugMode) {
            debugPrint(errorMsg2);
          }
          return errorMsg2; // Return quota message directly to avoid fallback conversion
        }
        if (resp2.statusCode == 404) {
          if (kDebugMode) {
            debugPrint(
                'GeminiAdapter: model $modelName not found at $uriWithKey (404). Sourced from $apiKeySource. Body: ${body2.trim()}');
          }
          throw HttpException('Model not found');
        }
        if (resp2.statusCode == 401 || resp2.statusCode == 403) {
          if (kDebugMode) {
            debugPrint(
                'GeminiAdapter: query-param auth unauthorized (${resp2.statusCode}) for model $modelName at $uriWithKey. Sourced from $apiKeySource. Body: ${body2.trim()}');
          }
          throw HttpException('Unauthorized');
        }
        throw HttpException('Gemini error ${resp2.statusCode}: $body2');
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
              'GeminiAdapter: query-param attempt exception for model $modelName at $baseUri: ${e.toString()}');
        }
        rethrow;
      }
    }

    // If explicit endpoint provided, try it directly
    if (endpoint != null) {
      try {
        final result = await _attemptUri(endpoint!, 'explicit-endpoint');
        client.close(force: true);
        return result;
      } catch (e) {
        client.close(force: true);
        rethrow;
      }
    }

    // Try candidate models in order
    HttpException? lastModelNotFound;
    for (final model in candidateModels) {
      final modelUri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent');
      if (kDebugMode) {
        debugPrint('GeminiAdapter: trying model $model at $modelUri');
      }
      try {
        final result = await _attemptUri(modelUri, model);
        client.close(force: true);
        if (kDebugMode) {
          debugPrint('GeminiAdapter: SUCCESS - selected model=$model endpoint=$modelUri');
        }
        return result;
      } catch (e) {
        if (e is HttpException && e.message.contains('Model not found')) {
          lastModelNotFound = e;
          if (kDebugMode) {
            debugPrint(
                'GeminiAdapter: model $model not available (404), trying next');
          }
          continue; // try next model
        }
        client.close(force: true);
        rethrow;
      }
    }

    client.close(force: true);
    if (lastModelNotFound != null) throw lastModelNotFound;
    throw StateError('Gemini generation failed for all candidate models');
  }

  @override
  Future<bool> isAvailable(
      {Duration timeout = const Duration(seconds: 6)}) async {
    if (apiKey == null || apiKey!.isEmpty) return false;
    final client = HttpClient()..connectionTimeout = timeout;

    // Candidate models for health check
    final env = dotenv.isInitialized ? dotenv.env : <String, String>{};
    final envModel = env['GEMINI_MODEL']?.trim();
    
    List<String> candidateModels;
    if (endpoint != null) {
      candidateModels = [];
    } else if (envModel != null && envModel.isNotEmpty) {
      candidateModels = [envModel];
    } else {
      final discovered = await _discoverAvailableModels(client, const Duration(seconds: 5));
      
      String? firstFlashModel;
      for (final m in discovered) {
        if (m.toLowerCase().contains('flash')) {
          firstFlashModel = m;
          break;
        }
      }
      
      final baseCandidates = [
        'gemini-flash-latest',
        'gemini-1.5-flash',
        'gemini-1.5-pro',
      ];
      
      candidateModels = [];
      if (firstFlashModel != null) {
        candidateModels.add(firstFlashModel);
      }
      for (final model in baseCandidates) {
        if (model != firstFlashModel) {
          candidateModels.add(model);
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
          'GeminiAdapter.isAvailable: apiKeySource=$apiKeySource endpoint=${endpoint?.toString() ?? 'fallback models'} candidateModels=$candidateModels');
    }

    Future<bool> _attemptHealth(Uri uri, String modelName) async {
      // header auth
      try {
        if (kDebugMode) {
          debugPrint('GeminiAdapter.isAvailable: trying header auth for model $modelName to $uri using API key from $apiKeySource');
        }
        final req = await client.postUrl(uri);
        req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        req.headers.set('x-goog-api-key', apiKey ?? '');
        req.write(jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Ping'}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.0,
            'maxOutputTokens': 1,
          }
        }));
        final resp = await req.close().timeout(timeout);
        final body = await resp.transform(utf8.decoder).join();
        if (kDebugMode) {
          debugPrint(
              'GeminiAdapter.isAvailable: HTTP status ${resp.statusCode} for model $modelName at $uri. Sourced from $apiKeySource. Body: ${body.trim()}');
        }
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          if (kDebugMode) {
            debugPrint('GeminiAdapter.isAvailable: SUCCESS - model $modelName is available via header auth.');
          }
          return true;
        }
        if (resp.statusCode == 429) {
          if (kDebugMode) {
            debugPrint('GeminiAdapter.isAvailable: REACHABLE BUT RATE LIMITED (429) for model $modelName at $uri. Sourced from $apiKeySource. Treating as Available.');
          }
          return true;
        }
        if (resp.statusCode == 404) {
          if (kDebugMode) {
            debugPrint('GeminiAdapter.isAvailable: NOT FOUND (404) for model $modelName at $uri. Sourced from $apiKeySource.');
          }
          return false;
        }
        if (resp.statusCode == 401 || resp.statusCode == 403) {
          if (kDebugMode) {
            debugPrint('GeminiAdapter.isAvailable: AUTHENTICATION FAILURE (${resp.statusCode}) for model $modelName at $uri. Sourced from $apiKeySource.');
          }
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
              'GeminiAdapter.isAvailable: header attempt failed for model $modelName at $uri: ${e.toString()}');
        }
      }

      // query param
      try {
        final uriWithKey = uri.replace(
            queryParameters: {...uri.queryParameters, 'key': apiKey ?? ''});
        if (kDebugMode) {
          debugPrint(
              'GeminiAdapter.isAvailable: trying query-param auth for model $modelName to $uriWithKey using API key from $apiKeySource');
        }
        final req2 = await client.postUrl(uriWithKey);
        req2.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        req2.write(jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Ping'}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.0,
            'maxOutputTokens': 1,
          }
        }));
        final resp2 = await req2.close().timeout(timeout);
        final body2 = await resp2.transform(utf8.decoder).join();
        if (kDebugMode) {
          debugPrint(
              'GeminiAdapter.isAvailable: HTTP status ${resp2.statusCode} for model $modelName at $uriWithKey. Sourced from $apiKeySource. Body: ${body2.trim()}');
        }
        if (resp2.statusCode >= 200 && resp2.statusCode < 300) {
          if (kDebugMode) {
            debugPrint('GeminiAdapter.isAvailable: SUCCESS - model $modelName is available via query-param auth.');
          }
          return true;
        }
        if (resp2.statusCode == 429) {
          if (kDebugMode) {
            debugPrint('GeminiAdapter.isAvailable: REACHABLE BUT RATE LIMITED (429) for model $modelName at $uriWithKey. Sourced from $apiKeySource. Treating as Available.');
          }
          return true;
        }
        if (resp2.statusCode == 404) {
          if (kDebugMode) {
            debugPrint('GeminiAdapter.isAvailable: NOT FOUND (404) for model $modelName at $uriWithKey. Sourced from $apiKeySource.');
          }
          return false;
        }
        if (resp2.statusCode == 401 || resp2.statusCode == 403) {
          if (kDebugMode) {
            debugPrint('GeminiAdapter.isAvailable: AUTHENTICATION FAILURE (${resp2.statusCode}) for model $modelName at $uriWithKey. Sourced from $apiKeySource.');
          }
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
              'GeminiAdapter.isAvailable: query-param attempt failed for model $modelName at $uri: ${e.toString()}');
        }
      }

      return false;
    }

    // If explicit endpoint provided, try it
    if (endpoint != null) {
      try {
        final ok = await _attemptHealth(endpoint!, 'explicit-endpoint');
        client.close(force: true);
        return ok;
      } finally {}
    }

    for (final model in candidateModels) {
      final modelUri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent');
      final ok = await _attemptHealth(modelUri, model);
      if (ok) {
        client.close(force: true);
        if (kDebugMode) {
          debugPrint('GeminiAdapter.isAvailable: SELECTED ACTIVE MODEL - $model');
        }
        return true;
      }
    }

    client.close(force: true);
    return false;
  }
}

/// Manager that routes requests to configured backend with fallback.
class AiManager implements AiService {
  final AiService primary;
  final AiService secondary;
  final AiBackend primaryBackend;
  final bool allowFallback;

  AiManager(
      {required this.primary,
      required this.secondary,
      required this.primaryBackend,
      this.allowFallback = true});

  @override
  Future<String> generate(String prompt,
      {Duration timeout = const Duration(seconds: 60)}) async {
    if (kDebugMode) {
      debugPrint(
          'AiManager.generate: primary=${primary.runtimeType}, secondary=${secondary.runtimeType}, primaryBackend=$primaryBackend, allowFallback=$allowFallback');
    }
    if (!allowFallback) {
      // Manual mode - do not fallback
      return await primary.generate(prompt, timeout: timeout);
    }

    try {
      return await primary.generate(prompt, timeout: timeout);
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            'AiManager.generate: primary failed (${e.runtimeType}): ${e.toString()}');
      }
      try {
        if (kDebugMode)
          debugPrint('AiManager.generate: falling back to secondary provider');
        return await secondary.generate(prompt, timeout: timeout);
      } catch (e2) {
        if (kDebugMode) {
          debugPrint(
              'AiManager.generate: secondary also failed (${e2.runtimeType}): ${e2.toString()}');
        }
        rethrow;
      }
    }
  }

  @override
  Future<bool> isAvailable(
      {Duration timeout = const Duration(seconds: 6)}) async {
    if (!allowFallback) {
      return await primary.isAvailable(timeout: timeout);
    }
    return await primary.isAvailable(timeout: timeout) ||
        await secondary.isAvailable(timeout: timeout);
  }
}

/// Riverpod provider to expose a configured AiManager.
final aiManagerProvider = Provider<AiManager>((ref) {
  if (!dotenv.isInitialized) {
    dotenv.testLoad(fileInput: 'GEMINI_API_KEY=mock_key\nPREFERRED_AI=ollama\nOLLAMA_ENDPOINT=http://127.0.0.1:8000/chat');
  }
  final env = dotenv.env;
  final configuredPreferred = (env['PREFERRED_AI'] ?? 'ollama').toLowerCase();
 
  // Ollama configuration from secure storage or env
  final ollamaEndpointAsync = ref.watch(ollamaEndpointProvider);
  final ollamaEndpoint = ollamaEndpointAsync.asData?.value ?? env['OLLAMA_ENDPOINT'] ?? 'http://127.0.0.1:8000/chat';
  final ollamaUri =
      Uri.tryParse(ollamaEndpoint) ?? Uri.parse('http://127.0.0.1:8000/chat');

  final ollamaModelAsync = ref.watch(ollamaModelProvider);
  final ollamaModel = ollamaModelAsync.asData?.value ?? env['OLLAMA_MODEL'] ?? 'llama3.2:1b-instruct-q4_K_M';
 
  // Gemini configuration from secure storage or env
  final geminiKeyAsync = ref.watch(geminiKeyProvider);
  final geminiKey = geminiKeyAsync.asData?.value ?? env['GEMINI_API_KEY'];
  final geminiEndpoint = env['GEMINI_ENDPOINT'];
  final geminiKeySource =
      geminiKeyAsync.asData?.value != null ? 'settings' : 'env';

  final ollama = OllamaAdapter(endpoint: ollamaUri, model: ollamaModel);
  final gemini = GeminiAdapter(
      apiKey: geminiKey,
      apiKeySource: geminiKeySource,
      endpoint: geminiEndpoint == null ? null : Uri.tryParse(geminiEndpoint));

  final userMode = ref.watch(aiModeProvider);

  // Determine primary/secondary and fallback behavior
  if (userMode == AiMode.gemini) {
    return AiManager(
        primary: gemini,
        secondary: ollama,
        primaryBackend: AiBackend.gemini,
        allowFallback: false);
  }

  if (userMode == AiMode.calmora) {
    return AiManager(
        primary: ollama,
        secondary: gemini,
        primaryBackend: AiBackend.ollama,
        allowFallback: false);
  }

  // Auto or unspecified - use configuredPreferred as guide but allow fallback
  if (configuredPreferred == 'gemini') {
    return AiManager(
        primary: gemini,
        secondary: ollama,
        primaryBackend: AiBackend.gemini,
        allowFallback: true);
  }

  return AiManager(
      primary: ollama,
      secondary: gemini,
      primaryBackend: AiBackend.ollama,
      allowFallback: true);
});
