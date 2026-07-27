import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../repository/auth_repository.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = await StorageService.getToken();

    if (!mounted) return;

    if (token != null) {
      try {
        final user = await AuthRepository().getCurrentUser();
        await StorageService.saveUser(user);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(user: user),
          ),
        );
        return;
      } catch (_) {
        await StorageService.logout();
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [

              Icon(
                Icons.sports_martial_arts,
                size: 90,
                color: Colors.deepPurple,
              ),

              SizedBox(height: 24),

              Text(
                "HORUS ACADEMY",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              SizedBox(height: 10),

              Text(
                "Discipline • Strength • Respect",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              SizedBox(height: 50),

              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}