import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xterm/xterm.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import '../providers/app_state.dart';
import '../services/ai_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _ai = const types.User(id: 'ai', firstName: 'Agent');
  final _uuid = const Uuid();
  StreamSubscription? _aiSubscription;

  @override
  void initState() {
    super.initState();
    _addSystemMessage("System booted. I am your autonomous Linux agent.");
  }

  void _addSystemMessage(String text) {
    if (!mounted) return;
    setState(() {
      _messages.insert(0, types.TextMessage(
        author: _ai, createdAt: DateTime.now().millisecondsSinceEpoch,
        id: _uuid.v4(), text: text,
      ));
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    final appState = Provider.of<AppState>(context, listen: false);

    if (appState.apiKey.isEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
      return;
    }

    final userMsg = types.TextMessage(
      author: _user, createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(), text: message.text,
    );

    if(mounted) setState(() => _messages.insert(0, userMsg));

    await _runAgentLoop(message.text, appState);
  }

  Future<void> _runAgentLoop(String prompt, AppState appState) async {
    final aiService = AIService(apiKey: appState.apiKey);

    await _aiSubscription?.cancel();

    final aiMsgId = _uuid.v4();
    if(mounted) {
      setState(() {
        _messages.insert(0, types.TextMessage(
          author: _ai, createdAt: DateTime.now().millisecondsSinceEpoch,
          id: aiMsgId, text: '',
        ));
      });
    }

    String fullResponse = "";

    _aiSubscription = aiService.streamChat(prompt, appState.terminalBuffer).listen(
      (token) {
        if (!mounted) return;
        fullResponse += token;
        setState(() {
          final index = _messages.indexWhere((m) => m.id == aiMsgId);
          if (index != -1) {
            _messages[index] = types.TextMessage(
              author: _ai, createdAt: _messages[index].createdAt,
              id: aiMsgId, text: fullResponse,
            );
          }
        });
      },
      onDone: () async {
        if (!mounted) return;

        final cmdMatch = RegExp(r'<cmd>(.*?)</cmd>').firstMatch(fullResponse);
        if (cmdMatch != null) {
          final cmd = cmdMatch.group(1)!.trim();
          _addSystemMessage("⚙️ Executing: `$cmd`");

          await appState.runCommand(cmd);

          await Future.delayed(const Duration(seconds: 2));

          _addSystemMessage("🧠 Analyzing output...");

          await _runAgentLoop(
            "Here is the output of the command you just ran:\n\n${appState.terminalBuffer}\n\nPlease explain the result or tell me if the task is complete.",
            appState,
          );
        }
      },
      onError: (e) {
        if (mounted) _addSystemMessage("AI Error: $e");
      },
    );
  }

  @override
  void dispose() {
    _aiSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Proot Terminal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen())),
          )
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          if (!state.isReady) return const Center(child: CircularProgressIndicator());

          return Column(
            children: [
              Expanded(
                flex: 1,
                child: Chat(
                  messages: _messages,
                  onSendPressed: _handleSendPressed,
                  user: _user,
                  theme: const DarkChatTheme(),
                ),
              ),
              Container(height: 2, color: Colors.blueAccent),
              Expanded(
                flex: 1,
                child: TerminalView(
                  state.terminal,
                  backgroundOpacity: 0.95,
                  autofocus: true,
                  readOnly: false,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
