// lib/views/article_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bubuy/models/article.dart';
import 'package:bubuy/providers/article_provider.dart';
import 'package:bubuy/views/write_article_screen.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  void _navigateToEditScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => WriteArticleScreen(article: article),
    ));
  }

  void _deleteArticle(BuildContext context) {
    if (article.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Artikel ini tidak memiliki ID.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus artikel ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(ctx).pop();
                final success =
                    await Provider.of<ArticleProvider>(context, listen: false)
                        .deleteArticle(article.id!);
                if (success && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleProvider>(
      builder: (context, articleProvider, child) {
        final currentArticle = articleProvider.articles.firstWhere(
          (a) => a.id == article.id,
          orElse: () => article,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(currentArticle.title),
            actions: [
              IconButton(
                icon: Icon(
                  currentArticle.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: currentArticle.isFavorite ? Colors.red : null,
                ),
                onPressed: () async {
                  if (currentArticle.id != null) {
                    await articleProvider
                        .toggleFavoriteStatus(currentArticle.id!);
                  }
                },
                tooltip: 'Favorit',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _navigateToEditScreen(context),
                tooltip: 'Edit Artikel',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteArticle(context),
                tooltip: 'Hapus Artikel',
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentArticle.featuredImageUrl != null &&
                    currentArticle.featuredImageUrl!.isNotEmpty)
                  Image.network(
                    currentArticle.featuredImageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image,
                                  color: Colors.grey, size: 50),
                              SizedBox(height: 8),
                              Text('Gagal memuat gambar'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentArticle.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // --- PERUBAHAN TAMPILAN KATEGORI ---
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              color: Colors.grey[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Oleh ${currentArticle.author}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.label_outline,
                                    color: Colors.blue[800], size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  currentArticle.category,
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // ---------------------------------
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey[200]),
                      const SizedBox(height: 16),
                      Text(
                        currentArticle.content,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
