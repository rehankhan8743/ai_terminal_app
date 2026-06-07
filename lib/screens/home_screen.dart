import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        context.read<AppState>().initializeTerminal();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Terminal',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
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
                    activeColor: Colors.green,
                    activeTrackColor: Colors.green.withOpacity(0.3),
                  ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: () {
              context.read<AppState>().clearTerminal();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: Container(
                color: const Color(0xFF0D1117),
                padding: const EdgeInsets.all(12),
                child: Consumer<AppState>(
                  builder: (context, state, _) {
                    _scrollToBottom();
                    return SingleChildScrollView(
                      controller: _scrollController,
                      child: Text(
                        state.output,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: Color(0xFFE6EDF3),
                          height: 1.5,
                        ),
                      ),
                    );
                  },
                ),
              ),
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
                  color: Colors.green,
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
                    hintText: 'Enter command...',
                    hintStyle: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.grey,
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
                  },
                  enabled: state.state == TerminalState.ready && !state.isProcessing,
                ),
              ),
              if (state.isProcessing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
