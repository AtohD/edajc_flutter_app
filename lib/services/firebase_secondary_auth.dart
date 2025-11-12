import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseApp? _secondaryApp;

Future<UserCredential> createUserWithSecondaryApp({
  required String email,
  required String password,
}) async {
  try {
    // S'assurer que l'app principale est bien initialisée
    final primaryApp = Firebase.apps.isNotEmpty
        ? Firebase.app()
        : await Firebase.initializeApp();

    // Initialiser une app secondaire une seule fois
    _secondaryApp ??= await Firebase.initializeApp(
      name: 'SecondaryApp',
      options: primaryApp.options,
    );

    final FirebaseAuth secondaryAuth =
        FirebaseAuth.instanceFor(app: _secondaryApp!);

    final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential;
  } on FirebaseAuthException catch (e) {
    throw Exception('Firebase Auth Error: ${e.code} - ${e.message}');
  } on FirebaseException catch (e) {
    throw Exception('Firebase Error: ${e.code} - ${e.message}');
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}
