import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

class AIService {
  final String apiKey;
  final Dio _dio = Dio();

  AIService({required this.apiKey});

  Stream<String> streamChat(String prompt, String terminalContext) async* {
    final messages = [
      {
        "role": "system",
        "content": "You are an expert Linux root terminal agent. "
            "If you need to run a command to answer the user, "
            "you MUST wrap the exact bash command in <cmd>...</cmd> tags. "
            "Otherwise, reply with text. "
            "Current Terminal Context:\n$terminalContext"
      },
      {"role": "user", "content": prompt}
    ];

    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
          responseType: ResponseType.stream,
        ),
        data: {
          'model': 'gpt-4o',
          'messages': messages,
          'stream': true,
        },
      );

      final stream = (response.data as ResponseBody).stream;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk, allowMalformed: true);
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data == '[DONE]') break;

            try {
              final json = jsonDecode(data);
              final content = json['choices']?[0]?['delta']?['content'] ?? '';
              if (content.toString().isNotEmpty) {
                yield content.toString();
              }
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      yield "Error connecting to AI: $e";
    }
  }
}
