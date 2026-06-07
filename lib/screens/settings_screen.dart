import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'monospace',
            color: Colors.green,
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
                  _buildInfoTile('History', '${state.history.length} commands'),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                'AI Settings',
                [
                  _buildSwitchTile(
                    'AI Mode',
                    'Get smart command suggestions',
                    state.useAI,
                    (_) => state.toggleAI(),
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
                                state.initializeTerminal();
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
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'monospace'),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.green,
    );
  }
}
