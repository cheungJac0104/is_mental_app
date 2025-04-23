import 'package:flutter/material.dart';
import 'package:is_mb_app/partical_layouts/geometric_background.dart';
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
  String? _usernameError;
  String? _passwordError;
  bool _isLoading = false;
  int _currentStep = 0;
  final PageController _pageController = PageController();

  void _validateEmail(String value) {
    final error =
        _validationService.validateEmail(value); // Your validation logic
    setState(() {
      _emailError = error; // Update the error message
    });
  }

  void _validateUsername(String value) {
    final error = _validationService.validateUsername(value);
    setState(() {
      _usernameError = error;
    });
  }

  void _validatePassword(String value) {
    final errors = _validationService.validatePassword(value);
    setState(() {
      _passwordError = errors?.join('\n');
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
        title: Text('New Mate',
            style: TwTextStyles.heading1(context).copyWith(
              fontFamily: 'Pacifico',
              color: TwColors.text(context),
              fontStyle: FontStyle.italic,
            )),
      ),
      body: Stack(
        children: [
          const GeometricBackground(
            primaryColor: Colors.yellowAccent,
            secondaryColor: Colors.grey,
          ),
          _registerScreen()
        ],
      ),
    );
  }

  Widget _registerScreen() {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPadding > 0 ? 0 : TwSizes.p4,
        left: TwSizes.p4,
        right: TwSizes.p4,
        top: TwSizes.p4,
      ),
      child: Column(
        children: [
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              controller: _pageController,
              children: [
                // Username Page
                _buildStepPage(
                  icon: Icons.person_outline,
                  title: "Create Your Profile",
                  description: "Let's start with your unique username",
                  child: TwTextField(
                    controller: _usernameController,
                    hintText: 'Enter your username',
                    onChanged: _validateUsername,
                    errorText: _usernameError,
                    prefixIcon: const Icon(Icons.person),
                    labelText: '',
                  ),
                ),

                // Email Page
                _buildStepPage(
                  icon: Icons.email_outlined,
                  title: "Secure Your Account",
                  description: "We'll keep your information safe",
                  child: TwTextField(
                    controller: _emailController,
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email),
                    onChanged: _validateEmail,
                    errorText: _emailError,
                    labelText: '',
                  ),
                ),

                // Password Page
                _buildStepPage(
                  icon: Icons.lock_outline,
                  title: "Final Touch",
                  description: "Create a strong password",
                  child: TwTextField(
                    controller: _passwordController,
                    hintText: 'Enter your password',
                    onChanged: _validatePassword,
                    errorText: _passwordError,
                    obscureText: true,
                    prefixIcon: const Icon(Icons.key),
                    labelText: '',
                  ),
                ),
              ],
            ),
          ),

          // Progress Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => _buildProgressDot(index)),
          ),

          const SizedBox(height: TwSizes.p8),

          // Navigation Buttons
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: TwButton(
                    onPressed: _previousStep,
                    variant: TwButtonVariant.outline,
                    child: const Text('Back'),
                  ),
                ),
              Expanded(
                child: TwButton(
                  onPressed: _nextStep,
                  isLoading: _isLoading,
                  child:
                      Text(_currentStep == 2 ? 'Create Account' : 'Continue'),
                ),
              ),
            ].whereType<Widget>().toList(),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: RichText(
              text: TextSpan(
                text: 'Have an account? ',
                style: Theme.of(context).textTheme.bodyMedium,
                children: const [
                  TextSpan(
                    text: 'Login',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPage(
      {required IconData icon,
      required String title,
      required String description,
      required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(TwSizes.p8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Theme.of(context).primaryColor),
          const SizedBox(height: TwSizes.p8),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: TwSizes.p2),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TwSizes.p8),
          child,
        ],
      ),
    );
  }

  Widget _buildProgressDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentStep == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentStep == index
            ? Theme.of(context).primaryColor
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _nextStep() {
    bool isFormValid = true;

    if (_currentStep == 0 &&
        (_usernameController.text.isEmpty ||
            (_usernameError ?? '').isNotEmpty)) {
      isFormValid = false;
    }
    if (_currentStep == 1 &&
        (_emailController.text.isEmpty || (_emailError ?? '').isNotEmpty)) {
      isFormValid = false;
    }
    if (_currentStep == 2 &&
        (_passwordController.text.isEmpty ||
            (_passwordError ?? '').isNotEmpty)) {
      isFormValid = false;
    }

    if (!isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors before submitting.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _register();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }
}
