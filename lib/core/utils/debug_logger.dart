import 'package:flutter/foundation.dart';

/// 개발 모드에서만 로그를 출력하는 유틸리티 클래스
class DebugLogger {
  /// 개발 모드에서만 로그를 출력
  static void log(String message) {
    if (kDebugMode) {
      // print(message);
    }
  }

  /// 에러 로그 (릴리즈 모드에서도 출력)
  static void error(String message) {
    // print('❌ ERROR: $message');
  }

  /// 경고 로그 (개발 모드에서만 출력)
  static void warning(String message) {
    if (kDebugMode) {
      // print('⚠️ WARNING: $message');
    }
  }

  /// 정보 로그 (개발 모드에서만 출력)
  static void info(String message) {
    if (kDebugMode) {
      // print('ℹ️ INFO: $message');
    }
  }

  /// 성공 로그 (개발 모드에서만 출력)
  static void success(String message) {
    if (kDebugMode) {
      // print('✅ SUCCESS: $message');
    }
  }
}
