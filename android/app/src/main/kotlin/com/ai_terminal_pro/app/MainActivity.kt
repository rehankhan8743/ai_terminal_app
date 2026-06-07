package com.ai_terminal_pro.app

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.*

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.ai_terminal_pro/proot"
    private val STREAM = "com.ai_terminal_pro/stream"
    private var prootProcess: Process? = null
    private var eventSink: EventChannel.EventSink? = null
    private var outputStream: OutputStream? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, STREAM).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { eventSink = events }
                override fun onCancel(arguments: Any?) { eventSink = null }
            }
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDirs" -> {
                    result.success(mapOf(
                        "nativeLibDir" to applicationInfo.nativeLibraryDir,
                        "filesDir" to filesDir.absolutePath
                    ))
                }
                "start" -> {
                    val rootfsPath = call.argument<String>("rootfsPath")
                    val prootPath = call.argument<String>("prootPath")
                    startProotSession(rootfsPath!!, prootPath!!)
                    result.success(null)
                }
                "write" -> {
                    val cmd = call.argument<String>("cmd")
                    outputStream?.write("$cmd".toByteArray())
                    outputStream?.flush()
                    result.success(null)
                }
                "stop" -> {
                    prootProcess?.destroy()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startProotSession(rootfsPath: String, prootPath: String) {
        try {
            val prootDir = File(filesDir, "proot_bins")
            prootDir.mkdirs()

            val prootBin = File(prootDir, "proot")
            val srcProot = File(prootPath)
            if (!prootBin.exists() || prootBin.length() != srcProot.length()) {
                srcProot.copyTo(prootBin, overwrite = true)
            }
            prootBin.setExecutable(true)

            val nativeLibDir = applicationInfo.nativeLibraryDir
            val libtallocSrc = File(nativeLibDir, "libtalloc.so.2")
            val libtallocDst = File(prootDir, "libtalloc.so.2")
            if (libtallocSrc.exists() && (!libtallocDst.exists() || libtallocDst.length() != libtallocSrc.length())) {
                libtallocSrc.copyTo(libtallocDst, overwrite = true)
            }

            val cmd = listOf(
                prootBin.absolutePath,
                "-r", rootfsPath,
                "-b", "/dev",
                "-b", "/proc",
                "-b", "/sys",
                "-w", "/root",
                "-0",
                "/bin/sh"
            )

            val pb = ProcessBuilder(cmd).redirectErrorStream(true)
            pb.environment().apply {
                put("TERM", "xterm-256color")
                put("HOME", "/root")
                put("PROOT_NO_SECCOMP", "1")
                put("LD_LIBRARY_PATH", "$prootDir:/system/lib64")
            }

            prootProcess = pb.start()
            outputStream = prootProcess?.outputStream

            Thread {
                val reader = BufferedReader(InputStreamReader(prootProcess?.inputStream))
                val buffer = CharArray(4096)
                var bytesRead: Int
                while (reader.read(buffer).also { bytesRead = it } != -1) {
                    val output = String(buffer, 0, bytesRead)
                    mainHandler.post { eventSink?.success(output) }
                }
            }.start()
        } catch (e: Exception) {
            mainHandler.post { eventSink?.error("PROOT_ERROR", e.message, null) }
        }
    }
}
