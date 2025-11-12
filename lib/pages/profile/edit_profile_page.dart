import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';
import 'package:flareline/models/user_profile_model.dart';
import 'package:flareline/services/user_profile_service.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends LayoutWidget {
  const EditProfilePage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return AppLocalizations.of(context)!.profile;
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return const _ProfileForm();
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm();

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _villeNaissanceController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _emailController = TextEditingController();
  final _departementController = TextEditingController();
  final _quartierController = TextEditingController();
  final _villeResidenceController = TextEditingController();
  final _formationController = TextEditingController();
  final _professionController = TextEditingController();
  final _temoignageController = TextEditingController();

  // Dropdown values
  String? _pays;
  String? _region;
  String? _ethnie;
  String? _situation;
  String? _nbEnfants;
  final List<String> _langues = [];

  final List<String> _langueOptions = [
    'Français',
    'Anglais',
    'Fulfulde',
    'Beti',
    'Arabe'
  ];

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
    );
    if (date != null) {
      _birthDateController.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfileModel(
      firstName: _prenomController.text,
      lastName: _nomController.text,
      email: _emailController.text,
      birthDate: DateTime.tryParse(_birthDateController.text) ?? DateTime(2000),
      country: _pays ?? '',
      region: _region ?? '',
      cityOfBirth: _villeNaissanceController.text,
      ethnicity: _ethnie ?? '',
      contacts: {
        'mobile': _telephoneController.text,
        'whatsapp': _whatsappController.text,
        'facebook': _facebookController.text,
        'instagram': _instagramController.text,
        'email': _emailController.text,
      },
      maritalStatus: _situation ?? '',
      childrenCount: int.tryParse(_nbEnfants ?? '0') ?? 0,
      education: _formationController.text,
      job: _professionController.text,
      languages: _langues,
      testimony: _temoignageController.text,
      role: 'admin', // ou tout autre rôle souhaité
    );

    await UserProfileService().updateUserProfile(profile);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil enregistré avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: CommonCard(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Informations personnelles',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Wrap(
                  runSpacing: 16,
                  spacing: 16,
                  children: [
                    _buildTextField('Nom', _nomController),
                    _buildTextField('Prénom', _prenomController),
                    _buildDateField('Date de naissance', _birthDateController),
                    _buildDropdown(
                        'Pays de résidence',
                        ['Cameroun', 'Tchad', 'Sénégal'],
                        _pays,
                        (v) => setState(() => _pays = v)),
                    _buildDropdown(
                        'Région de résidence',
                        ['Centre', 'Littoral', 'Nord-Ouest'],
                        _region,
                        (v) => setState(() => _region = v)),
                    _buildTextField(
                        'Ville de naissance', _villeNaissanceController),
                    _buildDropdown('Ethnie', ['Bamiléké', 'Bassa', 'Fang'],
                        _ethnie, (v) => setState(() => _ethnie = v)),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Contacts',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Wrap(
                  runSpacing: 16,
                  spacing: 16,
                  children: [
                    _buildTextField('Téléphone mobile', _telephoneController),
                    _buildTextField('Numéro WhatsApp', _whatsappController),
                    _buildTextField('Facebook', _facebookController),
                    _buildTextField('Instagram', _instagramController),
                    _buildTextField('Adresse Email', _emailController),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Situation et résidence',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Wrap(
                  runSpacing: 16,
                  spacing: 16,
                  children: [
                    _buildDropdown(
                        'Situation matrimoniale',
                        ['Célibataire', 'Marié(e)', 'Divorcé(e)'],
                        _situation,
                        (v) => setState(() => _situation = v)),
                    _buildDropdown('Nombre enfants', ['0', '1', '2', '3', '4+'],
                        _nbEnfants, (v) => setState(() => _nbEnfants = v)),
                    _buildTextField(
                        'Département régional', _departementController),
                    _buildTextField('Quartier', _quartierController),
                    _buildTextField(
                        'Ville de résidence', _villeResidenceController),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Profession et compétences',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Wrap(
                  runSpacing: 16,
                  spacing: 16,
                  children: [
                    _buildTextField(
                        'Formation professionnelle', _formationController),
                    _buildTextField(
                        'Profession actuelle', _professionController),
                    _buildMultiSelectField('Langues parlées', _langueOptions),
                  ],
                ),
                const SizedBox(height: 32),
                Text('Témoignage',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _temoignageController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Votre témoignage',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save),
                    label: const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _pickDate(context),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value,
      ValueChanged<String?> onChanged) {
    return SizedBox(
      width: 300,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
      ),
    );
  }

  Widget _buildMultiSelectField(String label, List<String> options) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Wrap(
            spacing: 8,
            children: options.map((lang) {
              final selected = _langues.contains(lang);
              return FilterChip(
                label: Text(lang),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _langues.add(lang);
                    } else {
                      _langues.remove(lang);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
