import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile_model.dart';
import 'package:provider/provider.dart';
import '../../providers/user_list_provider.dart';
import '../../services/firebase_secondary_auth.dart';

class UserFormDialog extends StatefulWidget {
  final UserProfileModel? user;

  const UserFormDialog({super.key, this.user});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Champs texte
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  late TextEditingController cityOfBirthController;
  late TextEditingController educationController;
  late TextEditingController jobController;
  late TextEditingController testimonyController;
  TextEditingController otherEthnicityController = TextEditingController();
  bool isOtherEthnicity = false;
  TextEditingController otherCountryController = TextEditingController();
  bool isOtherCountry = false;
  TextEditingController otherLanguageController = TextEditingController();
  bool isOtherLanguage = false;

  DateTime? birthDate;

  bool _isLoading = false;

  String? selectedCountry;
  String? selectedRegion;
  String? selectedEthnicity;
  String? selectedMaritalStatus;
  int selectedChildrenCount = 0;
  List<String> selectedLanguages = [];

  final List<String> countries = [
    'Côte d’Ivoire',
    'France',
    'Italie',
    'Espagne',
    'Allemagne',
    'États-Unis',
    'Canada',
    'Burkina Faso',
    'Mali',
    'Ghana',
    'Guinée',
    'Nigeria',
    'Maroc',
    'Afrique du Sud',
    'Royaume-Uni',
    'Autre',
  ];

  final List<String> ethnicities = [
    '',
    // Akan
    'Baoulé',
    'Agni',
    'Abrons',
    'Attié',
    'Abé',
    'Abouré',
    'Akyé',
    'Alladian',
    'Avikam',
    'Ehotilé',
    // Krou
    'Bété',
    'Dida',
    'Wé (Guéré)',
    'Wobé',
    'Kru',
    'Godié',
    'Kodia',
    'Kouya',
    'Niaboua',
    // Mandé du Nord
    'Malinké',
    'Dioula',
    'Sénoufo',
    'Koyaka',
    'Tagbana',
    // Mandé du Sud
    'Gouro',
    'Yaouré',
    'Mandingue du Sud',
    // Gour
    'Lobi',
    'Koulango',
    'Djimini',
    'Lobi-Dagari',
    'Birifor',
    'Dagara',
    // Autres & minorités
    'Mahouka',
    'Toura',
    'Kroumen',
    'Autre'
  ];

  final List<String> maritalStatusOptions = [
    'Célibataire',
    'Marié(e)',
    'Divorcé(e)',
    'Veuf(ve)'
  ];
  final List<int> childrenCountOptions = List.generate(11, (i) => i); // 0 à 10
  final List<String> allRoles = [
    'Ame',
  ];
  String? selectedRole;

  final List<String> allLanguages = [
    'Français',
    'Anglais',
    'Espagnol',
    'Autre'
  ];

  @override
  void initState() {
    super.initState();
    final user = widget.user;

    firstNameController = TextEditingController(text: user?.firstName ?? '');
    lastNameController = TextEditingController(text: user?.lastName ?? '');
    emailController =
        TextEditingController(text: user?.contacts['email'] ?? '');
    mobileController =
        TextEditingController(text: user?.contacts['mobile'] ?? '');
    cityOfBirthController =
        TextEditingController(text: user?.cityOfBirth ?? '');
    educationController = TextEditingController(text: user?.education ?? '');
    jobController = TextEditingController(text: user?.job ?? '');
    testimonyController = TextEditingController(text: user?.testimony ?? '');

    birthDate = user?.birthDate ?? DateTime(2000);
    selectedCountry = user?.country;
    selectedEthnicity = user?.ethnicity;
    selectedMaritalStatus = user?.maritalStatus;
    selectedChildrenCount = user?.childrenCount ?? 0;
    selectedRole = user?.role ?? 'Ame';
    selectedLanguages = user?.languages ?? [];
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    cityOfBirthController.dispose();
    educationController.dispose();
    jobController.dispose();
    testimonyController.dispose();
    otherEthnicityController.dispose();
    otherCountryController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null
          ? 'Ajouter un utilisateur'
          : 'Modifier un utilisateur'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(firstNameController, 'Prénom'),
              _buildTextField(lastNameController, 'Nom'),
              _buildTextField(emailController, 'Email'),
              _buildTextField(mobileController, 'Téléphone mobile'),
              _buildTextField(cityOfBirthController, 'Ville de naissance'),
              _buildDropdown(
                'Ethnie',
                ethnicities,
                selectedEthnicity,
                (val) {
                  setState(() {
                    selectedEthnicity = val;
                    isOtherEthnicity = val == 'Autre';
                  });
                },
              ),
              if (isOtherEthnicity)
                _buildTextField(
                    otherEthnicityController, 'Précisez votre ethnie'),
              _buildDropdown(
                'Pays',
                countries,
                selectedCountry,
                (val) {
                  setState(() {
                    selectedCountry = val;
                    isOtherCountry = val == 'Autre';
                  });
                },
              ),
              if (isOtherCountry)
                _buildTextField(otherCountryController, 'Précisez votre Pays'),
              _buildDropdown(
                  'Situation matrimoniale',
                  maritalStatusOptions,
                  selectedMaritalStatus,
                  (val) => setState(() => selectedMaritalStatus = val)),
              _buildDropdown<int>(
                  'Nombre d\'enfants',
                  childrenCountOptions,
                  selectedChildrenCount,
                  (val) => setState(() => selectedChildrenCount = val ?? 0)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  items: allRoles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.replaceAll('_', ' ').toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Rôle'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Champ requis' : null,
                ),
              ),
              _buildTextField(educationController, 'Formation professionnelle'),
              _buildTextField(jobController, 'Profession'),
              _buildTextField(testimonyController, 'Témoignage'),
              const SizedBox(height: 10),
              Text(
                  'Date de naissance : ${birthDate?.toLocal().toIso8601String().split("T")[0]}'),
              TextButton(
                  onPressed: _selectDate,
                  child: const Text('Choisir une date')),
              const SizedBox(height: 10),
              const Text('Langues parlées'),
              Wrap(
                children: allLanguages.map((lang) {
                  return CheckboxListTile(
                    title: Text(lang),
                    value: selectedLanguages.contains(lang),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedLanguages.add(lang);
                        } else {
                          selectedLanguages.remove(lang);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              if (selectedLanguages.contains('Autre'))
                _buildTextField(
                    otherLanguageController, 'Précisez la langue parlée'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('Annuler')),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Enregistrer'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value == null || value.isEmpty ? 'Champ requis' : null,
      ),
    );
  }

  Widget _buildDropdown<T>(
      String label, List<T> items, T? selected, void Function(T?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<T>(
        initialValue: selected,
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(item.toString()),
                ))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value == null || (value is String && value.isEmpty)
                ? 'Champ requis'
                : null,
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => birthDate = picked);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || birthDate == null) return;

    setState(() => _isLoading = true);
    final userProvider = context.read<UserListProvider>();

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final creatorUid = currentUser?.uid;
      String creatorInfo = 'created by inconnu';
      final createdByUid = creatorUid ?? '';
      String userRegion = ''; // 👈 région du créateur

      if (creatorUid != null) {
        final creatorDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(creatorUid)
            .get();

        if (creatorDoc.exists) {
          final creator = UserProfileModel.fromFirestore(creatorDoc);
          creatorInfo = '${creator.role} ${creator.firstName} ${creator.lastName}';
          userRegion = creator.region; // ✅ on récupère la région du créateur
        }
      }

      // Vérifie si email existe déjà
      final existing = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(emailController.text.trim());
      if (existing.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Un utilisateur avec cet email existe déjà.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Crée le compte sans déconnexion
      UserCredential cred = await createUserWithSecondaryApp(
        email: emailController.text.trim(),
        password: 'Temp1234@',
      );
      final uid = cred.user!.uid;

      // 🔥 Création du nouveau profil avec la région du créateur
      final newUser = UserProfileModel(
        uid: uid,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text.trim(),
        birthDate: birthDate!,
        country: isOtherCountry
            ? otherCountryController.text
            : (selectedCountry ?? ''),
        region: userRegion, // ✅ Région héritée du créateur
        cityOfBirth: cityOfBirthController.text,
        ethnicity: isOtherEthnicity
            ? otherEthnicityController.text
            : (selectedEthnicity ?? ''),
        contacts: {
          'email': emailController.text.trim(),
          'mobile': mobileController.text,
        },
        maritalStatus: selectedMaritalStatus ?? '',
        childrenCount: selectedChildrenCount,
        education: educationController.text,
        job: jobController.text,
        languages: selectedLanguages.contains('Autre') &&
                otherLanguageController.text.isNotEmpty
            ? selectedLanguages.where((lang) => lang != 'Autre').toList() +
                [otherLanguageController.text]
            : selectedLanguages,
        testimony: testimonyController.text,
        role: selectedRole ?? 'Ame',
        createdBy: creatorInfo,
        createdByUid: createdByUid,
        createdAt: DateTime.now(),
      );

      await userProvider.addUser(uid, newUser);
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur créé et e-mail de réinitialisation envoyé.'),
        ),
      );
    } catch (e) {
      debugPrint("Erreur lors de l'ajout de l'utilisateur: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

}
