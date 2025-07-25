import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:crytoapp/providers/graph_provider.dart';
import 'package:crytoapp/models/LocalStorage.dart';
import 'package:crytoapp/pages/Login.dart';
import 'package:crytoapp/providers/market_provider.dart';
import 'package:crytoapp/providers/theme_provider.dart';
import 'package:crytoapp/utils/register_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:async'; // Needed for runZonedGuarded

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  String currentTheme = await LocalStorage.getTheme() ?? "light";

  // ✅ Catch Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🔥 Flutter framework error: ${details.exception}');
  };

  runApp(MyApp(theme: currentTheme));

  // Email registration disabled - use the app's registration page instead
  // await registerUserEmail('test@cryptotracker.com', 'TestPassword123!', 'Test User');
}

// Function to register your email in Firebase
Future<void> registerUserEmail(String email, String password, String name) async {
  try {
    print('🔥 Registering email: $email');
    bool success = await UserRegistration.registerUser(
      email: email,
      password: password,
      firstName: name,
    );

    if (success) {
      print('✅ SUCCESS! Email registered: $email');
    } else {
      print('❌ FAILED to register email: $email');
    }
  } catch (e) {
    print('❌ Error registering email: $e');
  }
}

class MyApp extends StatelessWidget {
  final String theme;
  const MyApp({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MarketProvider>(
          create: (context) => MarketProvider(),
        ),
        ChangeNotifierProvider<GraphProvider>(
          create: (context) => GraphProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(theme),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff1890ff),
              Color(0xff0050b3),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Modern Logo Container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.currency_bitcoin,
                size: 50,
                color: Color(0xff1890ff),
              ),
            ),
            const SizedBox(height: 40),
            // App Title
            const Text(
              'CRYPTO TRACKER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle
            const Text(
              'Professional Trading Platform',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 60),
            // Loading indicator
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xff1890ff),
      nextScreen: const LoginScreen(),
      splashIconSize: double.infinity,
      duration: 2500,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      animationDuration: const Duration(milliseconds: 800),
    );
  }
}
