import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdMob {
  static Map<String, Map<String, String>> adIds = {
    'ios': {
      'banner': dotenv.get('IOS_BANNER_ID'),
      'interstitial': dotenv.get('IOS_INTERSTITIAL_ID')
    },
    'android': {
      'banner': dotenv.get('ANDROID_BANNER_ID'),
      'interstitial': dotenv.get('ANDROID_INTERSTITIAL_ID')
    }
  };

  static String getAdId({required String deviceType, required String adType}) {
    return adIds[deviceType]![adType].toString();
  }
}
