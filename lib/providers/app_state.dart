import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';
import 'package:uuid/uuid.dart';
import '../services/proot_service.dart';
import '../services/ai_service.dart';

enum AppStateType { idle, initializing, ready, error }

class AppState extends ChangeNotifier {
  final AIService _aiService = AIService();
  final Uuid _uuid = const Uuid();

  late Terminal _terminal;
  Terminal get terminal => _terminal;

  AppStateType _state = AppStateType.idle;
  String _currentPath = '~';
  bool _isProcessing = false;
  bool _useAI = false;
  String _apiKey = '';
  String _selectedModel = 'gpt-3.5-turbo';
  List<Map<String, dynamic>> _chatMessages = [];
  String _sessionId = '';
  String _prootPath = '';
  String _rootfsPath = '';
  StreamSubscription? _outputSubscription;

  AppStateType get state => _state;
  String get currentPath => _currentPath;
  bool get isProcessing => _isProcessing;
  bool get useAI => _useAI;
  String get apiKey => _apiKey;
  String get selectedModel => _selectedModel;
  List<Map<String, dynamic>> get chatMessages => _chatMessages;
  String get sessionId => _sessionId;

  Future<void> initialize() async {
    _state = AppStateType.initializing;
    _sessionId = _uuid.v4();
    _terminal = Terminal(maxLines: 5000);

    _terminal.write('Initializing AI Terminal Pro...\r\n');
    notifyListeners();

    try {
      _terminal.write('Setting up environment...\r\n');
      notifyListeners();

      final dirs = await ProotService.initEnvironment();
      _prootPath = dirs['proot']!;
      _rootfsPath = dirs['rootfs']!;

      _terminal.write('Starting proot session...\r\n');
      notifyListeners();

      await ProotService.start(_prootPath, _rootfsPath);

      _outputSubscription = ProotService.output.listen(
        (data) {
          _terminal.write(data.toString());
          notifyListeners();
        },
        onError: (error) {
          _terminal.write('\x1B[31mStream error: $error\x1B[0m\r\n');
          notifyListeners();
        },
      );

      _state = AppStateType.ready;
      _terminal.write('\x1B[32m✓ Terminal ready!\x1B[0m\r\n');
      _terminal.write('\x1B[36mWelcome to AI Terminal Pro\x1B[0m\r\n');
      _terminal.write('Type commands or enable AI mode.\r\n\r\n');
    } catch (e) {
      _state = AppStateType.error;
      _terminal.write('\x1B[31m✗ Error: $e\x1B[0m\r\n');
    }
    notifyListeners();
  }

  void toggleAI() {
    _useAI = !_useAI;
    notifyListeners();
  }

  void setApiKey(String key) {
    _apiKey = key;
    _aiService.setApiKey(key);
    notifyListeners();
  }

  void setModel(String model) {
    _selectedModel = model;
    _aiService.setModel(model);
    notifyListeners();
  }

  Future<void> executeCommand(String command) async {
    if (command.trim().isEmpty) return;

    _isProcessing = true;
    notifyListeners();

    if (command == 'clear') {
      _terminal.clear();
      _isProcessing = false;
      notifyListeners();
      return;
    }

    if (command == 'help') {
      _terminal.write('\x1B[36mAvailable commands:\x1B[0m\r\n');
      _terminal.write('  help          - Show this help\r\n');
      _terminal.write('  clear         - Clear terminal\r\n');
      _terminal.write('  ls, cd, cat   - Standard Linux commands\r\n');
      _terminal.write('  ai <prompt>   - Ask AI assistant\r\n');
      _terminal.write('  status        - Show system status\r\n');
      _terminal.write('\r\n');
      _isProcessing = false;
      notifyListeners();
      return;
    }

    if (command == 'status') {
      _terminal.write('\x1B[36mSystem Status:\x1B[0m\r\n');
      _terminal.write('  Proot: ${_prootPath.isNotEmpty ? "Ready" : "Not Ready"}\r\n');
      _terminal.write('  Rootfs: ${_rootfsPath.isNotEmpty ? "Ready" : "Not Ready"}\r\n');
      _terminal.write('  AI Mode: ${_useAI ? "ON" : "OFF"}\r\n');
      _terminal.write('  Session: $_sessionId\r\n');
      _terminal.write('\r\n');
      _isProcessing = false;
      notifyListeners();
      return;
    }

    if (command.startsWith('ai ') || command.startsWith('ask ')) {
      final prompt = command.substring(command.indexOf(' ') + 1);
      await _askAi(prompt);
      return;
    }

    try {
      await ProotService.write(command);
      _updatePath(command);
    } catch (e) {
      _terminal.write('\x1B[31mError: $e\x1B[0m\r\n');
    }

    _isProcessing = false;
    notifyListeners();
  }

  Future<void> _askAi(String prompt) async {
    _terminal.write('\x1B[35mAI thinking...\x1B[0m\r\n');
    notifyListeners();

    try {
      final response = await _aiService.getCommandSuggestion(prompt);
      _terminal.write('\x1B[35mAI: $response\x1B[0m\r\n\r\n');

      _chatMessages.add({
        'id': _uuid.v4(),
        'role': 'user',
        'content': prompt,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _chatMessages.add({
        'id': _uuid.v4(),
        'role': 'assistant',
        'content': response,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _terminal.write('\x1B[31mAI Error: $e\x1B[0m\r\n');
    }

    _isProcessing = false;
    notifyListeners();
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
    _terminal.clear();
    notifyListeners();
  }

  void clearChat() {
    _chatMessages.clear();
    notifyListeners();
  }

  void resetTerminal() {
    _outputSubscription?.cancel();
    _state = AppStateType.idle;
    _currentPath = '~';
    _isProcessing = false;
    _chatMessages.clear();
    _sessionId = _uuid.v4();
    _terminal.clear();
    notifyListeners();
    initialize();
  }

  @override
  void dispose() {
    _outputSubscription?.cancel();
    ProotService.write('exit');
    super.dispose();
  }
}
