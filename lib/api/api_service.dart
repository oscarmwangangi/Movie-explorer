import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// This is the ONLY file in the app that talks to our backend server.
/// Keeping every network call here (instead of scattered across
/// screens) makes it much easier to find and fix things later.
class ApiService {
  // Use dotenv for the base URL. Fallback to local for development.
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:4000';

  /// Saves the login token to the phone's local storage so the user
  /// stays logged in even after closing the app.
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// Builds the headers every authenticated request needs.
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ---------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------

  /// Returns null on success, or an error message string on failure.
  /// This pattern (return the error instead of throwing) keeps the
  /// UI code simple: `final error = await ApiService.login(...); if (error != null) ...`
  static Future<String?> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      return data['error'] ?? 'Registration failed.';
    }

    await _saveToken(data['token']);
    return null; // no error = success
  }

  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return data['error'] ?? 'Login failed.';
    }

    await _saveToken(data['token']);
    return null;
  }

  static Future<String?> changePassword(String currentPassword, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/change-password'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return data['error'] ?? 'Password change failed.';
    }

    return null;
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/me'),
      headers: await _authHeaders(),
    );

    debugPrint("Profile Response (${response.statusCode}): ${response.body}");

    if (response.statusCode != 200) {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Failed to load profile');
      } catch (e) {
        throw Exception('Failed to load profile (${response.statusCode})');
      }
    }

    return jsonDecode(response.body);
  }

  static Future<String?> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      return data['error'] ?? 'Failed to request reset.';
    }

    return null;
  }

  // ---------------------------------------------------------------
  // Subscriptions
  // ---------------------------------------------------------------

  /// Asks the backend to start a PayPal subscription.
  /// Returns the PayPal approval URL to open in a browser, or throws
  /// an Exception with a friendly message on failure.
  static Future<String> startSubscription(String planType) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/subscriptions/start'),
      headers: await _authHeaders(),
      body: jsonEncode({'planType': planType}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Could not start checkout.');
    }

    return data['approveUrl'];
  }

  /// Checks the current user's subscription status.
  /// Returns a map like: { status: 'active', planType: 'monthly', expiresAt: '...' }
  static Future<Map<String, dynamic>> getMySubscription() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/subscriptions/me'),
      headers: await _authHeaders(),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Failed to check subscription');
    }

    return data;
  }
}
