package com.ccswitch.minimax

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 设置MethodChannel
        val channel = flutterEngine.dartExecutor.binaryMessenger
        // 这里可以添加原生方法通道
    }
}
