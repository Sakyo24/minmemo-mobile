import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

import '../config/constants.dart';
import '../model/admob.dart';
import '../pages/groups/index.dart';
import '../pages/todos/index.dart';
import '../pages/user/show.dart';

class BottomMenu extends StatefulWidget {
  final int currentPageIndex;

  const BottomMenu({
    Key? key,
    required this.currentPageIndex,
  }) : super(key: key);

  @override
  State<BottomMenu> createState() => _MenuState();
}

class _MenuState extends State<BottomMenu> {
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

  // 初期処理
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
            BottomNavigationBarItem(label: 'メモ', icon: Icon(Icons.list)),
            BottomNavigationBarItem(label: 'グループ', icon: Icon(Icons.groups)),
            BottomNavigationBarItem(
              label: 'マイページ',
              icon: Icon(Icons.perm_identity),
            ),
          ],
          onTap: (int value) {
            if (value == PageIndex.todo) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TodosIndexPage(),
                ),
              );
            } else if (value == PageIndex.group) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GroupsIndexPage(),
                ),
              );
            } else if (value == PageIndex.user) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserShowPage(),
                ),
              );
            }
          },
        )
      ],
    );
  }
}
