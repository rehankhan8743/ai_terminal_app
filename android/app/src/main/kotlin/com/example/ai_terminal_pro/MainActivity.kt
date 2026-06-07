package com.example.ai_terminal_pro

import android.content.Context
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ai_terminal/proot"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "extractProot" -> {
                    val success = extractProotBinary()
                    result.success(success)
                }
                "extractRootfs" -> {
                    val rootfsPath = call.argument<String>("path") ?: ""
                    val success = extractRootfs(rootfsPath)
                    result.success(success)
                }
                "getProotPath" -> {
                    result.success(getProotBinaryPath())
                }
                "getNativeLibDir" -> {
                    result.success(applicationInfo.nativeLibraryDir)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun extractProotBinary(): Boolean {
        return try {
            val prootFile = File(filesDir, "proot")
            if (prootFile.exists()) return true

            val nativeLibDir = applicationInfo.nativeLibraryDir
            val prootLib = File(nativeLibDir, "libproot.so")

            if (prootLib.exists()) {
                prootLib.copyTo(prootFile, overwrite = true)
                prootFile.setExecutable(true, false)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    private fun extractRootfs(rootfsPath: String): Boolean {
        return try {
            val rootfsDir = File(filesDir, "rootfs")
            if (rootfsDir.exists()) return true

            val rootfsFile = File(rootfsPath)
            if (!rootfsFile.exists()) return false

            rootfsDir.mkdirs()

            val process = Runtime.getRuntime().exec(
                arrayOf("tar", "-xzf", rootfsFile.absolutePath, "-C", rootfsDir.absolutePath)
            )
            process.waitFor()
            process.exitValue() == 0
        } catch (e: Exception) {
            false
        }
    }

    private fun getProotBinaryPath(): String {
        return File(filesDir, "proot").absolutePath
    }
}
