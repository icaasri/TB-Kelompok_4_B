// lib/providers/auth_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:bubuy/services/api_service.dart';

// HANYA ADA AuthProvider DI FILE INI

class AuthProvider with ChangeNotifier {
  final ApiService apiService;
  String? _token;
  bool _isLoading = true;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  final String _appEmail = "news@itg.ac.id";
  final String _appPassword = "ITG#news";

  AuthProvider({required this.apiService}) {
    authenticateApp();
  }

  Future<void> authenticateApp() async {
    _isLoading = true;
    notifyListeners();

    debugPrint("🚀 [AUTH] Memulai autentikasi aplikasi...");

    try {
      final response = await apiService.authenticate(_appEmail, _appPassword);

      debugPrint("📦 [AUTH] Response Status: ${response.statusCode}");
      debugPrint("📦 [AUTH] Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['body']['success'] == true) {
          _token = data['body']['data']['token'];
          apiService.setToken(_token);
          _isAuthenticated = true;
          debugPrint(
              "✅ [AUTH] Aplikasi berhasil diautentikasi. Token diterima.");
        } else {
          _isAuthenticated = false;
          debugPrint(
              "❌ [AUTH] Gagal mengautentikasi aplikasi: ${data['body']['message']}");
        }
      } else {
        _isAuthenticated = false;
        debugPrint(
            "❌ [AUTH] Gagal melakukan request autentikasi. Status: ${response.statusCode}");
      }
    } catch (e) {
      _isAuthenticated = false;
      debugPrint("🔥 [AUTH] Terjadi error saat autentikasi: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
