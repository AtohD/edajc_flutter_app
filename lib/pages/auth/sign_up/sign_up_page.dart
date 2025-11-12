import 'package:flareline/pages/auth/sign_up/sign_up_provider.dart';
import 'package:flareline_uikit/core/mvvm/base_widget.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/forms/outborder_text_form_field.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SignUpWidget extends BaseWidget<SignUpProvider> {
  const SignUpWidget({super.key});

  @override
  Widget bodyWidget(
      BuildContext context, SignUpProvider viewModel, Widget? child) {
    return Scaffold(body: ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
          return Center(
            child: contentDesktopWidget(context, viewModel),
          );
        }

        return contentMobileWidget(context, viewModel);
      },
    ));
  }

  @override
  SignUpProvider viewModelBuilder(BuildContext context) {
    return SignUpProvider(context);
  }

  Widget contentDesktopWidget(BuildContext context, SignUpProvider viewModel) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      CommonCard(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Row(children: [
          Expanded(
              child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.appName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(AppLocalizations.of(context)!.slogan),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: 350,
                child: SvgPicture.asset('assets/signin/signup.svg',
                    semanticsLabel: ''),
              )
            ],
          )),
          const VerticalDivider(width: 1),
          Expanded(child: _formWidget(context, viewModel))
        ]),
      ),
    ]);
  }

  Widget contentMobileWidget(BuildContext context, SignUpProvider viewModel) {
    return CommonCard(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: _formWidget(context, viewModel),
    );
  }

  Widget _formWidget(BuildContext context, SignUpProvider viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.startForFree),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.startForFree,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            labelText: AppLocalizations.of(context)!.email,
            hintText: AppLocalizations.of(context)!.emailHint,
            keyboardType: TextInputType.emailAddress,
            suffixWidget: SvgPicture.asset(
              'assets/signin/email.svg',
              width: 22,
              height: 22,
            ),
            controller: viewModel.emailController,
          ),
          const SizedBox(height: 16),
          OutBorderTextFormField(
            obscureText: true,
            labelText: AppLocalizations.of(context)!.password,
            hintText: AppLocalizations.of(context)!.passwordHint,
            suffixWidget: SvgPicture.asset(
              'assets/signin/lock.svg',
              width: 22,
              height: 22,
            ),
            controller: viewModel.passwordController,
          ),
          const SizedBox(height: 20),
          OutBorderTextFormField(
            obscureText: true,
            labelText: AppLocalizations.of(context)!.retypePassword,
            hintText: AppLocalizations.of(context)!.retypePasswordHint,
            suffixWidget: SvgPicture.asset(
              'assets/signin/lock.svg',
              width: 22,
              height: 22,
            ),
            controller: viewModel.rePasswordController,
          ),
          const SizedBox(height: 20),
          ButtonWidget(
            type: ButtonType.primary.type,
            btnText: AppLocalizations.of(context)!.createAccount,
            onTap: () async {
              final email = viewModel.emailController.text.trim();
              final password = viewModel.passwordController.text.trim();
              final rePassword = viewModel.rePasswordController.text.trim();

              if (email.isEmpty || !email.contains('@')) {
                Get.snackbar("Erreur", "Adresse email invalide");
                return;
              }
              if (password.length < 6) {
                Get.snackbar("Erreur",
                    "Le mot de passe doit contenir au moins 6 caractères");
                return;
              }
              if (password != rePassword) {
                Get.snackbar(
                    "Erreur", "Les mots de passe ne correspondent pas");
                return;
              }

              try {
                final credential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );

                // Envoyer un e-mail de vérification
                await credential.user!.sendEmailVerification();

                // Enregistrement dans Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(credential.user!.uid)
                    .set({
                  'uid': credential.user!.uid,
                  'email': email,
                  'role': 'admin',
                  'createdAt': FieldValue.serverTimestamp(),
                });

                Get.snackbar("Succès",
                    "Compte créé ! Vérifiez votre e-mail pour l'activer.");
                await FirebaseFirestore.instance
                    .collection('config')
                    .doc('status')
                    .set({'adminCreated': true}, SetOptions(merge: true));

                Get.offAllNamed('/signIn');
              } on FirebaseAuthException catch (e) {
                Get.snackbar("Erreur Firebase", e.message ?? "Erreur inconnue");
              } catch (e) {
                Get.snackbar("Erreur", "Erreur inconnue : $e");
              }
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.haveAnAccount),
              InkWell(
                child: Text(
                  AppLocalizations.of(context)!.signIn,
                  style: const TextStyle(color: Colors.blue),
                ),
                onTap: () {
                  Navigator.of(context).popAndPushNamed('/signIn');
                },
              )
            ],
          )
        ],
      ),
    );
  }

  bool get isPage => true;

  bool get showTitle => false;

  bool get isAlignCenter => true;
}
