import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';

final bannerAdProvider = FutureProvider<BannerAd?>((ref) async {
  final adService = AdService();
  await adService.initialize();
  return adService.loadBannerAd();
});
