import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;

  AdService._internal();

  // 광고 지원 플랫폼인지 확인
  bool get isAdSupportedPlatform => Platform.isAndroid || Platform.isIOS;

  // 광고 초기화
  Future<void> initialize() async {
    if (!isAdSupportedPlatform) return;

    await MobileAds.instance.initialize();

    // 디버그 모드에서 테스트 모드 활성화
    if (kDebugMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: [
            'kGADSimulatorID', // iOS 시뮬레이터용
            '33BE2250B43518CCDA7DE426D04EE231', // 실제 디바이스용
          ],
        ),
      );
    }
  }

  // 배너 광고 생성
  Future<BannerAd?> createBannerAd() async {
    if (!isAdSupportedPlatform) return null;

    final adUnitId = _getBannerAdUnitId();
    debugPrint('🎯 광고 로드 시작 - AdUnit ID: $adUnitId');
    debugPrint('🔧 디버그 모드: $kDebugMode');
    debugPrint('📱 플랫폼: ${Platform.operatingSystem}');

    final completer = Completer<BannerAd?>();

    final bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('✅ 배너 광고 로딩 완료 - ID: $adUnitId');
          completer.complete(ad as BannerAd);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('❌ 배너 광고 로딩 실패');
          debugPrint('   - AdUnit ID: $adUnitId');
          debugPrint('   - Error Code: ${error.code}');
          debugPrint('   - Error Message: ${error.message}');
          debugPrint('   - Error Domain: ${error.domain}');
          ad.dispose();
          completer.complete(null);
        },
        onAdOpened: (Ad ad) {
          debugPrint('📢 광고 열림');
        },
        onAdClosed: (Ad ad) {
          debugPrint('📪 광고 닫힘');
        },
      ),
    );

    bannerAd.load();
    return completer.future;
  }

  // 플랫폼별 광고 단위 ID
  String _getBannerAdUnitId() {
    if (Platform.isAndroid) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/6300978111' // 테스트 배너 ID
          : 'ca-app-pub-4940948867704473/7365532237'; // 실제 배너 ID (Android)
    } else if (Platform.isIOS) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/2934735716' // 테스트 배너 ID
          : 'ca-app-pub-4940948867704473/7365532237'; // 실제 배너 ID (iOS)
    }
    return '';
  }
}
