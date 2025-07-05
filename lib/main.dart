// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bubuy/services/api_service.dart';
import 'package:bubuy/providers/auth_provider.dart';
import 'package:bubuy/providers/article_provider.dart';
import 'package:bubuy/views/splash_screen.dart';
import 'package:bubuy/views/main_navigation.dart';
import 'package:bubuy/views/write_article_screen.dart';
import 'package:bubuy/views/article_detail_screen.dart';
import 'package:bubuy/models/article.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Sediakan ApiService
        Provider(create: (_) => ApiService()),

        // 2. Sediakan AuthProvider, yang bergantung pada ApiService
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            apiService: Provider.of<ApiService>(context, listen: false),
          ),
        ),

        // 3. Sediakan ArticleProvider, yang bergantung pada AuthProvider (untuk mendapatkan token)
        ChangeNotifierProxyProvider<AuthProvider, ArticleProvider>(
          create: (context) => ArticleProvider(
              apiService: Provider.of<ApiService>(context, listen: false)),
          update: (context, auth, previousArticleProvider) {
            final apiService = Provider.of<ApiService>(context, listen: false);
            // Setiap kali auth berubah (misal setelah dapat token),
            // update token di dalam ApiService.
            apiService.setToken(auth.token);

            // Pastikan kita mengembalikan instance ArticleProvider yang sudah ada
            // dan hanya meng-update referensi apiService-nya jika perlu.
            previousArticleProvider!.apiService = apiService;
            return previousArticleProvider;
          },
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Bubuy News',
            theme: ThemeData(primarySwatch: Colors.deepPurple),
            debugShowCheckedModeBanner: false,
            home: auth.isLoading
                ? const SplashScreen()
                : auth.isAuthenticated
                    ? const MainNavigation()
                    : const Scaffold(
                        body: Center(
                          child: Text(
                            'Gagal terhubung ke server.\nSilakan coba lagi nanti.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
            routes: {
              '/main': (context) => const MainNavigation(),
              '/writeArticle': (context) => const WriteArticleScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/articleDetail') {
                final args = settings.arguments as Article;
                return MaterialPageRoute(
                  builder: (context) => ArticleDetailScreen(article: args),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
