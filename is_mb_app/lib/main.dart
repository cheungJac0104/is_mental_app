import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_routes/api_service.dart';
import 'screen_layouts/theme_provider.dart';

import 'screen_layouts/home_screen.dart';
import 'screen_layouts/login_screen.dart';
import 'screen_layouts/register_screen.dart';
import 'screen_layouts/tailwind.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final prefs = await SharedPreferences.getInstance();

  // Create instances of providers
  final themeProvider = ThemeProvider();
  final authService = AuthService(prefs);
  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        Provider<AuthService>.value(value: authService),
        Provider<ApiService>.value(value: apiService),
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
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
