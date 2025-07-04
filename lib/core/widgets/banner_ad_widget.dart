import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../providers/ad_provider.dart';

class BannerAdWidget extends ConsumerWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adState = ref.watch(bannerAdProvider);

    return adState.when(
      data: (ad) {
        if (ad == null) {
          return const SizedBox.shrink();
        }

        return Container(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          alignment: Alignment.center,
          child: AdWidget(ad: ad),
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
