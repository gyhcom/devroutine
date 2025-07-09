import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:auto_route/auto_route.dart';
import '../../core/providers/onboarding_provider.dart';
import '../../core/theme/typography.dart';
import '../../core/routing/app_router.dart';

@RoutePage()
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() {
    if (kDebugMode) {
      print('🏗️ [SPLASH] SplashScreen 생성자 호출됨');
    }
    return _SplashScreenState();
  }
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      print('🎬 [SPLASH] SplashScreen initState 시작');
    }

    // 온보딩 프로바이더 강제 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        print('🔄 [SPLASH] 온보딩 프로바이더 강제 초기화');
      }
      ref.read(onboardingProvider.notifier);
    });

    // 애니메이션 컨트롤러 설정
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 페이드 인 애니메이션
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // 스케일 애니메이션
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    // 애니메이션 시작
    _animationController.forward();

    // 2초 후 다음 화면으로 이동
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    if (kDebugMode) {
      print('🚀 [SPLASH] 네비게이션 시작');
    }

    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) {
      if (kDebugMode) {
        print('❌ [SPLASH] 위젯이 마운트되지 않음 - 네비게이션 중단');
      }
      return;
    }

    if (kDebugMode) {
      print('⏳ [SPLASH] 온보딩 상태 로딩 대기 중...');
    }

    // 온보딩 완료 상태 확인 (충분한 시간을 두고 확인)
    await Future.delayed(const Duration(milliseconds: 500));

    final isOnboardingCompleted = ref.read(onboardingProvider);

    if (kDebugMode) {
      print('📊 [SPLASH] 온보딩 완료 상태: $isOnboardingCompleted');
    }

    if (isOnboardingCompleted) {
      if (kDebugMode) {
        print('✅ [SPLASH] 온보딩 완료됨 → 대시보드로 이동');
      }
      // 온보딩 완료된 사용자 → 바로 대시보드로
      context.router.navigate(const DashboardRoute());
    } else {
      if (kDebugMode) {
        print('🎯 [SPLASH] 첫 사용자 → 온보딩 화면으로 이동');
      }
      // 첫 사용자 → 온보딩 화면으로
      context.router.navigate(const OnboardingRoute());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🏗️ [SPLASH] SplashScreen build 메서드 호출됨');
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 앱 로고
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade600.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.developer_mode_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 앱 제목
                    Text(
                      'DevRoutine',
                      style: AppTypography.safeGoogleFont(
                        fontFamily: 'Source Code Pro',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 부제목
                    Text(
                      '개발자를 위한 루틴 관리',
                      style: AppTypography.safeGoogleFont(
                        fontFamily: 'Source Code Pro',
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // 로딩 인디케이터
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
