import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';

final bannerAdProvider = FutureProvider<BannerAd?>((ref) async {
  final adService = AdService();

  // 플랫폼이 광고를 지원하지 않으면 null 반환
  if (!adService.isAdSupportedPlatform) {
    return null;
  }

  await adService.initialize();
  return adService.loadBannerAd();
});
