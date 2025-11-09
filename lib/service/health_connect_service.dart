import 'dart:io';

import 'package:appcheck/appcheck.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HealthConnectService extends GetxService{
  final _healthConnect = Health();

  Future init() async{
    await _healthConnect.configure();
    return this;
  }
  Future steps(int negative_offset) async{
    final isHealthConnectAvailable = await AppCheck().isAppEnabled("com.google.android.apps.healthdata")
        .catchError((error, stackTrace) => false);
    debugPrint("demo-service: steps called");

    if(!isHealthConnectAvailable && Platform.isAndroid) {
      debugPrint("demo-service: no health connect app");

      const url = "https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata";
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      }
      return [];
    };

    final types = [
      HealthDataType.STEPS
    ];

    final granted = await _healthConnect.hasPermissions(types) ?? false;
    if(!granted) {
      debugPrint("demo-service: no permission!");
      final success = await Health().requestAuthorization(types, permissions: [HealthDataAccess.READ]);
      debugPrint("demo-service: failed to get permission!");
      if(!success) return [];
    };

    bool hasActivityRecognitionPermission = await Permission.activityRecognition.isGranted;
    if (!hasActivityRecognitionPermission) {
      hasActivityRecognitionPermission = (await Permission.activityRecognition.request()).isGranted;
      if (!hasActivityRecognitionPermission) return;
    }
/*
*
* val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
    Intent(HealthConnectManager.ACTION_MANAGE_HEALTH_PERMISSIONS)
        .putExtra(Intent.EXTRA_PACKAGE_NAME, BuildConfig.APPLICATION_ID)
} else {
    Intent(HealthConnectClient.ACTION_HEALTH_CONNECT_SETTINGS)
}
startActivity(intent)
* */
    debugPrint("Healthの情報が取得可能になりました！！");
    debugPrint("demo-service: already has permission!");

    //
    final oneDay = Duration(days: 1);
    final now = DateTime.now().subtract(oneDay * negative_offset);
    final data = await _healthConnect.getHealthDataFromTypes(
      types: [HealthDataType.STEPS],
      startTime: DateTime(now.year, now.month, now.day, 0, 0, 0),
      endTime: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
    return data;
  }
}
