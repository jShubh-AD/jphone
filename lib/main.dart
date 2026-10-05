import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:j_phone/core/const/app_images.dart';
import 'package:j_phone/modules/home/presentation/pages/homepage.dart';

import 'core/const/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,

            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            systemStatusBarContrastEnforced: false,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(AppImages.appBg, fit: BoxFit.cover),
              ),
              child!,
            ],
          ),
        );
      },
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const Homepage(),
    );
  }
}
