// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = "http://45.149.187.204:3000";
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<http.Response> authenticate(String email, String password) {
    final url = '$_baseUrl/api/auth/login';
    final body = jsonEncode({'email': email, 'password': password});
    return http.post(Uri.parse(url), headers: _headers, body: body);
  }

  // --- PERBAIKAN: Buat fungsi baru untuk mengambil berita dari endpoint yang benar ---
  Future<http.Response> getAuthorNews() {
    final url =
        '$_baseUrl/api/author/news'; // Menggunakan endpoint milik penulis
    return http.get(Uri.parse(url), headers: _headers);
  }

  Future<http.Response> createArticle(Map<String, dynamic> data) {
    final url = '$_baseUrl/api/author/news';
    final body = jsonEncode(data);
    return http.post(Uri.parse(url), headers: _headers, body: body);
  }

  Future<http.Response> updateArticle(String id, Map<String, dynamic> data) {
    final url = '$_baseUrl/api/author/news/$id';
    final body = jsonEncode(data);
    return http.put(Uri.parse(url), headers: _headers, body: body);
  }

  Future<http.Response> deleteArticle(String id) {
    final url = '$_baseUrl/api/author/news/$id';
    return http.delete(Uri.parse(url), headers: _headers);
  }
}
