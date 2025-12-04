import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._();
  AdService._();

  // 広告ユニットID（プラットフォーム別）
  static String? get bannerAdUnitId {
    try {
      if (Platform.isAndroid) {
        return 'ca-app-pub-9566939033123179/2609977737';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-9566939033123179/4798809763';
      }
    } catch (e) {
      debugPrint('プラットフォーム判定エラー: $e');
    }
    return null;
  }

  bool _isInitialized = false;
  bool _initializationFailed = false;

  bool get isAvailable => _isInitialized && !_initializationFailed;

  Future<void> initialize() async {
    if (_isInitialized || _initializationFailed) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('AdMob初期化エラー: $e');
      _initializationFailed = true;
    }
  }

  BannerAd? createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    final adUnitId = bannerAdUnitId;
    if (adUnitId == null || !isAvailable) {
      return null;
    }

    try {
      return BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: onAdLoaded,
          onAdFailedToLoad: onAdFailedToLoad,
        ),
      );
    } catch (e) {
      debugPrint('BannerAd作成エラー: $e');
      return null;
    }
  }
}
