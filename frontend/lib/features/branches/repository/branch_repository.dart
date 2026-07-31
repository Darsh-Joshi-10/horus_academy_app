import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/branch_model.dart';

class BranchRepository {
  Future<List<Branch>> getBranches({bool activeOnly = false}) async {
    try {
      final Response response = await DioClient.dio.get(
        ApiConstants.branches,
        queryParameters: activeOnly ? {'is_active': true} : null,
      );

      final List list = response.data as List;
      return list.map((e) => Branch.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _extractErrorMessage(e);
    }
  }

  Future<Branch> createBranch(Map<String, dynamic> data) async {
    try {
      final Response response = await DioClient.dio.post(
        ApiConstants.branches,
        data: data,
      );
      return Branch.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _extractErrorMessage(e);
    }
  }

  Future<Branch> updateBranch(String branchId, Map<String, dynamic> data) async {
    try {
      final Response response = await DioClient.dio.put(
        ApiConstants.branchDetail(branchId),
        data: data,
      );
      return Branch.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _extractErrorMessage(e);
    }
  }

  Future<void> deleteBranch(String branchId) async {
    try {
      await DioClient.dio.delete(
        ApiConstants.branchDetail(branchId),
      );
    } on DioException catch (e) {
      throw _extractErrorMessage(e);
    }
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data["detail"] != null) {
      return data["detail"].toString();
    }
    return "Branch operation failed.";
  }
}
