import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/service/account_service.dart';
import 'package:town_pass/service/device_service.dart';
import 'package:town_pass/service/geo_locator_service.dart';
import 'package:town_pass/service/health_connect_service.dart';
import 'package:town_pass/service/nfc_service.dart';
import 'package:town_pass/service/notification_service.dart';
import 'package:town_pass/service/package_service.dart';
import 'package:town_pass/service/shared_preferences_service.dart';
import 'package:town_pass/service/subscription_service.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';

const _transparentStatusBar = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
);

// Foreground Taskのハンドラー
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  int _count = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {

    debugPrint('位置情報サービス開始: $timestamp');
    debugPrint('起動方法: ${starter.name}');
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    _count++;

    try {
      // 位置情報を取得
      const LocationSettings(
        accuracy: LocationAccuracy.high
      );

      Position position = await Geolocator.getCurrentPosition();

      debugPrint('==== 位置情報 #$_count ====');
      debugPrint('緯度: ${position.latitude}');
      debugPrint('経度: ${position.longitude}');
      debugPrint('精度: ${position.accuracy}m');
      debugPrint('高度: ${position.altitude}m');
      debugPrint('速度: ${position.speed}m/s');
      debugPrint('時刻: ${DateTime.now()}');
      debugPrint('========================');
      await Supabase.initialize(
        url: 'https://uurrzheotsnisszuitee.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV1cnJ6aGVvdHNuaXNzenVpdGVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1ODg5NzQsImV4cCI6MjA3ODE2NDk3NH0.-6IT4TbBE4DORBA1WU9--D2BTPJyf77BaTJkwGhgJ14',
      );
      final client = Supabase.instance.client;
      final String jsonString = await rootBundle.loadString('assets/mock_data/account.json');
      final data = jsonDecode(jsonString);

      await client.from('user_location').upsert({"id": data['data']['id'], "latitude": position.latitude, "longitude": position.longitude });

      // 通知を更新
      FlutterForegroundTask.updateService(
        notificationTitle: '取得地理位置中',
        notificationText: '緯度: ${position.latitude.toStringAsFixed(6)}, '
            '経度: ${position.longitude.toStringAsFixed(6)}',
      );

      // UIに送信
      FlutterForegroundTask.sendDataToMain({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': DateTime.now().toIso8601String(),
        'count': _count,
      });

    } catch (e) {
      debugPrint('位置情報取得エラー: $e');
      FlutterForegroundTask.updateService(
        notificationTitle: '位置情報取得中',
        notificationText: 'エラー: $e',
      );
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    debugPrint('位置情報サービス終了: $timestamp');
    debugPrint('タイムアウト: $isTimeout');
  }

  @override
  void onNotificationButtonPressed(String id) {
    debugPrint('通知ボタンが押されました: $id');
  }

  @override
  void onNotificationPressed() {
    debugPrint('通知が押されました');
    FlutterForegroundTask.launchApp('/');
  }

  @override
  void onNotificationDismissed() {
    debugPrint('通知が閉じられました');
  }

  @override
  void onReceiveData(Object data) {
    debugPrint('TaskHandlerがデータを受信: $data');
  }
}

void main() async {


  WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(
  //   widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  // );

  await initServices();


  SystemChrome.setSystemUIOverlayStyle(_transparentStatusBar);
  FlutterForegroundTask.initCommunicationPort();
  FlutterForegroundTask.startService(notificationTitle: "Demo Foreground Serivee", notificationText: "TESTSTETSET");
  runApp(const MyApp());
}

Future<void> initServices() async {
  await Get.putAsync<AccountService>(() async => await AccountService().init());
  await Get.putAsync<DeviceService>(() async => await DeviceService().init());
  await Get.putAsync<PackageService>(() async => await PackageService().init());
  await Get.putAsync<SharedPreferencesService>(() async => await SharedPreferencesService().init());
  await Get.putAsync<GeoLocatorService>(() async => await GeoLocatorService().init());
  await Get.putAsync<NotificationService>(() async => await NotificationService().init());
  await Get.putAsync<HealthConnectService>(() async => await HealthConnectService().init());
  await Get.putAsync<NfcService>(() async => await NfcService().init());

  Get.put<SubscriptionService>(SubscriptionService());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Town Pass',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: TPColors.grayscale50,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: TPColors.white,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: TPColors.primary500),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0.0,
          iconTheme: IconThemeData(size: 56),
          actionsIconTheme: IconThemeData(size: 56),
        ),
        actionIconTheme: ActionIconThemeData(
          backButtonIconBuilder: (_) => Semantics(
            excludeSemantics: true,
            child: Assets.svg.iconArrowLeft.svg(width: 24, height: 24),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: TPRoute.main,
      onInit: () {
        GeoLocatorService.requestPermission();
        NotificationService.requestPermission();
      },
      getPages: TPRoute.page,
    );
  }
}