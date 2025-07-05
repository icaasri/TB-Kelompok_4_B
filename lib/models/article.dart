// lib/models/article.dart

class Article {
  String? id;
  String author;
  String title;
  String content;
  String category;
  String? featuredImageUrl;
  String? summary;
  bool isFavorite;

  Article({
    this.id,
    required this.author,
    required this.title,
    required this.content,
    required this.category,
    this.featuredImageUrl,
    this.summary,
    this.isFavorite = false,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id']?.toString(),
      author: json['author_name'] ?? 'Penulis Tidak Dikenal',
      title: json['title'] ?? 'Tanpa Judul',
      content: json['content'] ?? 'Tidak ada konten.',
      category: json['category'] ?? 'Tanpa Kategori',
      featuredImageUrl: json['featured_image_url'],
      summary: json['summary'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'content': content,
      'category': category,
    };

    if (summary != null && summary!.isNotEmpty) {
      data['summary'] = summary;
    }
    if (featuredImageUrl != null && featuredImageUrl!.isNotEmpty) {
      data['featuredImageUrl'] = featuredImageUrl;
    }

    return data;
  }
}
