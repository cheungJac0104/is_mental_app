import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepSeekApi {
  static const String _baseUrl = 'https://api.deepseek.com';
  final String _apiKey;

  DeepSeekApi(this._apiKey);

  Future<Map<String, dynamic>> generateMoodTip({
    String mood = '',
    int intensity = 1,
    required List<String> keywords,
    String notes = '',
  }) async {
    final prompt = [
      {
        'role': 'system',
        'content':
            'You are a mood coach specializing in brief, actionable advice. '
                'Respond with ONLY the tip (15-30 words) in a single sentence.'
      },
      {
        'role': 'user',
        'content': 'Create a ${intensity > 3 ? 'strong' : 'gentle'} uplifting tip '
            'for someone feeling $mood. '
            '${keywords.isNotEmpty ? 'Keywords: ${keywords.join(', ')}. ' : ''}'
            '${notes.isNotEmpty ? 'Context: $notes' : ''}'
      }
    ];

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': prompt,
          'temperature': (0.3 + (intensity * 0.1)).clamp(0.0, 1.0),
          'max_tokens': 60,
          'stop': ['.', '!', '?']
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'tip': data['choices'][0]['message']['content'].trim(),
          'usage': data['usage'],
        };
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Tip generation failed: ${e.toString()}');
    }
  }
}
