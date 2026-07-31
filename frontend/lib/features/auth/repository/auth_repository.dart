import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/storage_service.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/user.dart';



class AuthRepository {


  Future<LoginResponse> login(
    LoginRequest request,
  ) async {

    try {

      final Response response =
          await DioClient.dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );


      final data =
          response.data as Map<String, dynamic>;


      final loginResponse =
          LoginResponse.fromJson(
            data,
          );


      // Save JWT token
      await StorageService.saveToken(
        loginResponse.accessToken,
      );


      // Debug check
      final savedToken =
          await StorageService.getToken();

      print(
        "SAVED TOKEN: $savedToken",
      );


      return loginResponse;


    } on DioException catch (e) {

      throw AuthException(
        _extractErrorMessage(e),
      );

    }

  }




  Future<User> register(
    RegisterRequest request,
  ) async {

    try {

      final Response response =
          await DioClient.dio.post(
        ApiConstants.register,
        data: request.toJson(),
      );


      return User.fromJson(
        response.data as Map<String, dynamic>,
      );


    } on DioException catch (e) {

      throw AuthException(
        _extractErrorMessage(e),
      );

    }

  }




  Future<User> getCurrentUser() async {

    try {

      final Response response =
          await DioClient.dio.get(
        ApiConstants.me,
      );


      final user =
          User.fromJson(
            response.data as Map<String, dynamic>,
          );


      await StorageService.saveUser(
        user,
      );


      return user;


    } on DioException catch (e) {

      throw AuthException(
        _extractErrorMessage(e),
      );

    }

  }




  String _extractErrorMessage(
    DioException e,
  ) {


    final responseData =
        e.response?.data;


    if (responseData is Map &&
        responseData["detail"] != null) {


      final detail =
          responseData["detail"];


      if (detail is String) {
        return detail;
      }


      if (detail is List &&
          detail.isNotEmpty) {


        final first =
            detail.first;


        if (first is Map &&
            first["msg"] != null) {

          return first["msg"].toString();

        }

      }

    }



    if (e.type ==
        DioExceptionType.connectionTimeout) {

      return "Connection timeout.";

    }



    if (e.type ==
        DioExceptionType.connectionError) {

      return "Cannot connect to server.";

    }



    return "Something went wrong.";

  }

}





class AuthException implements Exception {

  final String message;


  AuthException(
    this.message,
  );


  @override
  String toString() {

    return message;

  }

}