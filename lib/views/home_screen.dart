// lib/views/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bubuy/providers/article_provider.dart';
import 'package:bubuy/models/article.dart';
import 'package:another_carousel_pro/another_carousel_pro.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ArticleProvider>(context, listen: false);
      if (provider.articles.isEmpty) {
        provider.fetchArticles();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    // Kosongkan search bar saat refresh
    _searchController.clear();
    await Provider.of<ArticleProvider>(context, listen: false).fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF005AAB);
    final Color lightBlueBg = const Color(0xFFF0F4F8);

    return Scaffold(
      backgroundColor: lightBlueBg,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: primaryBlue,
        title: const Text(
          'BUBUY',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 3,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ArticleProvider>(
        builder: (context, articleProvider, child) {
          if (articleProvider.isLoading && articleProvider.articles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Slider sekarang juga menggunakan data yang sudah difilter
          final articlesForSlider = articleProvider.articles
              .where((a) =>
                  a.featuredImageUrl != null && a.featuredImageUrl!.isNotEmpty)
              .toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                // --- WIDGET KOLOM PENCARIAN BARU ---
                SliverToBoxAdapter(
                  child: _buildSearchBar(),
                ),
                // ---------------------------------

                if (articlesForSlider.isNotEmpty &&
                    _searchController.text.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildNewsSlider(articlesForSlider, primaryBlue),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Berita Terbaru'
                          : 'Hasil Pencarian',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),

                // Tampilkan pesan jika hasil pencarian kosong
                if (articleProvider.articles.isEmpty &&
                    _searchController.text.isNotEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text('Berita tidak ditemukan.'),
                    ),
                  )
                else
                  // Gunakan daftar yang sudah difilter
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final article = articleProvider.articles[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildArticleListItem(context, article),
                        );
                      },
                      childCount: articleProvider.articles.length,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/writeArticle');
        },
        backgroundColor: primaryBlue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  // --- WIDGET BARU UNTUK KOLOM PENCARIAN ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          // Panggil fungsi search di provider setiap kali teks berubah
          Provider.of<ArticleProvider>(context, listen: false)
              .searchArticles(query);
        },
        decoration: InputDecoration(
          hintText: 'Cari judul berita...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<ArticleProvider>(context, listen: false)
                        .searchArticles('');
                  },
                )
              : null,
        ),
      ),
    );
  }
  // -----------------------------------------

  Widget _buildNewsSlider(List<Article> articles, Color indicatorColor) {
    List<Widget> sliderImages = articles.map((article) {
      return GestureDetector(
        onTap: () =>
            Navigator.pushNamed(context, '/articleDetail', arguments: article),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/bubuy.png',
                  image: article.featuredImageUrl!,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.blueGrey[800]),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20.0,
              left: 20.0,
              right: 20.0,
              child: Text(
                article.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        height: 200.0,
        width: double.infinity,
        child: AnotherCarousel(
          images: sliderImages,
          dotSize: 6,
          dotBgColor: Colors.transparent,
          dotColor: indicatorColor,
          dotIncreasedColor: indicatorColor,
          indicatorBgPadding: 5.0,
          autoplay: true,
          borderRadius: true,
          boxFit: BoxFit.cover,
          animationCurve: Curves.fastOutSlowIn,
          animationDuration: const Duration(milliseconds: 1000),
        ),
      ),
    );
  }

  Widget _buildArticleListItem(BuildContext context, Article article) {
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
            if (article.isFavorite)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(Icons.favorite, color: Colors.red[400], size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
