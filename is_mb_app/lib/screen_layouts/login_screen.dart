import 'package:flutter/material.dart';
import 'package:is_mb_app/screen_layouts/tailwind.dart';
import 'package:provider/provider.dart';

import '../api_routes/api_service.dart';
import '../partical_layouts/bounce_animation.dart';
import '../partical_layouts/geometric_background.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';

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
  late NavigationService navigationService;
  bool _isLoading = false;

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isHoveringRegister = false;
  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    navigationService = Provider.of<NavigationService>(context, listen: false);
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
    setState(() {
      _isLoading = true; // Start loading
    });

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
          navigationService.navigateTo('/', tabIndex: 0);
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
      setState(() {
        _isLoading = false; // Start loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _mainCanvas();
  }

  Widget _mainCanvas() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welix',
            style: TwTextStyles.heading1(context).copyWith(
              fontFamily: 'Pacifico',
              color: TwColors.text(context),
              fontStyle: FontStyle.italic,
            )),
      ),
      body: Stack(
        children: [
          const GeometricBackground(
            primaryColor: Color.fromRGBO(200, 160, 72, 1),
          ),
          _loginScreen()
        ],
      ),
    );
  }

  Widget _loginScreen() {
    return Padding(
      padding: const EdgeInsets.all(TwSizes.p4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Smile Icon with Bounce Animation
          const AnimatedBounce(
            child: Icon(
              Icons.emoji_emotions_outlined,
              size: 60,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: TwSizes.p8),

          // Username Field
          TwTextField(
            controller: _usernameController,
            labelText: 'Username',
            hintText: 'Enter your username',
            prefixIcon: const Icon(Icons.person, color: Colors.green),
            borderColor: Colors.green.shade500,
          ),
          const SizedBox(height: TwSizes.p4),

          // Password Field
          TwTextField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: 'Enter your password',
            obscureText: _obscurePassword,
            prefixIcon: const Icon(Icons.key, color: Colors.green),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.green.shade600,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            borderColor: Colors.green.shade500,
          ),
          const SizedBox(height: TwSizes.p4),

          // Remember Me Checkbox
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) =>
                    setState(() => _rememberMe = value ?? false),
                fillColor: WidgetStateProperty.resolveWith<Color>(
                  (states) => states.contains(WidgetState.selected)
                      ? Colors.green.shade500
                      : Colors.grey.shade300,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text('Remember me',
                  style: TextStyle(color: Colors.grey.shade700)),
              const Spacer(),
            ],
          ),
          const SizedBox(height: TwSizes.p4),

          // Login Button
          TwButton(
            onPressed: _login,
            backgroundColor: Colors.green.shade500,
            borderRadius: 6,
            padding: const EdgeInsets.symmetric(vertical: 16),
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.login, color: Colors.white),
            child: const SizedBox(),
          ),
          const SizedBox(height: TwSizes.p6),

          // Enhanced Register Button
          MouseRegion(
            onEnter: (_) => setState(() => _isHoveringRegister = true),
            onExit: (_) => setState(() => _isHoveringRegister = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isHoveringRegister
                      ? Colors.green.shade400
                      : Colors.green.shade300,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
                color: _isHoveringRegister
                    ? Colors.green.shade50
                    : Colors.transparent,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              child: InkWell(
                onTap: () =>
                    navigationService.navigateTo('/register', isStack: true),
                borderRadius: BorderRadius.circular(8),
                splashColor: Colors.green.shade100,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.translationValues(
                          _isHoveringRegister ? 4 : 0, 0, 0),
                      child: Text(
                        'Register ? ',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _isHoveringRegister ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
