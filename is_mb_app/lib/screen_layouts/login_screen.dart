import 'package:flutter/material.dart';
import 'package:is_mb_app/screen_layouts/tailwind.dart';

import '../api_routes/api_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final response = await _apiService.login(username, password);
      if (response.statusCode == 200) {
        // Handle successful login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful')),
        );
        // Navigate to the home screen or perform other actions
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(TwSizes.p4),
        child: Column(
          children: [
            TwTextField(
              controller: _usernameController,
              labelText: 'Username',
              hintText: 'Enter your username',
              prefixIcon: Icon(Icons.person), // Add a prefix icon
              borderColor: Colors.green.shade500, // Custom border color
            ),
            SizedBox(height: TwSizes.p4),
            TwTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Enter your password',
              obscureText: true,
              prefixIcon: Icon(Icons.key), // Add a prefix icon
              borderColor: Colors.green.shade500, // Custom border color
            ),
            SizedBox(height: TwSizes.p4),
            TwButton(
              onPressed: _login,
              child: Text('Login'),
              backgroundColor: Colors.green.shade500, // Custom background color
              textColor: Colors.white, // Custom text color
              borderRadius: 12.0, // Custom border radius
              icon: Icon(Icons.login), // Add an icon
              isLoading: false, // Set to true to show a loading indicator
            ),
            SizedBox(height: TwSizes.p4),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}
