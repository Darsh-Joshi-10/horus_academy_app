import 'user.dart';

class LoginResponse {
  final String accessToken;
  final String tokenType;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json["access_token"] as String,
      tokenType: json["token_type"] as String,
      user: User.fromJson(json["user"] as Map<String, dynamic>),
    );
  }
}
