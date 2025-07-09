import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// 온보딩 완료 상태를 관리하는 프로바이더
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false) {
    if (kDebugMode) {
      print('🔄 [ONBOARDING] OnboardingNotifier 초기화 시작');
    }
    _loadOnboardingStatus();
  }

  static const String _onboardingKey = 'onboarding_completed';

  // 온보딩 완료 상태 로드
  Future<void> _loadOnboardingStatus() async {
    if (kDebugMode) {
      print('📱 [ONBOARDING] SharedPreferences에서 온보딩 상태 로드 시작');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedState = prefs.getBool(_onboardingKey) ?? false;

      if (kDebugMode) {
        print('💾 [ONBOARDING] 저장된 상태: $savedState');
      }

      state = savedState;

      if (kDebugMode) {
        print('✅ [ONBOARDING] 상태 로드 완료 - 현재 상태: $state');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ONBOARDING] 상태 로드 실패: $e');
      }
      state = false;
    }
  }

  // 온보딩 완료 처리
  Future<void> completeOnboarding() async {
    if (kDebugMode) {
      print('🎉 [ONBOARDING] 온보딩 완료 처리 시작');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
      state = true;

      if (kDebugMode) {
        print('✅ [ONBOARDING] 온보딩 완료 상태 저장 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ONBOARDING] 온보딩 완료 저장 실패: $e');
      }
      // 에러 발생 시에도 상태는 변경 (앱 사용 가능하도록)
      state = true;
    }
  }

  // 온보딩 상태 리셋 (테스트용)
  Future<void> resetOnboarding() async {
    if (kDebugMode) {
      print('🔄 [ONBOARDING] 온보딩 상태 리셋 시작');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, false);
      state = false;

      if (kDebugMode) {
        print('✅ [ONBOARDING] 온보딩 상태 리셋 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ONBOARDING] 온보딩 상태 리셋 실패: $e');
      }
      state = false;
    }
  }
}
