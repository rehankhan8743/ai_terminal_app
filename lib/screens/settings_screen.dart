import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final key = await _storage.read(key: 'openai_api_key') ?? '';
    _apiKeyController.text = key;
    if (key.isNotEmpty && mounted) {
      context.read<AppState>().setApiKey(key);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveApiKey(String key) async {
    await _storage.write(key: 'openai_api_key', value: key);
    if (mounted) {
      context.read<AppState>().setApiKey(key);
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'monospace',
            color: Color(0xFF3FB950),
          ),
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(
                'Terminal',
                [
                  _buildInfoTile('Status', state.state.name),
                  _buildInfoTile('Current Path', state.currentPath),
                  _buildInfoTile('Session', state.sessionId.substring(0, 8)),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                'AI Configuration',
                [
                  SwitchListTile(
                    title: const Text(
                      'AI Mode',
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                    subtitle: const Text(
                      'Get smart command suggestions',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                    value: state.useAI,
                    onChanged: (_) => state.toggleAI(),
                    activeColor: const Color(0xFF3FB950),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OPENAI API KEY',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _apiKeyController,
                          obscureText: true,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'sk-...',
                            hintStyle: TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.grey[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0D1117),
                          ),
                          onSubmitted: (value) => _saveApiKey(value),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _saveApiKey(_apiKeyController.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3FB950),
                              foregroundColor: Colors.black,
                            ),
                            child: const Text(
                              'Save API Key',
                              style: TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Model',
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                    trailing: DropdownButton<String>(
                      value: state.selectedModel,
                      dropdownColor: const Color(0xFF161B22),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFF3FB950),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'gpt-3.5-turbo', child: Text('GPT-3.5')),
                        DropdownMenuItem(value: 'gpt-4', child: Text('GPT-4')),
                        DropdownMenuItem(value: 'gpt-4-turbo', child: Text('GPT-4 Turbo')),
                      ],
                      onChanged: (value) {
                        if (value != null) state.setModel(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                'Actions',
                [
                  ListTile(
                    leading: const Icon(Icons.refresh, color: Colors.orange),
                    title: const Text(
                      'Reset Terminal',
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                    subtitle: const Text(
                      'Clear all data and restart',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF161B22),
                          title: const Text(
                            'Reset Terminal?',
                            style: TextStyle(fontFamily: 'monospace'),
                          ),
                          content: const Text(
                            'This will clear all terminal data.',
                            style: TextStyle(fontFamily: 'monospace'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                state.resetTerminal();
                                Navigator.pop(ctx);
                              },
                              child: const Text(
                                'Reset',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'AI Terminal Pro v1.0',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Color(0xFF3FB950),
        ),
      ),
    );
  }
}
