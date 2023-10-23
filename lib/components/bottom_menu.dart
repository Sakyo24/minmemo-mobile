import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

import '../model/admob.dart';

class BottomMenu extends StatefulWidget {
  final int currentPageIndex;
  final Function(int) callback;

  const BottomMenu({
    Key? key,
    required this.currentPageIndex,
    required this.callback,
  }) : super(key: key);

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  // バナー広告
  late BannerAd bannerAd;
  bool isAdLoaded = false;
  void initAd() {
    bannerAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? AdMob.getAdId(deviceType: 'android', adType: 'banner')
          : AdMob.getAdId(deviceType: 'ios', adType: 'banner'),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(onAdLoaded: (Ad ad) {
        setState(() {
          isAdLoaded = true;
        });
      }),
    )..load();
  }

  void sendCurrentPageIndex(int data) {
    widget.callback(data);
  }

  @override
  void initState() {
    super.initState();
    initAd();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: isAdLoaded ? bannerAd.size.width.toDouble() : 0,
          height: isAdLoaded ? bannerAd.size.height.toDouble() : 0,
          child: isAdLoaded ? AdWidget(ad: bannerAd) : Container(),
        ),
        BottomNavigationBar(
          currentIndex: widget.currentPageIndex,
          items: const [
            BottomNavigationBarItem(
              label: 'メモ',
              icon: Icon(Icons.list),
            ),
            BottomNavigationBarItem(
              label: 'グループ',
              icon: Icon(Icons.groups),
            ),
            BottomNavigationBarItem(
              label: 'マイページ',
              icon: Icon(Icons.perm_identity),
            ),
          ],
          onTap: (int value) {
            sendCurrentPageIndex(value);
          },
        )
      ],
    );
  }
}
