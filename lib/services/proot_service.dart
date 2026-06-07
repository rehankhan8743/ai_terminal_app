import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class PRootService {
  static const MethodChannel _channel = MethodChannel('com.ai_terminal/proot');
  String _prootPath = '';
  String _rootfsPath = '';
  String _shellPath = '';

  String get prootPath => _prootPath;
  String get rootfsPath => _rootfsPath;

  Future<void> extractProot() async {
    try {
      final bool success = await _channel.invokeMethod('extractProot');
      if (!success) {
        throw Exception('Failed to extract proot binary');
      }
      _prootPath = await _channel.invokeMethod('getProotPath');
    } catch (e) {
      throw Exception('Proot extraction failed: $e');
    }
  }

  Future<void> extractRootfs() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final rootfsTar = File('${appDir.parent.path}/app_flutter/assets/rootfs.tar.gz');

      if (!rootfsTar.existsSync()) {
        throw Exception('rootfs.tar.gz not found in assets');
      }

      final bool success = await _channel.invokeMethod('extractRootfs', {
        'path': rootfsTar.path,
      });

      if (!success) {
        throw Exception('Failed to extract rootfs');
      }

      _rootfsPath = '${appDir.path}/rootfs';
    } catch (e) {
      throw Exception('Rootfs extraction failed: $e');
    }
  }

  Future<void> setupEnvironment() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final rootfsDir = Directory('${appDir.path}/rootfs');

      if (!rootfsDir.existsSync()) {
        throw Exception('Rootfs directory not found');
      }

      _shellPath = '${rootfsDir.path}/bin/sh';

      if (!File(_shellPath).existsSync()) {
        _shellPath = '${rootfsDir.path}/bin/bash';
        if (!File(_shellPath).existsSync()) {
          _shellPath = '/system/bin/sh';
        }
      }

      await _createInitScript(rootfsDir);
    } catch (e) {
      throw Exception('Environment setup failed: $e');
    }
  }

  Future<void> _createInitScript(Directory rootfsDir) async {
    final initScript = File('${rootfsDir.path}/etc/init.sh');
    await initScript.create(recursive: true);
    await initScript.writeAsString('''#!/bin/sh
export HOME=/root
export PATH=/usr/local/bin:/usr/bin:/bin
export TERM=xterm-256color
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

# Create necessary directories
mkdir -p /tmp /var/run /proc /sys /dev

# Mount procfs
mount -t proc proc /proc 2>/dev/null || true

exec /bin/sh
''');
  }

  Future<String> executeCommand(String command) async {
    try {
      final result = await Process.run(
        _prootPath,
        [
          '-r', _rootfsPath,
          '-w', '/root',
          '-b', '/proc',
          '-b', '/sys',
          '-b', '/dev',
          '-b', '/tmp',
          '--link2symlink',
          '--kill-on-exit',
          '--root-id',
          '--', _shellPath, '-c', command,
        ],
        environment: {
          'HOME': '/root',
          'PATH': '/usr/local/bin:/usr/bin:/bin',
          'TERM': 'xterm-256color',
          'LANG': 'C.UTF-8',
        },
        timeout: const Duration(seconds: 30),
      );

      if (result.exitCode != 0 && result.stderr.isNotEmpty) {
        return result.stdout.toString() + '\n' + result.stderr.toString();
      }

      return result.stdout.toString();
    } catch (e) {
      throw Exception('Command execution failed: $e');
    }
  }

  Future<String> getInstalledPackages() async {
    try {
      final result = await executeCommand('apk list --installed 2>/dev/null || dpkg -l 2>/dev/null || echo "Package manager not available"');
      return result;
    } catch (e) {
      return 'Unable to list packages';
    }
  }

  Future<void> installPackage(String packageName) async {
    try {
      await executeCommand('apk add $packageName 2>/dev/null || apt-get install -y $packageName 2>/dev/null');
    } catch (e) {
      throw Exception('Package installation failed: $e');
    }
  }
}
