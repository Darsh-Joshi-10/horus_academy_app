class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return "Minimum 6 characters";
    }

    return null;
  }
}