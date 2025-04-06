class ValidationService {
  final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  final RegExp _numberRegex = RegExp(r'[0-9]');
  final RegExp _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  List<String>? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return ['Please enter a password'];
    }

    List<String> errors = [];

    if (value.length < 8) {
      errors.add('Must be at least 8 characters');
    }

    if (!_uppercaseRegex.hasMatch(value)) {
      errors.add('At least one uppercase letter (A-Z)');
    }

    if (!_lowercaseRegex.hasMatch(value)) {
      errors.add('At least one lowercase letter (a-z)');
    }

    if (!_numberRegex.hasMatch(value)) {
      errors.add('At least one number (0-9)');
    }

    if (!_specialCharRegex.hasMatch(value)) {
      errors.add('At least one special character');
    }

    return errors.isEmpty ? null : errors;
  }

  // Username validation example
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }

    if (value.length < 4) {
      return 'Username must be at least 4 characters';
    }

    if (value.length > 20) {
      return 'Username cannot exceed 20 characters';
    }

    return null;
  }

  // Add other validation methods here (e.g., password, username)
}
