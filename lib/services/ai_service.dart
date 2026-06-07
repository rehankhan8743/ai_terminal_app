import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  String _apiKey = '';
  String _model = 'gpt-3.5-turbo';

  void setApiKey(String key) {
    _apiKey = key;
  }

  void setModel(String model) {
    _model = model;
  }

  Future<String> getCommandSuggestion(String userInput) async {
    if (_apiKey.isEmpty) {
      return _generateLocalSuggestion(userInput);
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a Linux terminal assistant. Provide concise command explanations and suggestions. Format: command | description'
            },
            {
              'role': 'user',
              'content': userInput,
            }
          ],
          'max_tokens': 200,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'API Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Connection error: ${e.toString()}';
    }
  }

  String _generateLocalSuggestion(String input) {
    final suggestions = {
      'help': 'Available commands:\n  ls - List files\n  cd - Change directory\n  cat - View file\n  echo - Print text\n  mkdir - Create directory\n  rm - Remove file\n  clear - Clear screen\n  whoami - Show user\n  date - Show date/time',
      'ls': 'ls - List directory contents\n  Usage: ls [-la] [path]\n  -l: Long format\n  -a: Show hidden files',
      'cd': 'cd - Change directory\n  Usage: cd [path]\n  cd ~ : Go to home\n  cd .. : Go up one level',
      'cat': 'cat - Display file contents\n  Usage: cat [filename]',
      'mkdir': 'mkdir - Create directory\n  Usage: mkdir [dirname]\n  mkdir -p: Create parent dirs',
      'rm': 'rm - Remove files/directories\n  Usage: rm [file]\n  rm -rf: Force remove dir',
      'clear': 'clear - Clear terminal screen',
      'whoami': 'whoami - Display current user name',
      'date': 'date - Display current date and time',
      'echo': 'echo - Display text\n  Usage: echo "Hello World"',
      'pwd': 'pwd - Print current working directory',
      'chmod': 'chmod - Change file permissions\n  Usage: chmod [mode] [file]\n  Example: chmod 755 script.sh',
      'cp': 'cp - Copy files\n  Usage: cp [source] [dest]',
      'mv': 'mv - Move/rename files\n  Usage: mv [source] [dest]',
    };

    final cmd = input.trim().split(' ').first.toLowerCase();
    if (suggestions.containsKey(cmd)) {
      return suggestions[cmd]!;
    }
    return 'Unknown command: "$cmd"\nType "help" for available commands.';
  }
}
