import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_profile_model.dart';
import 'package:provider/provider.dart';
import '../../providers/user_list_provider.dart';
import '../../services/firebase_secondary_auth.dart';

class MinistryMembersDialog extends StatefulWidget {
  final UserProfileModel? user;

  const MinistryMembersDialog({super.key, this.user});

  @override
  State<MinistryMembersDialog> createState() => _MinistryMembersDialogState();
}

class _MinistryMembersDialogState extends State<MinistryMembersDialog> {
  final _formKey = GlobalKey<FormState>();

  // Champs texte
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController mobileController;
  late TextEditingController whatsappController;
  late TextEditingController facebookController;
  late TextEditingController instagramController;
  late TextEditingController cityOfBirthController;
  late TextEditingController educationController;
  late TextEditingController jobController;
  late TextEditingController testimonyController;
  TextEditingController otherEthnicityController = TextEditingController();
  bool isOtherEthnicity = false;
  TextEditingController otherCountryController = TextEditingController();
  bool isOtherCountry = false;
  TextEditingController otherRegionController = TextEditingController();
  bool isOtherRegion = false;
  TextEditingController otherLanguageController = TextEditingController();
  bool isOtherLanguage = false;

  DateTime? birthDate;

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

  final List<String> regions = [
    'Abidjan',
    'Abengourou',
    'Daoukro',
    'Yamoussoukro',
    'Daloa',
    'Autre'
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
    'admin',
    'Assistant générale',
    'Directeur regionale',
    'Assistant accueil',
    'Enseignant titulaire',
    'Enseignant de recyclage',
    'Ame',
    'user'
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
    whatsappController =
        TextEditingController(text: user?.contacts['whatsapp'] ?? '');
    facebookController =
        TextEditingController(text: user?.contacts['facebook'] ?? '');
    instagramController =
        TextEditingController(text: user?.contacts['instagram'] ?? '');
    cityOfBirthController =
        TextEditingController(text: user?.cityOfBirth ?? '');
    educationController = TextEditingController(text: user?.education ?? '');
    jobController = TextEditingController(text: user?.job ?? '');
    testimonyController = TextEditingController(text: user?.testimony ?? '');

    birthDate = user?.birthDate ?? DateTime(2000);
    selectedCountry = user?.country;
    selectedRegion = user?.region;
    selectedEthnicity = user?.ethnicity;
    selectedMaritalStatus = user?.maritalStatus;
    selectedChildrenCount = user?.childrenCount ?? 0;
    selectedRole = user?.role ?? 'admin';
    selectedLanguages = user?.languages ?? [];
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    whatsappController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    cityOfBirthController.dispose();
    educationController.dispose();
    jobController.dispose();
    testimonyController.dispose();
    otherEthnicityController.dispose();
    otherCountryController.dispose();
    otherRegionController.dispose();

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
              _buildTextField(whatsappController, 'WhatsApp'),
              _buildTextField(facebookController, 'Facebook'),
              _buildTextField(instagramController, 'Instagram'),
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
                'Region',
                regions,
                selectedRegion,
                (val) {
                  setState(() {
                    selectedRegion = val;
                    isOtherRegion = val == 'Autre';
                  });
                },
              ),
              if (isOtherRegion)
                _buildTextField(otherRegionController, 'Précisez votre Region'),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
        ElevatedButton(onPressed: _submit, child: const Text('Enregistrer')),
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

    final userProvider = context.read<UserListProvider>();

    if (widget.user == null) {
      try {
        // Récupère l'utilisateur actuellement connecté
        final currentUser = FirebaseAuth.instance.currentUser;
        final creatorUid = currentUser?.uid;

        String creatorInfo = 'created by inconnu';
        final createdByUid = creatorUid ?? '';

        if (creatorUid != null) {
          final creatorDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(creatorUid)
              .get();

          if (creatorDoc.exists) {
            final creator = UserProfileModel.fromFirestore(creatorDoc);
            creatorInfo =
                '${creator.role} ${creator.firstName} ${creator.lastName}';
          }
        }

        // Crée le compte dans FirebaseAuth sans déconnecter le créateur
        UserCredential cred = await createUserWithSecondaryApp(
          email: emailController.text.trim(),
          password: 'Temp1234@',
        );

        final uid = cred.user!.uid;

        // Crée le modèle complet de l’utilisateur
        final newUser = UserProfileModel(
          uid: uid,
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          email: emailController.text.trim(),
          birthDate: birthDate!,
          country: isOtherCountry
              ? otherCountryController.text
              : (selectedCountry ?? ''),
          region: isOtherRegion
              ? otherRegionController.text
              : (selectedRegion ?? ''),
          cityOfBirth: cityOfBirthController.text,
          ethnicity: isOtherEthnicity
              ? otherEthnicityController.text
              : (selectedEthnicity ?? ''),
          contacts: {
            'email': emailController.text.trim(),
            'mobile': mobileController.text,
            'whatsapp': whatsappController.text,
            'facebook': facebookController.text,
            'instagram': instagramController.text,
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
          role: selectedRole ?? 'user',
          createdBy: creatorInfo,
          createdByUid: createdByUid,
          createdAt: DateTime.now(),
        );

        // Ajoute à Firestore
        await userProvider.addUser(uid, newUser);

        // Envoie mail de réinitialisation
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim(),
        );

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Utilisateur créé et e-mail de réinitialisation envoyé.'),
          ),
        );
      } catch (e) {
        debugPrint("Erreur lors de l'ajout de l'utilisateur: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }
}
