import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/models/user.dart';

class AdminRepository {
  Future<List<User>> getPendingUsers() async {
    try {
      final Response response = await DioClient.dio.get(
        ApiConstants.pendingUsers,
      );

      final List list = response.data as List;
      return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _extractErrorMessage(e);
    }
  }

  Future<User> approveUser(String userId, {int? roleId}) async {
    try {
      final Response response = await DioClient.dio.patch(
        ApiConstants.approveUser(userId),
        data: roleId != null ? {'role_id': roleId} : null,
      );
      return User.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _extractErrorMessage(e);
    }
  }

  Future<User> rejectUser(String userId) async {
    try {
      final Response response = await DioClient.dio.patch(
        ApiConstants.rejectUser(userId),
      );
      return User.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _extractErrorMessage(e);
    }
  }

  Future<User> suspendUser(String userId) async {
    try {
      final Response response = await DioClient.dio.patch(
        ApiConstants.suspendUser(userId),
      );
      return User.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _extractErrorMessage(e);
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data["detail"] != null) {
      return data["detail"].toString();
    }
    return "Action failed. Please try again.";
  }
}
