import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api_routes/api_service.dart';
import '../services/validation_service.dart';
import 'tailwind.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late ApiService _apiService;
  final _validationService = ValidationService();
  String? _emailError;
  bool _isFormValid = true;
  bool _isLoading = false;

  void _validateEmail(String value) {
    final error =
        _validationService.validateEmail(value); // Your validation logic
    setState(() {
      _emailError = error; // Update the error message
      _isFormValid = error == null;
    });
  }

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final response = await _apiService.register(
          username: username, email: email, password: password);
      if (response.statusCode == 200 && mounted) {
        // Handle successful registration
        var body = _apiService.responseBodyParse(response);
        final int statusCode = body['statusCode'] as int;
        final String bodyString = body['body'].toString();

        var bodyJson = _apiService.jsonBodyParse(bodyString);
        // Extract the message and token
        final String message = bodyJson['message'].toString();

        if (statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to the login screen or perform other actions
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TwSizes.p4),
        child: Column(
          children: [
            TwTextField(
              controller: _usernameController,
              labelText: 'Username',
              hintText: 'Enter your username',
              prefixIcon: const Icon(Icons.person),
            ),
            const SizedBox(height: TwSizes.p4),
            TwTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email),
              onChanged: _validateEmail, // Callback for text changes
              errorText: _emailError, // Pass the error message
            ),
            const SizedBox(height: TwSizes.p4),
            TwTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Enter your password',
              obscureText: true,
              prefixIcon: const Icon(Icons.key),
            ),
            const SizedBox(height: TwSizes.p4),
            TwButton(
              onPressed: !_isFormValid
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please fix the errors before submitting.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  : () async {
                      await _register();
                    },
              isLoading: _isLoading,
              child: const Text('Register'),
            ),
            const SizedBox(height: TwSizes.p4),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
