import 'package:flutter/material.dart';
import '../services/proot_service.dart';
import '../services/ai_service.dart';

enum TerminalState { idle, initializing, ready, error }

class AppState extends ChangeNotifier {
  final PRootService _prootService = PRootService();
  final AIService _aiService = AIService();

  TerminalState _state = TerminalState.idle;
  String _output = '';
  String _input = '';
  String _currentPath = '~';
  bool _isProcessing = false;
  List<Map<String, String>> _history = [];
  String _errorMessage = '';
  String _aiResponse = '';
  bool _useAI = false;

  TerminalState get state => _state;
  String get output => _output;
  String get input => _input;
  String get currentPath => _currentPath;
  bool get isProcessing => _isProcessing;
  List<Map<String, String>> get history => _history;
  String get errorMessage => _errorMessage;
  String get aiResponse => _aiResponse;
  bool get useAI => _useAI;

  Future<void> initializeTerminal() async {
    _state = TerminalState.initializing;
    _output = 'Initializing AI Terminal...\n';
    notifyListeners();

    try {
      _output += 'Extracting proot binary...\n';
      notifyListeners();
      await _prootService.extractProot();

      _output += 'Extracting rootfs...\n';
      notifyListeners();
      await _prootService.extractRootfs();

      _output += 'Setting up environment...\n';
      notifyListeners();
      await _prootService.setupEnvironment();

      _state = TerminalState.ready;
      _output += '✓ Terminal ready!\n\n';
      _output += 'Welcome to AI Terminal Pro\n';
      _output += 'Type commands or enable AI mode for smart suggestions.\n\n';
    } catch (e) {
      _state = TerminalState.error;
      _errorMessage = e.toString();
      _output += '✗ Error: $_errorMessage\n';
    }
    notifyListeners();
  }

  void updateInput(String value) {
    _input = value;
    notifyListeners();
  }

  void toggleAI() {
    _useAI = !_useAI;
    notifyListeners();
  }

  Future<void> executeCommand(String command) async {
    if (command.trim().isEmpty) return;

    _isProcessing = true;
    _history.add({'type': 'command', 'content': command});
    _output += '$_currentPath \$ $command\n';
    notifyListeners();

    try {
      if (_useAI && !_isSystemCommand(command)) {
        final aiResult = await _aiService.getCommandSuggestion(command);
        _aiResponse = aiResult;
        _history.add({'type': 'ai', 'content': aiResult});
        _output += '🤖 AI: $aiResult\n\n';
      } else {
        final result = await _prootService.executeCommand(command);
        _history.add({'type': 'output', 'content': result});
        _output += '$result\n';
        _updatePath(command);
      }
    } catch (e) {
      _history.add({'type': 'error', 'content': e.toString()});
      _output += 'Error: ${e.toString()}\n';
    }

    _input = '';
    _isProcessing = false;
    notifyListeners();
  }

  bool _isSystemCommand(String command) {
    final systemCommands = ['ls', 'cd', 'pwd', 'cat', 'echo', 'mkdir', 'rm', 'cp', 'mv', 'chmod', 'clear', 'exit', 'help', 'whoami', 'date'];
    final firstWord = command.split(' ').first;
    return systemCommands.contains(firstWord);
  }

  void _updatePath(String command) {
    if (command.startsWith('cd ')) {
      final path = command.substring(3).trim();
      if (path == '~' || path == '/') {
        _currentPath = '~';
      } else if (path == '..') {
        final parts = _currentPath.split('/');
        if (parts.length > 1) {
          parts.removeLast();
          _currentPath = parts.join('/');
          if (_currentPath.isEmpty) _currentPath = '~';
        }
      } else {
        _currentPath = '$_currentPath/$path';
      }
    }
  }

  void clearTerminal() {
    _output = '';
    _history.clear();
    notifyListeners();
  }

  void resetTerminal() {
    _state = TerminalState.idle;
    _output = '';
    _input = '';
    _currentPath = '~';
    _isProcessing = false;
    _history.clear();
    _errorMessage = '';
    _aiResponse = '';
    notifyListeners();
  }
}
