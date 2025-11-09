import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // 権限チェック
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      await Geolocator.requestPermission();
    }

    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        Position pos = await Geolocator.getCurrentPosition();
        debugPrint('📍 Location: ${pos.latitude}, ${pos.longitude}');
      } catch (e) {
        debugPrint('❌ Location error: $e');
      }
    });

    return;
  }

  // ← ここが重要
  @override
  Future<void> onDestroy(DateTime timestamp, bool isStopped) async {
    _timer?.cancel();
    debugPrint('🛑 Foreground Task destroyed. isStopped=$isStopped');
    return;
  }

  @override
  void onReceiveData(Object? data) {
    debugPrint("📩 Received data from main isolate: $data");
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // TODO: implement onRepeatEvent
  }
}
