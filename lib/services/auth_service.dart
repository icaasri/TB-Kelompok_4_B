// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bubuy/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService with ChangeNotifier {
  final String baseUrl = "http://45.149.187.204:3000";
  User? _user;
  String? _token;
  final _storage = const FlutterSecureStorage();

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  // Database simulasi untuk registrasi
  final Map<String, Map<String, String>> _simulatedUsersDb = {};
  final String _dbStorageKey = 'simulatedUsersDatabase';

  AuthService() {
    _loadSimulatedUsers();
  }

  Future<void> _loadSimulatedUsers() async {
    final dbJsonString = await _storage.read(key: _dbStorageKey);
    if (dbJsonString != null) {
      final Map<String, dynamic> decodedDb = json.decode(dbJsonString);
      decodedDb.forEach((key, value) {
        _simulatedUsersDb[key] = Map<String, String>.from(value);
      });
    }
  }

  Future<void> _saveSimulatedUsers() async {
    final dbJsonString = json.encode(_simulatedUsersDb);
    await _storage.write(key: _dbStorageKey, value: dbJsonString);
  }

  Future<void> register(String name, String email, String password) async {
    if (_simulatedUsersDb.containsKey(email)) {
      throw Exception('Email sudah terdaftar dalam simulasi.');
    }
    _simulatedUsersDb[email] = {'password': password, 'name': name};
    await _saveSimulatedUsers();
  }

  Future<void> login(String email, String password) async {
    // Cek database simulasi
    if (_simulatedUsersDb.containsKey(email)) {
      final simulatedUser = _simulatedUsersDb[email]!;
      if (simulatedUser['password'] == password) {
        _token =
            'jwt-token-palsu-simulasi-${DateTime.now().millisecondsSinceEpoch}';
        _user = User(username: simulatedUser['name']!, email: email);
        await _storage.write(key: 'authToken', value: _token);
        notifyListeners();
        return;
      }
    }

    // Jika tidak ada, coba API
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['body']['success'] == true) {
        final data = responseData['body']['data'];
        final authorData = data['author'];
        _token = data['token'] as String?;
        if (_token != null && _token!.isNotEmpty) {
          _user = User(
            username: "${authorData['firstName']} ${authorData['lastName']}",
            email: authorData['email'],
          );
          await _storage.write(key: 'authToken', value: _token);
          notifyListeners();
        } else {
          throw Exception('Token dari server kosong.');
        }
      } else {
        throw Exception(
            responseData['body']['message'] ?? 'Kredensial tidak valid');
      }
    } else {
      throw Exception('Gagal login: ${response.body}');
    }
  }

  Future<void> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'authToken');
    if (storedToken != null && storedToken.isNotEmpty) {
      _token = storedToken;
      _user = User(username: 'Pengguna', email: 'email@tersimpan.com');
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    await _storage.deleteAll();
    _simulatedUsersDb.clear();
    notifyListeners();
  }
}
