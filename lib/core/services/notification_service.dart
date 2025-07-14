import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 시간대 초기화
    tz.initializeTimeZones();

    // Android 설정
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 권한 요청 (iOS)
    if (Platform.isIOS) {
      await _requestIOSPermissions();
    }

    _isInitialized = true;
    debugPrint('✅ 푸시 알림 서비스 초기화 완료');
  }

  /// iOS 권한 요청
  Future<void> _requestIOSPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 알림 탭됨: ${response.payload}');
    // TODO: 라우팅 처리
  }

  /// 즉시 알림 (테스트용)
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      '즉시 알림',
      channelDescription: '테스트용 즉시 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );

    debugPrint('🔔 즉시 알림 전송: $title');
  }

  /// 지연 알림 (테스트용)
  Future<void> scheduleTestNotification({
    required Duration delay,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      '테스트 알림',
      channelDescription: '개발용 테스트 알림',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      scheduledDate,
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('⏰ ${delay.inSeconds}초 후 알림 예약: $title');
  }

  /// 루틴 리마인더 알림
  Future<void> scheduleRoutineReminder({
    required String routineId,
    required String routineTitle,
    required DateTime scheduledTime,
  }) async {
    if (!_isInitialized) await initialize();

    final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'routine_reminder',
      '루틴 리마인더',
      channelDescription: '루틴 완료 리마인더',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      routineId.hashCode,
      '🎯 루틴 시간이에요!',
      '$routineTitle를 완료할 시간입니다',
      scheduledDate,
      details,
      payload: 'routine:$routineId',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
    );

    debugPrint('🎯 루틴 리마인더 설정: $routineTitle at ${scheduledTime.toString()}');
  }

  /// 3일 챌린지 격려 알림
  Future<void> scheduleThreeDayChallenge({
    required String routineTitle,
    required int dayNumber,
  }) async {
    if (!_isInitialized) await initialize();

    // 내일 오전 9시에 격려 메시지
    final tomorrow = DateTime.now().add(Duration(days: 1));
    final scheduledDate = tz.TZDateTime(
      tz.local,
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      9, // 오전 9시
    );

    const androidDetails = AndroidNotificationDetails(
      'three_day_challenge',
      '3일 챌린지',
      channelDescription: '3일 챌린지 격려 메시지',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    String title = '';
    String body = '';

    switch (dayNumber) {
      case 1:
        title = '🌟 3일 챌린지 시작!';
        body = '$routineTitle의 첫 번째 날입니다. 화이팅!';
        break;
      case 2:
        title = '🔥 3일 챌린지 2일차!';
        body = '$routineTitle 어제 잘했어요! 오늘도 화이팅!';
        break;
      case 3:
        title = '🏆 3일 챌린지 마지막 날!';
        body = '$routineTitle 오늘만 완료하면 성공이에요!';
        break;
    }

    await _notifications.zonedSchedule(
      'three_day_$routineTitle$dayNumber'.hashCode,
      title,
      body,
      scheduledDate,
      details,
      payload: 'challenge:$routineTitle:$dayNumber',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('🌟 3일 챌린지 $dayNumber일차 알림 설정: $routineTitle');
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('🗑️ 모든 알림 취소됨');
  }

  /// 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('🗑️ 알림 취소됨 (ID: $id)');
  }
}
