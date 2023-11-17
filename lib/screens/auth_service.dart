import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl; // Replace with your backend API base URL

  AuthService(this.baseUrl);

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Authentication successful
      return true;
    } else {
      // Authentication failed
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: jsonEncode({'username': username, 'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      // Registration successful
      return true;
    } else {
      // Registration failed
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      body: jsonEncode({'email': email}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Password reset email sent successfully
      return true;
    } else {
      // Password reset failed
      return false;
    }
  }

  Future<bool> confirmPasswordReset(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password/$token'),
      body: jsonEncode({'newPassword': newPassword}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Password reset successful
      return true;
    } else {
      // Password reset failed
      return false;
    }
  }
}
