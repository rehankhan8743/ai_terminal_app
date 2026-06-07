import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..initialize(),
      child: const AITerminalProApp(),
    ),
  );
}

class AITerminalProApp extends StatelessWidget {
  const AITerminalProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Terminal Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        cardColor: const Color(0xFF161B22),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF58A6FF),
          secondary: Color(0xFF3FB950),
          surface: Color(0xFF161B22),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'monospace', color: Color(0xFFE6EDF3)),
          bodyMedium: TextStyle(fontFamily: 'monospace', color: Color(0xFFE6EDF3)),
          bodySmall: TextStyle(fontFamily: 'monospace', color: Color(0xFF8B949E)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
