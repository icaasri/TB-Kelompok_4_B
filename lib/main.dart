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
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            apiService: Provider.of<ApiService>(context, listen: false),
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ArticleProvider>(
          create: (context) => ArticleProvider(
              apiService: Provider.of<ApiService>(context, listen: false)),
          update: (context, auth, previousArticleProvider) {
            final apiService = Provider.of<ApiService>(context, listen: false);
            apiService.setToken(auth.token);
            previousArticleProvider!.apiService = apiService;
            return previousArticleProvider;
          },
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Bubuy News',
            // --- PERUBAHAN TEMA UTAMA ---
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
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
