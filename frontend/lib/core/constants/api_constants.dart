class ApiConstants {
  static String get baseUrl {
    return "http://192.168.1.8:8000";
  }

  static String get login => "$baseUrl/api/auth/login";

  static String get register => "$baseUrl/api/auth/register";

  static String get me => "$baseUrl/api/auth/me";

  static String get pendingUsers => "$baseUrl/api/users/pending";

  static String approveUser(String id) => "$baseUrl/api/users/$id/approve";

  static String rejectUser(String id) => "$baseUrl/api/users/$id/reject";

  static String suspendUser(String id) => "$baseUrl/api/users/$id/suspend";

  static String get branches => "$baseUrl/api/branches";

  static String branchDetail(String id) => "$baseUrl/api/branches/$id";
}
