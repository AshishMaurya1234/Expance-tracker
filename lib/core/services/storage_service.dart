import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String userTokenKey = "USER_TOKEN";

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(userTokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(userTokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(userTokenKey);
  }
}