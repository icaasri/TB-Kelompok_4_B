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
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        actions: [
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
            // PERBAIKAN: Cek apakah URL tidak null DAN tidak kosong
            if (article.featuredImageUrl != null &&
                article.featuredImageUrl!.isNotEmpty)
              Image.network(
                article.featuredImageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Widget ini ditampilkan jika URL ada tapi gambar gagal dimuat
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
                  if (article.featuredImageUrl != null &&
                      article.featuredImageUrl!.isNotEmpty)
                    const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Oleh ${article.author} - Kategori: ${article.category}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.content,
                    style: Theme.of(context).textTheme.bodyLarge,
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
