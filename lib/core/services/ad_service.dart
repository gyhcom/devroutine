import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();

  factory AdService() => _instance;

  AdService._internal();

  Future<void> initialize() async {
    await MobileAds.instance.initialize();

    // 테스트 모드 설정
    if (kDebugMode) {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: ['kGADSimulatorID'],
        ),
      );
    }
  }

  // 배너 광고 로드
  Future<BannerAd?> loadBannerAd() async {
    final String adUnitId = _getBannerAdUnitId();

    final BannerAd bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('Banner ad loaded: ${ad.adUnitId}');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Banner ad failed to load: ${error.message}');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => debugPrint('Banner ad opened'),
        onAdClosed: (Ad ad) => debugPrint('Banner ad closed'),
      ),
    );

    try {
      await bannerAd.load();
      return bannerAd;
    } catch (e) {
      debugPrint('Error loading banner ad: $e');
      return null;
    }
  }

  // 플랫폼별 테스트 광고 ID 반환
  String _getBannerAdUnitId() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ca-app-pub-3940256099942544/6300978111'; // 안드로이드 테스트 ID
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 ID
    } else {
      throw UnsupportedError('지원하지 않는 플랫폼입니다');
    }
  }
}
