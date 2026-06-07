import 'package:dio/dio.dart';

class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final Dio _dio = Dio();
  String _apiKey = '';
  String _model = 'gpt-3.5-turbo';

  void setApiKey(String key) {
    _apiKey = key;
    _dio.options.headers['Authorization'] = 'Bearer $key';
  }

  void setModel(String model) {
    _model = model;
  }

  Future<String> getCommandSuggestion(String userInput) async {
    if (_apiKey.isEmpty) {
      return _generateLocalSuggestion(userInput);
    }

    try {
      final response = await _dio.post(
        _baseUrl,
        data: {
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
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['choices'][0]['message']['content'];
      } else {
        return 'API Error: ${response.statusCode}';
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return 'API Error: ${e.response?.statusCode}';
      }
      return 'Connection error: ${e.message}';
    } catch (e) {
      return 'Error: ${e.toString()}';
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
      'apt': 'apt - Package manager\n  Usage: apt update && apt install [pkg]',
      'apk': 'apk - Alpine package manager\n  Usage: apk add [pkg]',
      'pip': 'pip - Python package manager\n  Usage: pip install [pkg]',
      'node': 'node - JavaScript runtime\n  Usage: node [script.js]',
      'python': 'python - Python interpreter\n  Usage: python [script.py]',
      'git': 'git - Version control\n  Usage: git [command]',
      'ssh': 'ssh - Secure shell\n  Usage: ssh user@host',
      'curl': 'curl - HTTP client\n  Usage: curl [url]',
      'wget': 'wget - Download files\n  Usage: wget [url]',
    };

    final cmd = input.trim().split(' ').first.toLowerCase();
    if (suggestions.containsKey(cmd)) {
      return suggestions[cmd]!;
    }
    return 'Unknown command: "$cmd"\nType "help" for available commands.';
  }
}
