# AI Terminal Pro

A production-ready AI Proot Terminal for Android with autonomous agent loop.

## Features

- Full Linux terminal via proot
- AI Agent that executes commands and analyzes output
- Split view: Chat + Terminal
- Streaming AI responses (SSE)
- Secure API key storage
- xterm terminal emulation

## Project Structure

```
ai_terminal_pro/
├── android/app/src/main/
│   ├── AndroidManifest.xml
│   ├── jniLibs/arm64-v8a/
│   │   └── libproot.so        ← (Termux APK থেকে নেওয়া)
│   └── kotlin/.../MainActivity.kt
├── assets/
│   └── rootfs.tar.gz           ← (Alpine Linux minirootfs)
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

## ⚠️ শেষ এবং সবচেয়ে গুরুত্বপূর্ণ ধাপ

কোড রান করার আগে আপনাকে ম্যানুয়ালি ২টি ফাইল যোগ করতে হবে:

### 1. `libproot.so` জোগাড় করা

1. প্লে-স্টোর থেকে **Termux** অ্যাপটি ডাউনলোড করুন
2. এটি একটি `.apk` ফাইল - এটিকে `.zip` হিসেবে রিনেম করুন
3. এক্সট্রাক্ট করুন
4. `lib/arm64-v8a/` ফোল্ডারের ভেতর থেকে `libproot.so` ফাইলটি কপি করুন
5. আপনার ফ্লাটার প্রজেক্টে `android/app/src/main/jniLibs/arm64-v8a/` ফোল্ডার তৈরি করুন
6. `libproot.so` সেখানে পেস্ট করুন

### 2. `rootfs.tar.gz` জোগাড় করা

1. [Alpine Linux Minirootfs](https://alpinelinux.org/downloads/) অফিসিয়াল সাইটে যান
2. `aarch64` ভার্সনের `.tar.gz` ফাইলটি ডাউনলোড করুন (মাত্র ৩-৪ MB)
3. এটিকে রিনেম করে `rootfs.tar.gz` নাম দিন
4. আপনার প্রজেক্টের `assets/` ফোল্ডারে রাখুন

## রান করার নিয়ম

```bash
flutter clean
flutter pub get
flutter run
```

**গুরুত্বপূর্ণ:** Real ARM64 Android Phone-এ রান করুন (Emulator নয়)।

## Build

```bash
flutter build apk --release
```

## AI Configuration

1. Settings এ যান
2. OpenAI API Key দিন
3. Chat-এ প্রশ্ন করুন - AI অটোমেটিকলি কমান্ড এক্সিকিউট করবে

## License

MIT
