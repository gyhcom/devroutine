import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;

  AdService._internal();

  bool _isInitialized = false;
  int _retryAttempt = 0;
  static const int _maxRetryAttempt = 3;

  BannerAd? _cachedBannerAd;

  /// 플랫폼이 광고를 지원하는지 확인
  bool get isAdSupportedPlatform {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    // macOS, Windows, Linux에서는 광고 초기화 건너뛰기
    if (!isAdSupportedPlatform) {
      if (kDebugMode) {
        debugPrint('ℹ️ 현재 플랫폼(${Platform.operatingSystem})은 광고를 지원하지 않습니다.');
      }
      _isInitialized = true;
      return;
    }

    try {
      await MobileAds.instance.initialize();

      if (kDebugMode) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: ['kGADSimulatorID']),
        );
      }

      _isInitialized = true;
      debugPrint('✅ AdMob 초기화 완료');
    } catch (e) {
      debugPrint('❌ AdMob 초기화 실패: $e');
    }
  }

  /// 배너 광고 로드 (재사용 지원)
  Future<BannerAd?> loadBannerAd() async {
    // 지원하지 않는 플랫폼에서는 null 반환
    if (!isAdSupportedPlatform) {
      if (kDebugMode) {
        debugPrint('ℹ️ 현재 플랫폼에서는 광고를 지원하지 않습니다.');
      }
      return null;
    }

    if (_cachedBannerAd != null) return _cachedBannerAd;

    if (!_isInitialized) await initialize();

    _retryAttempt = 0;
    final ad = await _loadBannerAdWithRetry();
    _cachedBannerAd = ad;
    return ad;
  }

  /// 광고 로딩 재시도 로직
  Future<BannerAd?> _loadBannerAdWithRetry() async {
    if (_retryAttempt >= _maxRetryAttempt) {
      if (kDebugMode) {
        debugPrint('❌ 광고 로드 최대 재시도 초과 ($_maxRetryAttempt회)');
      }
      return null;
    }

    final completer = Completer<BannerAd?>();
    final adUnitId = _getBannerAdUnitId();

    final BannerAd bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize
          .banner, // 또는 AdSize.smartBanner, AnchoredAdaptiveBannerAdSize 사용 가능
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (kDebugMode) {
            debugPrint('✅ 광고 로드 성공: ${ad.adUnitId}');
          }
          completer.complete(ad as BannerAd);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) async {
          ad.dispose();
          if (kDebugMode) {
            debugPrint('⚠️ 광고 로드 실패 ($_retryAttempt): ${error.message}');
          }

          _retryAttempt++;
          // 재시도 간격을 늘림 (1초 → 5초)
          Future.delayed(const Duration(seconds: 5), () async {
            final retryAd = await _loadBannerAdWithRetry();
            completer.complete(retryAd);
          });
        },
        onAdOpened: (ad) {
          if (kDebugMode) debugPrint('📢 광고 클릭됨');
        },
        onAdClosed: (ad) {
          if (kDebugMode) debugPrint('📪 광고 닫힘');
        },
      ),
    );

    try {
      await bannerAd.load();
      return completer.isCompleted ? await completer.future : bannerAd;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ 광고 로딩 중 예외: $e');
      completer.complete(null);
      return null;
    }
  }

  /// 배너 광고 단위 ID
  String _getBannerAdUnitId() {
    // 루틴 등록 화면 배너 광고 단위 ID (실제 광고)
    return 'ca-app-pub-4940948867704473/7365532237';
  }

  /// 광고 해제 (위젯 dispose 시 호출)
  void disposeBannerAd() {
    _cachedBannerAd?.dispose();
    _cachedBannerAd = null;
    if (kDebugMode) debugPrint('🗑️ 광고 리소스 해제 완료');
  }
}
