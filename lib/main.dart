import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './pages/top.dart';
import './utils/app_colors.dart';

Future main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'みんメモ',
      theme: ThemeData(
        primarySwatch: primarySwatchColor,
        primaryColor: AppColors.primaryColor,
        canvasColor: AppColors.whiteColor,
      ),
      home: const TopPage(),
    );
  }
}
