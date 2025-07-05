// lib/views/splash_screen.dart

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Menampilkan gambar dari asset
            Image.asset(
              'assets/images/bubuy.png', // Pastikan path ini sesuai
              width: 150, // Atur lebar gambar sesuai kebutuhan
            ),
            const SizedBox(height: 30), // Jarak antara gambar dan loading

            // 2. Indikator loading
            const CircularProgressIndicator(),
            const SizedBox(height: 16),

            // 3. Teks di bawah loading
            const Text('Memuat data...'),
          ],
        ),
      ),
    );
  }
}
