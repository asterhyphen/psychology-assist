import 'dart:convert';
import 'dart:io';

class OllamaService {
  static const defaultQuantizedModel = 'llama3.2:1b-instruct-q4_K_M';

  final Uri endpoint;
  final String model;

  const OllamaService({
    required this.endpoint,
    this.model = defaultQuantizedModel,
  });

  Future<String> summarize({
  required String prompt,
  Duration timeout = const Duration(seconds: 60),
}) async {
  final client = HttpClient()..connectionTimeout = timeout;

  try {
    final request = await client.postUrl(endpoint);
    request.headers.contentType = ContentType.json;

    // ✅ FIXED BODY (matches FastAPI)
    request.write(
      jsonEncode({
        'message': prompt,
        'session_id': 'mobile_user',
      }),
    );

    final response = await request.close().timeout(timeout);
    final body = await response.transform(utf8.decoder).join();

    print("RAW RESPONSE: $body"); // debug

    if (response.statusCode != 200) {
      throw HttpException('Error ${response.statusCode}: $body');
    }

    final data = jsonDecode(body);

    if (data is Map<String, dynamic>) {
      return data['response']?.toString() ?? '';
    }

    return body;
  } finally {
    client.close(force: true);
  }

  }
}
