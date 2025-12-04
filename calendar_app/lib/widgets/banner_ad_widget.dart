import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    try {
      final ad = AdService.instance.createBannerAd(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isAdLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('バナー広告の読み込みに失敗: ${error.message}');
        },
      );

      if (ad != null) {
        _bannerAd = ad;
        _bannerAd?.load();
      }
    } catch (e) {
      debugPrint('バナー広告の初期化に失敗: $e');
    }
  }

  @override
  void dispose() {
    try {
      _bannerAd?.dispose();
    } catch (e) {
      debugPrint('バナー広告の破棄に失敗: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 広告が読み込まれていない場合は何も表示しない
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    try {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    } catch (e) {
      debugPrint('バナー広告の表示に失敗: $e');
      return const SizedBox.shrink();
    }
  }
}
