// lib/providers/article_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bubuy/models/article.dart';
import 'package:bubuy/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArticleProvider with ChangeNotifier {
  ApiService apiService;
  List<Article> _articles = [];
  bool _isLoading = false;

  // --- STATE BARU UNTUK FITUR PENCARIAN ---
  List<Article> _filteredArticles = [];
  String _searchQuery = '';
  // -----------------------------------------

  static const String _favoriteKey = 'favorite_articles';

  List<Article> get articles =>
      _filteredArticles; // UI akan menggunakan daftar yang sudah difilter
  bool get isLoading => _isLoading;

  ArticleProvider({required this.apiService});

  List<Article> get favoriteArticles =>
      _articles.where((article) => article.isFavorite).toList();

  Future<void> toggleFavoriteStatus(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = prefs.getStringList(_favoriteKey) ?? [];

    final index = _articles.indexWhere((article) => article.id == articleId);
    if (index != -1) {
      _articles[index].isFavorite = !_articles[index].isFavorite;
      if (_articles[index].isFavorite) {
        if (!favoriteIds.contains(articleId)) {
          favoriteIds.add(articleId);
        }
      } else {
        favoriteIds.remove(articleId);
      }
      await prefs.setStringList(_favoriteKey, favoriteIds);
      // Panggil juga filter agar UI ter-update dengan benar
      searchArticles(_searchQuery);
    }
  }

  Future<void> _applyFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteIds = prefs.getStringList(_favoriteKey) ?? [];
    for (var article in _articles) {
      article.isFavorite = favoriteIds.contains(article.id);
    }
  }

  // --- FUNGSI BARU UNTUK LOGIKA PENCARIAN ---
  void searchArticles(String query) {
    _searchQuery = query;

    if (_searchQuery.isEmpty) {
      // Jika query kosong, tampilkan semua artikel
      _filteredArticles = List.from(_articles);
    } else {
      // Jika ada query, filter berdasarkan judul
      _filteredArticles = _articles
          .where((article) =>
              article.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    // Beri tahu UI untuk update
    notifyListeners();
  }
  // -----------------------------------------

  Future<void> fetchArticles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await apiService.getAuthorNews();
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseJson = jsonDecode(response.body);
        final List<dynamic> data = responseJson['body']['data'] ?? [];
        _articles = data.map((e) => Article.fromJson(e)).toList();

        // Inisialisasi daftar yang difilter saat pertama kali mengambil data
        _filteredArticles = List.from(_articles);

        await _applyFavoriteStatus();
      } else {
        Fluttertoast.showToast(msg: "Gagal memuat berita");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Terjadi kesalahan: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ... (Sisa kode (create, update, delete) tidak berubah)
  Future<bool> createArticle(Article article) async {
    try {
      final response = await apiService.createArticle(article.toJson());
      if (response.statusCode == 201 || response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Berita berhasil ditambahkan, memuat ulang...");
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
        // Hapus dari kedua list
        _articles.removeWhere((article) => article.id == articleId);
        searchArticles(_searchQuery); // Refresh daftar filter
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
