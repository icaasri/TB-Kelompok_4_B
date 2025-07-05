// lib/views/write_article_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bubuy/models/article.dart';
import 'package:bubuy/providers/article_provider.dart';

class WriteArticleScreen extends StatefulWidget {
  final Article? article;

  const WriteArticleScreen({super.key, this.article});

  @override
  State<WriteArticleScreen> createState() => _WriteArticleScreenState();
}

class _WriteArticleScreenState extends State<WriteArticleScreen> {
  final _formKey = GlobalKey<FormState>();

  var _articleData = {
    'title': '',
    'summary': '',
    'content': '',
    'category': null as String?,
    'featuredImageUrl': '',
  };

  bool _isSaving = false;
  bool get _isEditing => widget.article != null;

  final Map<String, String> _categoryOptions = {
    'Business': 'Bisnis',
    'Technology': 'Teknologi',
    'Health': 'Kesehatan',
    'Sports': 'Olahraga',
    'Lingkungan': 'Lingkungan',
    'Science': 'Sains',
    'Politics': 'Politik',
  };

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _articleData = {
        'title': widget.article!.title,
        'summary': widget.article!.summary ?? '',
        'content': widget.article!.content,
        'category': widget.article!.category,
        'featuredImageUrl': widget.article!.featuredImageUrl ?? '',
      };
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isSaving = true;
    });

    final provider = Provider.of<ArticleProvider>(context, listen: false);

    final articleToSave = Article(
      id: _isEditing ? widget.article!.id : null,
      title: _articleData['title']!,
      summary: _articleData['summary'],
      content: _articleData['content']!,
      category: _articleData['category']!,
      featuredImageUrl: _articleData['featuredImageUrl'],
      author: '',
    );

    bool success = false;
    if (_isEditing) {
      success = await provider.updateArticle(articleToSave);
    } else {
      success = await provider.createArticle(articleToSave);
    }

    // PERBAIKAN: Logika navigasi disederhanakan
    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      // Jika gagal, hentikan loading agar tombol bisa ditekan lagi
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Artikel' : 'Tulis Artikel Baru'),
      ),
      body: _isSaving
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Menyimpan dan me-refresh berita..."),
              ],
            ))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // ... (Semua TextFormField tetap sama)
                    TextFormField(
                      initialValue: _articleData['title'],
                      decoration: const InputDecoration(labelText: 'Judul'),
                      validator: (value) =>
                          value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                      onSaved: (value) => _articleData['title'] = value!,
                    ),
                    TextFormField(
                      initialValue: _articleData['summary'],
                      decoration: const InputDecoration(
                          labelText: 'Ringkasan (Summary)'),
                      onSaved: (value) => _articleData['summary'] = value!,
                    ),
                    DropdownButtonFormField<String>(
                      value: _articleData['category'],
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      hint: const Text('Pilih Kategori'),
                      items: _categoryOptions.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _articleData['category'] = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Kategori harus dipilih' : null,
                      onSaved: (value) => _articleData['category'] = value,
                    ),
                    TextFormField(
                      initialValue: _articleData['content'],
                      decoration: const InputDecoration(labelText: 'Konten'),
                      maxLines: 5,
                      validator: (value) {
                        if (value!.isEmpty) return 'Konten tidak boleh kosong';
                        if (value.length < 10)
                          return 'Konten minimal 10 karakter';
                        return null;
                      },
                      onSaved: (value) => _articleData['content'] = value!,
                    ),
                    TextFormField(
                      initialValue: _articleData['featuredImageUrl'],
                      decoration:
                          const InputDecoration(labelText: 'URL Gambar'),
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final uri = Uri.tryParse(value);
                        if (uri == null || !uri.isAbsolute) {
                          return 'Format URL tidak valid';
                        }
                        return null;
                      },
                      onSaved: (value) =>
                          _articleData['featuredImageUrl'] = value!,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveForm,
                      child:
                          Text(_isEditing ? 'Simpan Perubahan' : 'Terbitkan'),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
