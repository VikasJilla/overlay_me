import 'package:flutter/material.dart';
import 'package:overlay_me/extensions/context_extension.dart';
import 'package:overlay_me/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/photo_editing_screen.dart';
import 'services/permission_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OverlayMeApp());
}

class OverlayMeApp extends StatefulWidget {
  const OverlayMeApp({super.key});

  @override
  State<OverlayMeApp> createState() => _OverlayMeAppState();
}

class _OverlayMeAppState extends State<OverlayMeApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('languageCode');

    if (savedLanguageCode != null) {
      // Use saved user preference
      setState(() {
        _locale = Locale(savedLanguageCode);
      });
    } else {
      // Use device locale if supported, otherwise default to English
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final supportedLanguageCodes = AppLocalizations.supportedLocales.map((locale) => locale.languageCode).toList();
      print('deviceLocale: $deviceLocale');
      print('supportedLanguageCodes: $supportedLanguageCodes');
      if (supportedLanguageCodes.contains(deviceLocale.languageCode)) {
        setState(() {
          _locale = deviceLocale;
        });
      } else {
        setState(() {
          _locale = const Locale('en'); // Default to English
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overlay Me',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.blue, foregroundColor: Colors.white, elevation: 0),
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/photo-editing': (context) => const PhotoEditingScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Proactively request photo permission early
    await PermissionService.requestPhotoPermission(context);

    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;

    if (hasCompletedOnboarding) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              context.translations.splash.overlay_me,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              context.translations.splash.create_amazing_photo_overlays,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          ],
        ),
      ),
    );
  }
}
