// lib/views/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bubuy/providers/article_provider.dart';
import 'package:bubuy/models/article.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi warna agar konsisten dengan halaman utama
    final Color primaryBlue = const Color(0xFF005AAB);
    final Color lightBg = const Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: lightBg, // Samakan warna latar belakang
      // --- PERUBAHAN TAMPILAN APPBAR ---
      appBar: AppBar(
        elevation: 1,
        backgroundColor: primaryBlue,
        title: const Text(
          'FAVORIT', // Judul minimalis
          style: TextStyle(
            color: Colors.white, // Teks berwarna putih
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ArticleProvider>(
        builder: (context, articleProvider, child) {
          final favoriteArticles = articleProvider.favoriteArticles;

          // Tampilan jika tidak ada artikel favorit
          if (favoriteArticles.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Anda belum punya artikel favorit.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Tampilan jika ada artikel favorit
          return ListView.builder(
            padding: const EdgeInsets.all(16), // Padding yang konsisten
            itemCount: favoriteArticles.length,
            itemBuilder: (context, index) {
              final article = favoriteArticles[index];
              // Menggunakan desain item list yang sama dengan halaman utama
              return _buildFavoriteArticleListItem(context, article);
            },
          );
        },
      ),
    );
  }

  // --- WIDGET UNTUK ITEM FAVORIT (DESAIN DISAMAKAN DENGAN HOME) ---
  Widget _buildFavoriteArticleListItem(BuildContext context, Article article) {
    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, '/articleDetail', arguments: article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
              ),
            ]),
        child: Row(
          children: [
            if (article.featuredImageUrl != null &&
                article.featuredImageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  article.featuredImageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported,
                        color: Colors.grey[400]),
                  ),
                ),
              ),
            if (article.featuredImageUrl == null ||
                article.featuredImageUrl!.isEmpty)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.image, color: Colors.grey[400]),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Oleh: ${article.author}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
