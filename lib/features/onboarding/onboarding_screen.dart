import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:auto_route/auto_route.dart';
import '../../core/providers/onboarding_provider.dart';
import '../../core/theme/typography.dart';
import '../../core/routing/app_router.dart';

@RoutePage()
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IntroductionScreen(
      // 페이지 설정
      pages: [
        _buildPage(
          title: "3일만 해보세요!",
          body: "작은 습관도 3일만 지속하면\n큰 변화의 시작이 됩니다",
          image: Icons.calendar_today_rounded,
          color: Colors.blue.shade600,
        ),
        _buildPage(
          title: "오늘 할 일 확인",
          body: "매일 간단한 체크로\n성취감을 느껴보세요",
          image: Icons.check_circle_outline_rounded,
          color: Colors.green.shade600,
        ),
        _buildPage(
          title: "지금 시작하기",
          body: "첫 번째 루틴을 만들고\n새로운 습관을 시작해보세요",
          image: Icons.rocket_launch_rounded,
          color: Colors.purple.shade600,
        ),
      ],

      // 완료 버튼 설정
      onDone: () => _completeOnboarding(context, ref),
      showDoneButton: true,
      done: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          '시작하기',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 다음 버튼 설정
      showNextButton: true,
      next: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.blue.shade600,
          size: 20,
        ),
      ),

      // 건너뛰기 버튼 설정
      showSkipButton: true,
      skip: Text(
        '건너뛰기',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
      onSkip: () => _completeOnboarding(context, ref),

      // 인디케이터 설정
      dotsDecorator: DotsDecorator(
        size: const Size(10, 10),
        activeSize: const Size(20, 10),
        activeColor: Colors.blue.shade600,
        color: Colors.grey.shade300,
        spacing: const EdgeInsets.symmetric(horizontal: 4),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),

      // 전체 설정
      globalBackgroundColor: Colors.white,
      animationDuration: 300,
      curve: Curves.easeInOut,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.all(12),
      dotsContainerDecorator: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  PageViewModel _buildPage({
    required String title,
    required String body,
    required IconData image,
    required Color color,
  }) {
    return PageViewModel(
      title: title,
      body: body,
      image: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Icon(
          image,
          size: 80,
          color: color,
        ),
      ),
      decoration: PageDecoration(
        titleTextStyle: AppTypography.headlineLarge.copyWith(
          color: Colors.grey.shade800,
        ),
        bodyTextStyle: AppTypography.bodyLarge.copyWith(
          color: Colors.grey.shade600,
          height: 1.5,
        ),
        imagePadding: const EdgeInsets.only(top: 40, bottom: 40),
        pageMargin: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }

  Future<void> _completeOnboarding(BuildContext context, WidgetRef ref) async {
    // 온보딩 완료 상태 저장
    await ref.read(onboardingProvider.notifier).completeOnboarding();

    // 대시보드로 이동
    if (context.mounted) {
      context.router.navigate(const DashboardRoute());
    }
  }
}
