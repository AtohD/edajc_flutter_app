import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/flutter_gen/app_localizations.dart';
import 'package:flareline/models/user_profile_model.dart';
import 'package:flareline/services/user_profile_service.dart';
import 'package:flareline/pages/profile/edit_profile_page.dart';

class ProfilePage extends LayoutWidget {
  const ProfilePage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return AppLocalizations.of(context)!.profile;
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return FutureBuilder<UserProfileModel?>(
      future: UserProfileService().getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
              child: Text("Aucune donnée de profil disponible."));
        }

        final profile = snapshot.data!;

        return CommonCard(
          margin: EdgeInsets.zero,
          child: Stack(children: [
            SizedBox(
              height: 280,
              child: Stack(children: [
                Image.asset(
                  'assets/cover/cover-01.png',
                  height: 280,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    color: Colors.blueAccent,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ]),
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 230),
                  SizedBox(
                    width: 144,
                    height: 144,
                    child: Stack(children: [
                      CircleAvatar(
                        radius: 72,
                        backgroundColor: Colors.greenAccent,
                        child: Image.asset('assets/user/user-01.png'),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          alignment: Alignment.center,
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(45),
                          ),
                          margin: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.camera_enhance,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      )
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Text('${profile.firstName} ${profile.lastName}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(profile.job, style: const TextStyle(fontSize: 10)),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildItem(
                            "Date de naissance",
                            profile.birthDate
                                .toLocal()
                                .toString()
                                .split(' ')[0]),
                        _buildItem("Pays", profile.country),
                        _buildItem("Région", profile.region),
                        _buildItem("Ville de naissance", profile.cityOfBirth),
                        _buildItem("Ethnie", profile.ethnicity),
                        _buildItem("Mobile", profile.contacts['mobile'] ?? ''),
                        _buildItem(
                            "WhatsApp", profile.contacts['whatsapp'] ?? ''),
                        _buildItem(
                            "Facebook", profile.contacts['facebook'] ?? ''),
                        _buildItem(
                            "Instagram", profile.contacts['instagram'] ?? ''),
                        _buildItem("Email", profile.contacts['email'] ?? ''),
                        _buildItem(
                            "Situation matrimoniale", profile.maritalStatus),
                        _buildItem("Nombre d'enfants",
                            profile.childrenCount.toString()),
                        _buildItem("Formation", profile.education),
                        _buildItem(
                            "Langues parlées", profile.languages.join(', ')),
                        _buildItem("Témoignage", profile.testimony),
                        _buildItem("Rôle", profile.role),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Modifier le profil"),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            )
          ]),
        );
      },
    );
  }

  Widget _buildItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label : ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
