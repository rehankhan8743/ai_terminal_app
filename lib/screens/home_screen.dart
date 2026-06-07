import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'settings_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.terminal, color: Color(0xFF3FB950), size: 20),
            SizedBox(width: 8),
            Text(
              'AI Terminal Pro',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Color(0xFFC9D1D9),
              ),
            ),
          ],
        ),
        actions: [
          Consumer<AppState>(
            builder: (context, state, _) {
              return Row(
                children: [
                  const Text(
                    'AI',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Switch(
                    value: state.useAI,
                    onChanged: (_) => state.toggleAI(),
                    activeColor: const Color(0xFF3FB950),
                    activeTrackColor: const Color(0xFF3FB950).withOpacity(0.3),
                  ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF8B949E)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF8B949E)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF8B949E)),
            onPressed: () {
              context.read<AppState>().clearTerminal();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AppState>(
              builder: (context, state, _) {
                return TerminalView(
                  terminal: state.terminal,
                  textStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: Color(0xFFE6EDF3),
                    height: 1.5,
                  ),
                  backgroundColor: const Color(0xFF0D1117),
                  cursorColor: const Color(0xFF3FB950),
                  selectionColor: const Color(0xFF58A6FF).withOpacity(0.3),
                  onInput: (input) {
                    state.executeCommand(input);
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Container(
          color: const Color(0xFF161B22),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Text(
                '${state.currentPath} \$ ',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Color(0xFF3FB950),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Color(0xFFE6EDF3),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Type command or "ai <question>"...',
                    hintStyle: TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFF484F58),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      state.executeCommand(value.trim());
                      _controller.clear();
                    }
                    _focusNode.requestFocus();
                  },
                  enabled: state.state == AppStateType.ready && !state.isProcessing,
                ),
              ),
              if (state.isProcessing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF58A6FF),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Color(0xFF58A6FF),
                    size: 20,
                  ),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      state.executeCommand(_controller.text.trim());
                      _controller.clear();
                    }
                    _focusNode.requestFocus();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
