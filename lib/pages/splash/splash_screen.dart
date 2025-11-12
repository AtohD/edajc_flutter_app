import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkAdminExists();
  }

  Future<void> _checkAdminExists() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('status')
          .get();

      final adminCreated = doc.data()?['adminCreated'] ?? false;

      if (!adminCreated) {
        // Rediriger vers l'inscription de l'admin
        Get.offAllNamed('/signUp');
      } else {
        // Admin existe, on va à la connexion
        Get.offAllNamed('/firstConnexion');
      }
    } catch (e) {
      print('Erreur Firestore: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Erreur lors de la connexion à la base de données.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkAdminExists,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Affiche le loader pendant la vérification
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
