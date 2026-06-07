# AI Terminal Pro

AI-powered terminal emulator for Android with proot Linux environment and smart command suggestions.

## Features

- Full Linux terminal via proot
- AI-powered command suggestions
- Alpine Linux rootfs support
- Dark hacker-style UI
- Command history

## Project Structure

```
ai_terminal_app/
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
│   │   └── settings_screen.dart
│   └── services/
│       ├── ai_service.dart
│       └── proot_service.dart
└── pubspec.yaml
```

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
flutter build apk --release
```

## GitHub Actions

Push to `main` branch triggers automatic build. APK available as artifact.

## AI Mode

Toggle AI mode in the app to get smart command suggestions powered by OpenAI API or local suggestions.

## License

MIT
