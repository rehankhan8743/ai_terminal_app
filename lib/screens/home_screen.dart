import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              return IconButton(
                icon: Icon(
                  state.isReady ? Icons.check_circle : Icons.sync,
                  color: state.isReady ? const Color(0xFF3FB950) : Colors.orange,
                ),
                onPressed: () {},
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
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.isReady) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF3FB950)),
                  SizedBox(height: 16),
                  Text(
                    'Initializing terminal...',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFF8B949E),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: TerminalView(
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
