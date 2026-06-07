import 'dart:io';
import 'package:flutter/services.dart';
import 'package:archive/archive_io.dart';

class ProotService {
  static const MethodChannel _channel = MethodChannel('com.ai_terminal_pro/proot');
  static const EventChannel _stream = EventChannel('com.ai_terminal_pro/stream');

  static Stream<dynamic> get output => _stream.receiveBroadcastStream();

  static Future<Map<String, String>> initEnvironment() async {
    final dirs = await _channel.invokeMethod('getDirs');
    final nativeLibDir = dirs['nativeLibDir'];
    final filesDir = dirs['filesDir'];

    final prootPath = '$nativeLibDir/libproot.so';
    final rootfsPath = '$filesDir/rootfs';

    if (!Directory(rootfsPath).existsSync()) {
      Directory(rootfsPath).createSync(recursive: true);

      final tarPath = '$filesDir/rootfs.tar.gz';
      final byteData = await rootBundle.load('assets/rootfs.tar.gz');
      final file = File(tarPath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      try {
        final result = await Process.run('tar', ['-xzf', tarPath, '-C', rootfsPath]);
        if (result.exitCode != 0) throw Exception('Native tar failed');
      } catch (e) {
        final bytes = await file.readAsBytes();
        final archive = TarDecoder().decodeBuffer(GZipDecoder().decodeBuffer(bytes));
        extractArchiveToDisk(archive, rootfsPath);
      }

      file.deleteSync();
    }

    return {'proot': prootPath, 'rootfs': rootfsPath};
  }

  static Future<void> start(String prootPath, String rootfsPath) async {
    await _channel.invokeMethod('start', {
      'rootfsPath': rootfsPath,
      'prootPath': prootPath,
    });
  }

  static Future<void> write(String cmd) async {
    await _channel.invokeMethod('write', {'cmd': cmd});
  }
}
