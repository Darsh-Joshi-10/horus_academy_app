class ApiConstants {

  static String get baseUrl {
    return "http://192.168.1.8:8000";
  }

  // All routers are mounted under /api in main.py
  static String get _api => "$baseUrl/api";


  static String get login =>
      "$_api/auth/login";


  static String get register =>
      "$_api/auth/register";


  static String get me =>
      "$_api/auth/me";


  static String get users =>
      "$_api/users";


  static String get pendingUsers =>
      "$_api/users/pending";


  static String approveUser(String id) =>
      "$_api/users/$id/approve";


  static String rejectUser(String id) =>
      "$_api/users/$id/reject";


  static String suspendUser(String id) =>
      "$_api/users/$id/suspend";


  static String get branches =>
      "$_api/branches";


  static String branchDetail(String id) =>
      "$_api/branches/$id";

  static String get roles =>
      "$_api/roles";
}