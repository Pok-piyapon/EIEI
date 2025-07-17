import 'package:flutter_line_sdk/flutter_line_sdk.dart';

class LineAuthService {
  

  // Login with LINE
  static Future<LoginResult?> login() async {
    try {
      final result = await LineSDK.instance.login(
        scopes: ['profile', 'openid', 'email'],
      );
      print("Login Success: ${result.userProfile?.displayName}");
      return result;
    } catch (e) {
      print("Login Failed: $e");
      return null;
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      await LineSDK.instance.logout();
      print("Logout successful");
    } catch (e) {
      print("Logout failed: $e");
    }
  }

  // Get current access token
  static Future<String?> getAccessToken() async {
    try {
      final token = await LineSDK.instance.currentAccessToken;
      return token?.value;
    } catch (e) {
      print("Error getting access token: $e");
      return null;
    }
  }

  // Get user profile
  static Future<UserProfile?> getUserProfile() async {
    try {
      final result = await LineSDK.instance.getProfile();
      return result;
    } catch (e) {
      print("Error getting user profile: $e");
      return null;
    }
  }
}
