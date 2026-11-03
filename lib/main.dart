import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:j_phone/core/di/service_locator.dart';
import 'package:j_phone/core/router/app_router.dart';
import 'package:j_phone/modules/planner/presentation/bloc/planner_bloc.dart';

import 'core/const/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider<PlannerBloc>(create: (_) => sl<PlannerBloc>())],
      child: const MyApp(),
    ),
  );
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
          child: child ?? const SizedBox.shrink(),
        );
      },
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
    );
  }
}
