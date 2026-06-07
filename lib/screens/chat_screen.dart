import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final Uuid _uuid = const Uuid();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<types.Message> _buildMessages(List<Map<String, dynamic>> chatMessages) {
    final messages = chatMessages.map((msg) {
      return types.TextMessage(
        id: msg['id'] ?? _uuid.v4(),
        author: types.User(
          id: msg['role'] == 'user' ? 'user' : 'assistant',
          firstName: msg['role'] == 'user' ? 'You' : 'AI',
        ),
        text: msg['content'] ?? '',
      );
    }).toList();

    messages.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return messages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Color(0xFFD2A8FF), size: 20),
            SizedBox(width: 8),
            Text(
              'AI Assistant',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Color(0xFFC9D1D9),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF8B949E)),
            onPressed: () {
              context.read<AppState>().clearChat();
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final messages = _buildMessages(state.chatMessages);

          return Column(
            children: [
              Expanded(
                child: Chat(
                  messages: messages,
                  user: const types.User(id: 'user', firstName: 'You'),
                  onSendPressed: (types.PartialText message) {
                    state.executeCommand('ai ${message.text}');
                  },
                  theme: const DefaultChatTheme(
                    backgroundColor: Color(0xFF0D1117),
                    inputBackgroundColor: Color(0xFF161B22),
                    inputTextColor: Color(0xFFE6EDF3),
                    inputTextCursorColor: Color(0xFF3FB950),
                    primaryColor: Color(0xFF161B22),
                    secondaryColor: Color(0xFF0D1117),
                    sentMessageBodyTextStyle: TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFFE6EDF3),
                    ),
                    receivedMessageBodyTextStyle: TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFFE6EDF3),
                    ),
                    inputBorderRadius: BorderRadius.all(Radius.circular(8)),
                    inputMargin: EdgeInsets.all(8),
                  ),
                  emptyState: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.smart_toy_outlined,
                          size: 64,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ask AI anything about Linux commands',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Type a message to start',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
