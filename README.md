# AI Terminal Pro

A production-ready AI Proot Terminal for Android with smart command suggestions and chat interface.

## Features

- Full Linux terminal via proot
- AI-powered command suggestions (OpenAI API + local)
- Chat interface for AI conversations
- Secure API key storage
- xterm.js-style terminal emulation
- Dark hacker-style UI
- Command history
- Package management (apt/apk)

## Project Structure

```
ai_terminal_pro/
├── android/
│   └── app/
│       └── src/main/
│           ├── AndroidManifest.xml
│           ├── jniLibs/
│           │   └── arm64-v8a/
│           │       └── libproot.so
│           └── kotlin/.../MainActivity.kt
├── assets/
│   └── rootfs.tar.gz
├── lib/
│   ├── main.dart
│   ├── providers/
│   │   └── app_state.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── chat_screen.dart
│   │   └── settings_screen.dart
│   └── services/
│       ├── ai_service.dart
│       └── proot_service.dart
└── pubspec.yaml
```

## Dependencies

- `xterm: ^3.5.0` - Terminal emulation
- `flutter_chat_ui: ^1.6.10` - Chat interface
- `flutter_chat_types: ^3.6.2` - Chat types
- `dio: ^5.4.0` - HTTP client
- `provider: ^6.1.1` - State management
- `archive: ^3.4.10` - Archive extraction
- `flutter_secure_storage: ^9.0.0` - Secure storage
- `uuid: ^4.3.3` - UUID generation

## Setup

### 1. Get proot binary
Extract `libproot.so` from a Termux APK or build from source.
Place it in: `android/app/src/main/jniLibs/arm64-v8a/libproot.so`

### 2. Get rootfs
Download Alpine Linux minirootfs:
```bash
wget https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-minirootfs-3.19.1-x86_64.tar.gz
mv alpine-minirootfs-3.19.1-x86_64.tar.gz assets/rootfs.tar.gz
```

### 3. Run
```bash
flutter pub get
flutter run
```

## Build

```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release

# App Bundle
flutter build appbundle --release
```

## AI Configuration

1. Open Settings
2. Enter your OpenAI API key
3. Select model (GPT-3.5/GPT-4)
4. Toggle AI Mode ON

## GitHub Actions

Push to `main` or `develop` triggers:
- Debug APK build
- Release APK + AAB build
- Automated GitHub Release (main branch only)

## License

MIT
