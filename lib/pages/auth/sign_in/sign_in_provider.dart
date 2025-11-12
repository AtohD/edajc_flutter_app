import 'package:flareline_uikit/core/mvvm/base_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';

class SignInProvider extends BaseViewModel {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  SignInProvider(super.ctx) {
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  Future<void> signIn(BuildContext context) async {
    setBusy(true);
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        if (user.emailVerified) {
          //  Étape 1 : récupérer le rôle depuis Firestore
      await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

          if (user.emailVerified) {
            // Charger les données utilisateur dans UserProvider
            await Provider.of<UserProvider>(context, listen: false)
                .loadUser(user.uid);

            final role =
                Provider.of<UserProvider>(context, listen: false).user?.role ??
                    'user';
            print('Rôle chargé dans UserProvider : $role');

            print('Rôle trouvé : $role');

            // 🔁 Étape 2 : redirection selon le rôle
            if (role == 'admin') {
              Navigator.of(context).pushNamed('/');
            } else if (role == 'Assistant générale') {
              Navigator.of(context).pushNamed('/');
            } else if (role == 'Directeur regionale') {
              Navigator.of(context).pushNamed('/');
            } else if (role == 'Assistant accueil') {
              Navigator.of(context).pushNamed('/');
            } else if (role == 'Enseignant titulaire' ||
                role == 'Enseignant de recyclage') {
              Navigator.of(context).pushNamed('/profile');
            } else if (role == 'Ame') {
              Navigator.of(context).pushNamed('/profile');
            } else {
              // Rôle inconnu
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rôle utilisateur inconnu.')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profil utilisateur introuvable.")),
            );
          }
        } else {
          await FirebaseAuth.instance.signOut();
          await user.sendEmailVerification();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Veuillez vérifier votre email avant de vous connecter. Un email de vérification vient de vous être renvoyé.',
              ),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Erreur de connexion';
      if (e.code == 'user-not-found') {
        errorMsg = "Utilisateur non trouvé pour cet email.";
      } else if (e.code == 'wrong-password') {
        errorMsg = "Mot de passe incorrect.";
      } else if (e.code == 'invalid-email') {
        errorMsg = "Email invalide.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur inattendue : $e')),
      );
    } finally {
      setBusy(false);
    }
  }
}
