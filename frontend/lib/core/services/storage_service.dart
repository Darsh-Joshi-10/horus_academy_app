import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/models/user.dart';

class StorageService {
  StorageService._();

  static const _storage = FlutterSecureStorage();

  static const _tokenKey = "token";
  static const _userKey = "user";

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> saveUser(User user) async {
    await _storage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  static Future<User?> getUser() async {
    final raw = await _storage.read(key: _userKey);

    if (raw == null) {
      return null;
    }

    return User.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }
}
