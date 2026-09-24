import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/plan_detail_screen.dart';
import 'screens/splash_screen.dart';
import 'services/billing_service.dart';
import 'services/plan_service.dart';
import 'services/reminder_service.dart';
import 'theme/app_theme.dart';
import 'widgets/reminder_banner.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('az', null);
  await initializeDateFormatting('en', null);
  await ReminderService.instance.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const CedvelApp());
}

class CedvelApp extends StatefulWidget {
  const CedvelApp({super.key});

  @override
  State<CedvelApp> createState() => _CedvelAppState();
}

class _CedvelAppState extends State<CedvelApp> {
  static const _splashDuration = Duration(milliseconds: 2500);
  final _plans = PlanService();
  late final BillingService _billing = BillingService(_plans);
  Timer? _splashTimer;
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    _plans.load().then((_) {
      if (!mounted) return;
      _billing.init();
    });
    _splashTimer = Timer(_splashDuration, () {
      if (mounted) setState(() => _splashDone = true);
      _bindReminders();
    });
  }

  void _bindReminders() {
    ReminderService.instance.bindNavigator((id) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => PlanDetailScreen(planId: id)),
      );
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _billing.dispose();
    _plans.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _plans),
        ChangeNotifierProvider.value(value: _billing),
        ChangeNotifierProvider<ReminderService>.value(
          value: ReminderService.instance,
        ),
      ],
      child: Consumer<PlanService>(
        builder: (context, service, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Cədvəl',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: service.themeMode,
            locale: Locale(service.locale == 'en' ? 'en' : 'az'),
            supportedLocales: const [Locale('az'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => ReminderBannerHost(
              child: child ?? const SizedBox.shrink(),
            ),
            home: !_splashDone
                ? const SplashScreen()
                : !service.isLoaded
                    ? const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6C5CE7),
                          ),
                        ),
                      )
                    : !service.onboardingDone
                        ? const OnboardingScreen()
                        : const MainShell(),
          );
        },
      ),
    );
  }
}
