# AI Terminal Pro

A production-ready AI Proot Terminal for Android with autonomous agent loop.

## Features

- Full Linux terminal via proot (static binary, bundled)
- AI Agent that executes commands and analyzes output
- Split view: Chat + Terminal
- Streaming AI responses (SSE)
- Secure API key storage
- xterm terminal emulation
- Alpine Linux aarch64 rootfs (bundled)

## Project Structure

```
ai_terminal_pro/
├── android/app/src/main/
│   ├── AndroidManifest.xml
│   ├── jniLibs/arm64-v8a/
│   │   ├── libproot.so        ← static proot binary (bundled)
│   │   └── libtalloc.so.2     ← talloc library (bundled)
│   └── kotlin/.../MainActivity.kt
├── assets/
│   └── rootfs.tar.gz           ← Alpine Linux minirootfs (bundled)
├── lib/
│   ├── main.dart
│   ├── providers/app_state.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   └── settings_screen.dart
│   └── services/
│       ├── ai_service.dart
│       └── proot_service.dart
└── pubspec.yaml
```

## Run

```bash
flutter clean
flutter pub get
flutter build apk --release
```

**Note:** Run on a real ARM64 Android phone (not emulator).

## AI Configuration

1. Open the app
2. Go to Settings
3. Enter your OpenAI API Key
4. Chat - AI will auto-execute commands and analyze output

## License

MIT
