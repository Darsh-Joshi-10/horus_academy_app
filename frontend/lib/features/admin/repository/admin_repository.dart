import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/models/user.dart';
import '../models/role_model.dart';


class AdminRepository {

  Future<List<Role>> getRoles() async {
    try {
      final Response response = await DioClient.dio.get(
        ApiConstants.roles,
      );

      final List<dynamic> data = response.data;

      return data
          .map((json) => Role.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _extractErrorMessage(e);
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final Response response = await DioClient.dio.get(
        ApiConstants.users,
      );

      final List<dynamic> data = response.data;

      return data
          .map(
            (json) => User.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw _extractErrorMessage(e);
    }
  }

  Future<List<User>> getPendingUsers() async {
    try {

      final Response response = await DioClient.dio.get(
        ApiConstants.pendingUsers,
      );


      final List<dynamic> data = response.data;


      return data
          .map(
            (json) => User.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();


    } on DioException catch (e) {

      throw _extractErrorMessage(e);

    }
  }



  Future<User> approveUser(
    String userId, {
    required int roleId,
    String? branchId,
  }) async {

    try {

      final data = <String, dynamic>{
        "role_id": roleId,
      };

      if (branchId != null && branchId.isNotEmpty) {
        data["branch_id"] = branchId;
      }

      final Response response = await DioClient.dio.patch(
        ApiConstants.approveUser(userId),

        data: data,
      );


      return User.fromJson(
        response.data as Map<String, dynamic>,
      );


    } on DioException catch (e) {

      throw _extractErrorMessage(e);

    }
  }



  Future<User> rejectUser(
    String userId,
  ) async {

    try {

      final Response response = await DioClient.dio.patch(
        ApiConstants.rejectUser(userId),
      );


      return User.fromJson(
        response.data as Map<String, dynamic>,
      );


    } on DioException catch (e) {

      throw _extractErrorMessage(e);

    }
  }



  Future<User> suspendUser(
    String userId,
  ) async {

    try {

      final Response response = await DioClient.dio.patch(
        ApiConstants.suspendUser(userId),
      );


      return User.fromJson(
        response.data as Map<String, dynamic>,
      );


    } on DioException catch (e) {

      throw _extractErrorMessage(e);

    }
  }



  String _extractErrorMessage(
    DioException e,
  ) {

    final data = e.response?.data;


    if (data is Map && data["detail"] != null) {

      return data["detail"].toString();

    }


    return "Action failed. Please try again.";

  }

}