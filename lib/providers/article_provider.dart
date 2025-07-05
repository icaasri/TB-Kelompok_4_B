// lib/providers/article_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bubuy/models/article.dart';
import 'package:bubuy/services/api_service.dart';

class ArticleProvider with ChangeNotifier {
  ApiService apiService;
  List<Article> _articles = [];
  bool _isLoading = false;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;

  ArticleProvider({required this.apiService});

  List<Article> get favoriteArticles =>
      _articles.where((a) => a.isFavorite).toList();

  void toggleFavorite(String articleId) {
    final index = _articles.indexWhere((article) => article.id == articleId);
    if (index != -1) {
      _articles[index].isFavorite = !_articles[index].isFavorite;
      notifyListeners();
    }
  }

  // --- PERBAIKAN: Mengganti nama dan sumber data ---
  Future<void> fetchArticles() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Memanggil endpoint yang benar
      final response = await apiService.getAuthorNews();
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);
        final List<dynamic> data = responseJson['body']['data'] ?? [];
        _articles = data.map((e) => Article.fromJson(e)).toList();
      } else {
        Fluttertoast.showToast(msg: "Gagal memuat berita");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Terjadi kesalahan: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createArticle(Article article) async {
    try {
      final response = await apiService.createArticle(article.toJson());
      if (response.statusCode == 201 || response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Berita berhasil ditambahkan, memuat ulang...");
        // Panggil fetchArticles untuk memuat ulang dari endpoint yang benar
        await fetchArticles();
        return true;
      } else {
        final error = jsonDecode(response.body);
        Fluttertoast.showToast(
            msg:
                "Gagal: ${error['body']?['message'] ?? 'Error tidak diketahui'}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
      return false;
    }
  }

  Future<bool> updateArticle(Article article) async {
    if (article.id == null) return false;
    try {
      final response =
          await apiService.updateArticle(article.id!, article.toJson());
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Berita berhasil diperbarui, memuat ulang...");
        await fetchArticles();
        return true;
      } else {
        final error = jsonDecode(response.body);
        Fluttertoast.showToast(
            msg:
                "Gagal update: ${error['body']?['message'] ?? 'Error tidak diketahui'}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
      return false;
    }
  }

  Future<bool> deleteArticle(String articleId) async {
    try {
      final response = await apiService.deleteArticle(articleId);
      if (response.statusCode == 200 || response.statusCode == 204) {
        Fluttertoast.showToast(msg: "Berita berhasil dihapus");
        _articles.removeWhere((article) => article.id == articleId);
        notifyListeners();
        return true;
      } else {
        final error = jsonDecode(response.body);
        Fluttertoast.showToast(
            msg:
                "Gagal hapus: ${error['body']?['message'] ?? 'Error tidak diketahui'}");
        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
      return false;
    }
  }
}
