import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:auto_route/auto_route.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/onboarding_provider.dart';
import '../../core/theme/typography.dart';
import '../../core/routing/app_router.dart';

@RoutePage()
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IntroductionScreen(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              next: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.blue,
              ),

              // 건너뛰기 버튼 설정
              showSkipButton: true,
              skip: const Text(
                '건너뛰기',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onSkip: () => _completeOnboarding(context, ref),

              // 페이지 표시 설정
              showBottomPart: true,
              dotsDecorator: const DotsDecorator(
                size: Size(10.0, 10.0),
                color: Colors.grey,
                activeColor: Colors.blue,
                activeSize: Size(22.0, 10.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),

              // 배경 색상
              globalBackgroundColor: Colors.white,

              // 애니메이션 설정
              curve: Curves.easeInOut,
              controlsMargin: const EdgeInsets.all(16),
              dotsContainerDecorator: const ShapeDecoration(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
          ),
          _buildBottomSheet(context),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '앱 사용 시 개인정보처리방침에 동의하게 됩니다.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _launchPrivacyPolicy(),
              child: Text(
                '개인정보처리방침 보기',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
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
      image: Icon(
        image,
        size: 120,
        color: color,
      ),
      decoration: PageDecoration(
        titleTextStyle: AppTypography.headlineLarge.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
        bodyTextStyle: AppTypography.bodyLarge.copyWith(
          color: Colors.grey.shade700,
          height: 1.5,
        ),
        imagePadding: const EdgeInsets.only(top: 80),
        contentMargin: const EdgeInsets.symmetric(horizontal: 16),
        titlePadding: const EdgeInsets.only(top: 40, bottom: 16),
      ),
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    final url = Uri.parse('https://gyhcom.github.io/devroutine/');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('개인정보처리방침 링크 열기 실패: $e');
    }
  }

  void _completeOnboarding(BuildContext context, WidgetRef ref) {
    ref.read(onboardingProvider.notifier).completeOnboarding();
    context.router.navigate(const DashboardRoute());
  }
}
