import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:j_phone/core/const/app_images.dart';
import 'package:j_phone/core/router/app_router.dart';

import 'core/const/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
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
              ?child,
            ],
          ),
        );
      },
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
    );
  }
}
