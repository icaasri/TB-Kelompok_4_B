// lib/services/article_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bubuy/models/article.dart';
import 'auth_service.dart'; // Menggunakan impor relatif yang sudah benar.

class ArticleService with ChangeNotifier {
  final String baseUrl = "http://45.149.187.204:3000";
  final AuthService? authService;

  ArticleService({required this.authService});

  List<Article> _articles = [];
  List<Article> get articles => _articles;

  List<Article> get favoriteArticles =>
      _articles.where((a) => a.isFavorite).toList();

  void toggleFavorite(String articleId) {
    final index = _articles.indexWhere((article) => article.id == articleId);
    if (index != -1) {
      _articles[index].isFavorite = !_articles[index].isFavorite;
      notifyListeners();
    }
  }

  void removeFavorite(String articleId) {
    final index = _articles.indexWhere((article) => article.id == articleId);
    if (index != -1) {
      _articles[index].isFavorite = false;
      notifyListeners();
    }
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, String> get _headers {
    final token = authService?.token;
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> getPublicArticles() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/news'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        _articles = data.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load articles. Status: ${response.statusCode}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAuthorArticles() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/author/news'),
          headers: _headers);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        _articles = data.map((json) => Article.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load author articles. Status: ${response.statusCode}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createArticle(Map<String, dynamic> articleData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/author/news'),
      headers: _headers,
      body: jsonEncode(articleData),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to create article. Status: ${response.statusCode}, Body: ${response.body}');
    }

    await getAuthorArticles();
  }

  Future<void> updateArticle(
      String id, Map<String, dynamic> articleData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/author/news/$id'),
      headers: _headers,
      body: jsonEncode(articleData),
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to update article. Status: ${response.statusCode}, Body: ${response.body}');
    }
    await getAuthorArticles();
  }

  Future<void> deleteArticle(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/author/news/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to delete article. Status: ${response.statusCode}');
    }
    _articles.removeWhere((article) => article.id == id);
    notifyListeners();
  }
}
