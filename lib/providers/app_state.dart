import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/proot_service.dart';

class AppState extends ChangeNotifier {
  final terminal = Terminal();
  String terminalBuffer = "";
  bool isReady = false;
  String apiKey = "";
  String _prootPath = "";
  String _rootfsPath = "";
  final _storage = const FlutterSecureStorage();

  // Batching variables to prevent UI Freeze
  String _pendingOutput = "";
  Timer? _batchTimer;

  Future<void> init() async {
    apiKey = await _storage.read(key: 'api_key') ?? '';

    final dirs = await ProotService.initEnvironment();
    _prootPath = dirs['proot']!;
    _rootfsPath = dirs['rootfs']!;

    await ProotService.start(_prootPath, _rootfsPath);

    ProotService.output.listen((data) {
      final text = data.toString();
      _pendingOutput += text;
      _batchTimer ??= Timer(const Duration(milliseconds: 100), _flushTerminalBuffer);
    });

    terminal.onOutput = (data) {
      ProotService.write(data);
    };

    isReady = true;
    notifyListeners();
  }

  void _flushTerminalBuffer() {
    if (_pendingOutput.isEmpty) return;

    terminal.write(_pendingOutput);
    terminalBuffer += _pendingOutput;

    if (terminalBuffer.length > 8000) {
      terminalBuffer = terminalBuffer.substring(terminalBuffer.length - 8000);
    }

    _pendingOutput = "";
    _batchTimer = null;
    notifyListeners();
  }

  Future<void> saveApiKey(String key) async {
    apiKey = key;
    await _storage.write(key: 'api_key', value: key);
    notifyListeners();
  }

  Future<void> runCommand(String cmd) async {
    terminalBuffer = "";
    await ProotService.write("$cmd\n");
  }

  @override
  void dispose() {
    _batchTimer?.cancel();
    super.dispose();
  }
}
