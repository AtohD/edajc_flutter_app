import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SoulMembersDialog extends StatefulWidget {
  const SoulMembersDialog({super.key});

  @override
  State<SoulMembersDialog> createState() => _SoulMembersDialogState();
}

class _SoulMembersDialogState extends State<SoulMembersDialog> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController cityOfBirthController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController testimonyController = TextEditingController();
  final TextEditingController otherEthnicityController =
      TextEditingController();
  final TextEditingController otherCountryController = TextEditingController();
  final TextEditingController otherLanguageController = TextEditingController();

  DateTime? birthDate;

  // Dropdowns
  String? selectedCountry;
  String? selectedRegion;
  String? selectedEthnicity;
  String? selectedMaritalStatus;
  int selectedChildrenCount = 0;
  List<String> selectedLanguages = [];

  bool isOtherEthnicity = false;
  bool isOtherCountry = false;
  bool isOtherRegion = false;
  bool isOtherLanguage = false;

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
    'Baoulé',
    'Agni',
    'Bété',
    'Malinké',
    'Dioula',
    'Sénoufo',
    'Lobi',
    'Wé',
    'Autre',
  ];

  final List<String> maritalStatusOptions = [
    'Célibataire',
    'Marié(e)',
    'Divorcé(e)',
    'Veuf(ve)'
  ];

  final List<int> childrenCountOptions = List.generate(11, (i) => i); // 0 à 10

  final List<String> allLanguages = [
    'Français',
    'Anglais',
    'Espagnol',
    'Autre'
  ];

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    mobileController.dispose();
    cityOfBirthController.dispose();
    jobController.dispose();
    testimonyController.dispose();
    otherEthnicityController.dispose();
    otherCountryController.dispose();
    otherLanguageController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || birthDate == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseFirestore.instance.collection('soul_members');

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userRegion = userDoc.data()?['region'] ?? '';

    final memberData = {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'mobile': mobileController.text,
      'cityOfBirth': cityOfBirthController.text,
      'job': jobController.text,
      'testimony': testimonyController.text,
      'birthDate': birthDate,
      'country': isOtherCountry
          ? otherCountryController.text
          : (selectedCountry ?? ''),
      'ethnicity': isOtherEthnicity
          ? otherEthnicityController.text
          : (selectedEthnicity ?? ''),
      'maritalStatus': selectedMaritalStatus ?? '',
      'childrenCount': selectedChildrenCount,
      'languages': selectedLanguages.contains('Autre') &&
              otherLanguageController.text.isNotEmpty
          ? selectedLanguages.where((lang) => lang != 'Autre').toList() +
              [otherLanguageController.text]
          : selectedLanguages,
      'createdBy': user.email ?? '',
      'createdByUid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'region': userRegion, // 👈 Région automatiquement ajoutée
    };

    await ref.add(memberData);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Âme enregistrée avec succès.')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une ame'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(firstNameController, 'Prénom'),
              _buildTextField(lastNameController, 'Nom'),
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
                _buildTextField(otherCountryController, 'Précisez votre pays'),
              _buildDropdown(
                'Situation matrimoniale',
                maritalStatusOptions,
                selectedMaritalStatus,
                (val) => setState(() => selectedMaritalStatus = val),
              ),
              _buildDropdown<int>(
                'Nombre d\'enfants',
                childrenCountOptions,
                selectedChildrenCount,
                (val) => setState(() => selectedChildrenCount = val ?? 0),
              ),
              _buildTextField(jobController, 'Profession'),
              _buildTextField(testimonyController, 'Témoignage'),
              const SizedBox(height: 10),
              Text(
                'Date de naissance : ${birthDate?.toLocal().toIso8601String().split("T")[0] ?? 'Non définie'}',
              ),
              TextButton(
                onPressed: _selectDate,
                child: const Text('Choisir une date'),
              ),
              const SizedBox(height: 10),
              const Text('Langues parlées'),
              Column(
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
                        isOtherLanguage = selectedLanguages.contains('Autre');
                      });
                    },
                  );
                }).toList(),
              ),
              if (isOtherLanguage)
                _buildTextField(otherLanguageController, 'Précisez la langue'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
