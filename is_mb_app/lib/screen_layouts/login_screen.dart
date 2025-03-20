import 'package:flutter/material.dart';
import 'package:is_mb_app/screen_layouts/tailwind.dart';
import 'package:provider/provider.dart';

import '../api_routes/api_service.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late ApiService _apiService;
  late AuthService authService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    _isLoading = true;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final response = await _apiService.login(username, password);
      if (response.statusCode == 200) {
        // Handle successful login
        var body = _apiService.responseBodyParse(response);
        final int statusCode = body['statusCode'] as int;
        final String bodyString = body['body'].toString();

        var bodyJson = _apiService.jsonBodyParse(bodyString);
        // Extract the message and token
        final String message = bodyJson['message'].toString();
        final String token = bodyJson['token'].toString();

        if (statusCode == 200 && mounted) {
          // Handle successful login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );

          // Save the token and user information

          authService.saveToken(token, 3600);
          authService.saveTokenUserInfo(token);

          // Navigate to the home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // Handle other status codes (e.g., 400, 401, 500)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          }
        }
        // Navigate to the home screen or perform other actions
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TwSizes.p4),
        child: Column(
          children: [
            TwTextField(
              controller: _usernameController,
              labelText: 'Username',
              hintText: 'Enter your username',
              prefixIcon: const Icon(Icons.person), // Add a prefix icon
              borderColor: Colors.green.shade500, // Custom border color
            ),
            const SizedBox(height: TwSizes.p4),
            TwTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Enter your password',
              obscureText: true,
              prefixIcon: const Icon(Icons.key), // Add a prefix icon
              borderColor: Colors.green.shade500, // Custom border color
            ),
            const SizedBox(height: TwSizes.p4),
            TwButton(
              onPressed: _login,
              backgroundColor: Colors.green.shade500, // Custom background color
              textColor: Colors.white, // Custom text color
              borderRadius: 12.0, // Custom border radius
              icon: const Icon(Icons.login), // Add an icon
              isLoading: false,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Login'), // Set to true to show a loading indicator
            ),
            const SizedBox(height: TwSizes.p4),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}
