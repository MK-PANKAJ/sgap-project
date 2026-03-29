import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/network/api_interceptor.dart' show navigatorKey;
import 'screens/splash/splash_screen.dart';
import 'screens/auth/language_screen.dart';
import 'screens/auth/phone_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/dashboard/worker_dashboard.dart';
import 'screens/income/voice_logger_screen.dart';
import 'screens/income/income_ledger_screen.dart';
import 'screens/credit/credit_profile_screen.dart';
import 'screens/loans/loan_home_screen.dart';
import 'screens/loans/loan_offers_screen.dart';
import 'screens/loans/loan_success_screen.dart';
import 'screens/employer/employer_dashboard.dart';
import 'screens/schemes/schemes_screen.dart';
import 'screens/schemes/insurance_screen.dart';
import 'screens/help/help_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/roadmap_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global navigator key — used by [ApiInterceptor] to redirect on 401.
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait for mobile-first experience
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Translucent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialise network layer
  ApiClient.instance.init();

  // Share the navigator key with the interceptor for 401 redirects
  navigatorKey = _navigatorKey;

  runApp(const ProviderScope(child: SgapApp()));
}

class SgapApp extends StatelessWidget {
  const SgapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S-GAP',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/language': (context) => const LanguageScreen(),
        '/phone': (context) => const PhoneScreen(),
        '/otp': (context) {
          final phone =
              ModalRoute.of(context)?.settings.arguments as String? ?? '';
          return OtpScreen(phoneNumber: phone);
        },
        '/registration': (context) => const RegistrationScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/dashboard': (context) => const WorkerDashboard(),
        '/voice-logger': (context) => const VoiceLoggerScreen(),
        '/income-ledger': (context) => const IncomeLedgerScreen(),
        '/credit-profile': (context) => const CreditProfileScreen(),
        '/loan-home': (context) => const LoanHomeScreen(),
        '/loan-offers': (context) => const LoanOffersScreen(),
        '/loan-success': (context) => const LoanSuccessScreen(),
        '/employer': (context) => const EmployerDashboard(),
        '/schemes': (context) => const SchemesScreen(),
        '/insurance': (context) => const InsuranceScreen(),
        '/help': (context) => const HelpScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/roadmap': (context) => const RoadmapScreen(),
      },
    );
  }
}
