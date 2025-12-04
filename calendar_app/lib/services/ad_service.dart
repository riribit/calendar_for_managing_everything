import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService instance = AdService._();
  AdService._();

  // 広告ユニットID（プラットフォーム別）
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9566939033123179/2609977737';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9566939033123179/4798809763';
    }
    throw UnsupportedError('Unsupported platform');
  }

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}
