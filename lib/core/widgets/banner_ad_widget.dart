import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../providers/ad_provider.dart';

class BannerAdWidget extends ConsumerWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adService = AdService();

    // 지원하지 않는 플랫폼에서는 빈 컨테이너 반환
    if (!adService.isAdSupportedPlatform) {
      return const SizedBox.shrink();
    }

    final bannerAdAsyncValue = ref.watch(bannerAdProvider);

    return bannerAdAsyncValue.when(
      data: (bannerAd) {
        if (bannerAd == null) {
          return const SizedBox.shrink();
        }

        return Container(
          alignment: Alignment.center,
          width: bannerAd.size.width.toDouble(),
          height: bannerAd.size.height.toDouble(),
          child: AdWidget(ad: bannerAd),
        );
      },
      loading: () => const SizedBox(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) {
        debugPrint('광고 로드 오류: $error');
        return const SizedBox.shrink();
      },
    );
  }
}
