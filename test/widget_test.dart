import 'package:flutter_test/flutter_test.dart';
import 'package:ai_terminal_app/services/ai_service.dart';

void main() {
  group('AIService Tests', () {
    late AIService aiService;

    setUp(() {
      aiService = AIService();
    });

    test('Local suggestion for ls command', () async {
      final result = await aiService.getCommandSuggestion('ls');
      expect(result, contains('List directory'));
    });

    test('Local suggestion for cd command', () async {
      final result = await aiService.getCommandSuggestion('cd');
      expect(result, contains('Change directory'));
    });

    test('Local suggestion for help command', () async {
      final result = await aiService.getCommandSuggestion('help');
      expect(result, contains('Available commands'));
    });

    test('Unknown command returns suggestion', () async {
      final result = await aiService.getCommandSuggestion('foobar');
      expect(result, contains('Unknown command'));
    });
  });
}
