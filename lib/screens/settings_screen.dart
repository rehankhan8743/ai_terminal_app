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
    final key = await _storage.read(key: 'api_key') ?? '';
    _apiKeyController.text = key;
    if (key.isNotEmpty && mounted) {
      context.read<AppState>().saveApiKey(key);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveApiKey(String key) async {
    await _storage.write(key: 'api_key', value: key);
    if (mounted) {
      context.read<AppState>().saveApiKey(key);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key saved', style: TextStyle(fontFamily: 'monospace')),
          backgroundColor: Color(0xFF3FB950),
        ),
      );
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
                  _buildInfoTile('Status', state.isReady ? 'Ready' : 'Initializing'),
                  _buildInfoTile('Buffer', '${state.terminalBuffer.length} chars'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                'AI Configuration',
                [
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
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                'Actions',
                [
                  ListTile(
                    leading: const Icon(Icons.refresh, color: Colors.orange),
                    title: const Text(
                      'Restart Terminal',
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                    subtitle: const Text(
                      'Re-initialize proot session',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF161B22),
                          title: const Text(
                            'Restart Terminal?',
                            style: TextStyle(fontFamily: 'monospace'),
                          ),
                          content: const Text(
                            'This will restart the proot session.',
                            style: TextStyle(fontFamily: 'monospace'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                state.init();
                              },
                              child: const Text(
                                'Restart',
                                style: TextStyle(color: Colors.orange),
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
