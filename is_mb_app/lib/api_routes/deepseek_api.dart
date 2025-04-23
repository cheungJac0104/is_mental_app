import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DeepSeekApi {
  static const String _baseUrl = 'https://api.deepseek.com';
  final String _apiKey = dotenv.get('DEEPSEEK_API_KEY');

  Future<Map<String, dynamic>> generateMoodTip({
    String mood = '',
    int intensity = 1,
    required List<String> keywords,
    String notes = '',
  }) async {
    final prompt = [
      {
        'role': 'system',
        'content': 'You are a mood coach specializing in brief, actionable advice. '
            'Respond with ONLY the lucky tip advice (15-30 words) in a single sentence.'
      },
      {
        'role': 'user',
        'content':
            'Create a ${intensity > 3 ? 'strong' : 'gentle'} uplifting lucky tip '
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
          'Content-Type': 'application/json; charset=utf-8',
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
        // Decode bytes explicitly as UTF-8 to avoid mojibake (e.g., â)
        final utf8Decoded = utf8.decode(response.bodyBytes); // Critical fix
        final data = jsonDecode(utf8Decoded);

        String tip = data['choices'][0]['message']['content'].trim();

        // Fix common mojibake characters (e.g., â€™ → ’)
        tip = tip
            .replaceAll('â€™', '’') // Fix curly apostrophe
            .replaceAll('â€”', '—') // Fix em-dash
            .replaceAll('â€“', '–'); // Fix en-dash

        return {
          'tip': tip,
          'usage': data['usage'],
          'status': 'success',
        };
      } else {
        throw Exception(
            'API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      return {
        'tip': 'Failed to generate tip. Please try again.',
        'usage': null,
        'status': 'error',
        'error': e.toString(),
      };
    }
  }
}
