/// Password Validation Utility
/// Provides comprehensive password validation with detailed feedback
class PasswordValidator {
  
  /// Validate password strength with detailed requirements
  static Map<String, dynamic> validatePassword(String password) {
    Map<String, bool> requirements = {
      'minLength': password.length >= 8,
      'hasUppercase': password.contains(RegExp(r'[A-Z]')),
      'hasLowercase': password.contains(RegExp(r'[a-z]')),
      'hasNumber': password.contains(RegExp(r'[0-9]')),
      'hasSpecialChar': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    };
    
    bool isValid = requirements.values.every((requirement) => requirement);
    
    List<String> missingRequirements = [];
    if (!requirements['minLength']!) {
      missingRequirements.add('At least 8 characters');
    }
    if (!requirements['hasUppercase']!) {
      missingRequirements.add('At least 1 uppercase letter (A-Z)');
    }
    if (!requirements['hasLowercase']!) {
      missingRequirements.add('At least 1 lowercase letter (a-z)');
    }
    if (!requirements['hasNumber']!) {
      missingRequirements.add('At least 1 number (0-9)');
    }
    if (!requirements['hasSpecialChar']!) {
      missingRequirements.add('At least 1 special character (!@#\$%^&*(),.?":{}|<>)');
    }
    
    return {
      'isValid': isValid,
      'requirements': requirements,
      'missingRequirements': missingRequirements,
      'strength': _calculatePasswordStrength(requirements),
      'strengthText': _getStrengthText(requirements),
    };
  }
  
  /// Calculate password strength score (0-5)
  static int _calculatePasswordStrength(Map<String, bool> requirements) {
    return requirements.values.where((req) => req).length;
  }
  
  /// Get password strength text description
  static String _getStrengthText(Map<String, bool> requirements) {
    int strength = _calculatePasswordStrength(requirements);
    
    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Good';
      case 5:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }
  
  /// Get password strength color
  static String getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'red';
      case 2:
        return 'orange';
      case 3:
        return 'yellow';
      case 4:
        return 'lightgreen';
      case 5:
        return 'green';
      default:
        return 'grey';
    }
  }
  
  /// Simple password validation for login (just check if not empty)
  static String? validateLoginPassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    return null;
  }
  
  /// Comprehensive password validation for registration
  static String? validateRegistrationPassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    Map<String, dynamic> validation = validatePassword(password);
    
    if (!validation['isValid']) {
      List<String> missing = validation['missingRequirements'];
      return 'Password must have:\n• ${missing.join('\n• ')}';
    }
    
    return null;
  }
  
  /// Validate password confirmation
  static String? validatePasswordConfirmation(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Get password requirements list for UI display
  static List<Map<String, dynamic>> getPasswordRequirements(String password) {
    Map<String, dynamic> validation = validatePassword(password);
    Map<String, bool> requirements = validation['requirements'];
    
    return [
      {
        'text': 'At least 8 characters',
        'met': requirements['minLength'],
        'icon': requirements['minLength']! ? '✓' : '✗',
      },
      {
        'text': 'At least 1 uppercase letter (A-Z)',
        'met': requirements['hasUppercase'],
        'icon': requirements['hasUppercase']! ? '✓' : '✗',
      },
      {
        'text': 'At least 1 lowercase letter (a-z)',
        'met': requirements['hasLowercase'],
        'icon': requirements['hasLowercase']! ? '✓' : '✗',
      },
      {
        'text': 'At least 1 number (0-9)',
        'met': requirements['hasNumber'],
        'icon': requirements['hasNumber']! ? '✓' : '✗',
      },
      {
        'text': 'At least 1 special character (!@#\$%^&*)',
        'met': requirements['hasSpecialChar'],
        'icon': requirements['hasSpecialChar']! ? '✓' : '✗',
      },
    ];
  }
  
  /// Generate a sample strong password for testing
  static String generateSamplePassword() {
    return 'CryptoApp123!';
  }
  
  /// Check if password meets minimum requirements for the app
  static bool meetsMinimumRequirements(String password) {
    Map<String, dynamic> validation = validatePassword(password);
    return validation['isValid'];
  }
}
