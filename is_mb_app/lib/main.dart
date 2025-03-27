import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:is_mb_app/screen_layouts/master_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_routes/api_service.dart';
import 'screen_layouts/theme_provider.dart';

import 'screen_layouts/login_screen.dart';
import 'screen_layouts/register_screen.dart';
import 'screen_layouts/tailwind.dart';
import 'services/auth_service.dart';
import 'services/mood_service.dart';
import 'services/navigation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final prefs = await SharedPreferences.getInstance();

  // Create instances of providers
  final themeProvider = ThemeProvider();
  final authService = AuthService(prefs);
  final apiService = ApiService();
  final navigationService = NavigationService();
  final moodService = MoodService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        Provider<AuthService>.value(value: authService),
        Provider<ApiService>.value(value: apiService),
        Provider<NavigationService>.value(value: navigationService),
        Provider<MoodService>.value(value: moodService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final navigationService = Provider.of<NavigationService>(context);

    ThemeData buildLightTheme() {
      return ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: TwColors.background(context),
      );
    }

    ThemeData buildDarkTheme() {
      return ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade900,
      );
    }

    return MaterialApp(
      title: 'Daily Wellness',
      theme: themeProvider.isDarkMode ? buildDarkTheme() : buildLightTheme(),
      navigatorKey: navigationService.navigatorKey,
      initialRoute: '/',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/': (context) => const MainWrapper(),
      },
    );
  }
}
