import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/user.dart';

class AuthRepository {
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final Response response = await DioClient.dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      return LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final detail = _extractErrorMessage(e);
      throw AuthException(detail);
    }
  }

  Future<User> register(RegisterRequest request) async {
    try {
      final Response response = await DioClient.dio.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      return User.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final detail = _extractErrorMessage(e);
      throw AuthException(detail);
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final Response response = await DioClient.dio.get(
        ApiConstants.me,
      );

      return User.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final detail = _extractErrorMessage(e);
      throw AuthException(detail);
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map && data["detail"] != null) {
      final detail = data["detail"];

      if (detail is String) {
        return detail;
      }

      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;

        if (first is Map && first["msg"] != null) {
          return first["msg"].toString();
        }
      }
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return "Connection timed out. Is the backend running?";
    }

    if (e.type == DioExceptionType.connectionError) {
      return "Unable to reach the server. Check your network connection.";
    }

    return "Unable to sign in right now.";
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
