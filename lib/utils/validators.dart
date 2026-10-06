class Validators {
  static String? required(
    String? value,
    String label,
  ) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final pattern =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    return pattern.hasMatch(value.trim())
        ? null
        : 'Enter a valid email address.';
  }

  static String? yearLevel(String? value) {
    final year = int.tryParse(value ?? '');

    if (year == null || year < 1 || year > 4) {
      return 'Year level must be 1 to 4.';
    }

    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }

    return RegExp(r'^09\d{9}$').hasMatch(
      value.trim(),
    )
        ? null
        : 'Enter an 11-digit Philippine mobile number.';
  }
}