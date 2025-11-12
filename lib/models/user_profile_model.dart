import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String firstName;
  final String lastName;
  final String email;
  final DateTime birthDate;
  final String country;
  final String region;
  final String cityOfBirth;
  final String ethnicity;
  final Map<String, String> contacts;
  final String maritalStatus;
  final int childrenCount;
  final String education;
  final String job;
  final List<String> languages;
  final String testimony;
  final String role;
  final String uid;
  final String createdBy; // Ex. "Assistant générale Atoh Désiré"
  final String createdByUid; // UID technique
  final DateTime? createdAt;

  UserProfileModel({
    this.uid = '',
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.birthDate,
    required this.country,
    required this.region,
    required this.cityOfBirth,
    required this.ethnicity,
    required this.contacts,
    required this.maritalStatus,
    required this.childrenCount,
    required this.education,
    required this.job,
    required this.languages,
    required this.testimony,
    required this.role,
    this.createdBy = '',
    this.createdByUid = '',
    this.createdAt,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map,
      {required String uid}) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return UserProfileModel(
      uid: uid,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      birthDate: parseDate(map['birthDate']) ?? DateTime(2000),
      country: map['country'] ?? '',
      region: map['region'] ?? '',
      cityOfBirth: map['cityOfBirth'] ?? '',
      ethnicity: map['ethnicity'] ?? '',
      contacts: Map<String, String>.from(map['contacts'] ?? {}),
      maritalStatus: map['maritalStatus'] ?? '',
      childrenCount: map['childrenCount'] ?? 0,
      education: map['education'] ?? '',
      job: map['job'] ?? '',
      languages: List<String>.from(map['languages'] ?? []),
      testimony: map['testimony'] ?? '',
      role: map['role'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdByUid: map['createdByUid'] ?? '',
      createdAt: parseDate(map['createdAt']),
    );
  }

  factory UserProfileModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserProfileModel.fromMap(data, uid: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'birthDate': birthDate.toIso8601String(),
      'country': country,
      'region': region,
      'cityOfBirth': cityOfBirth,
      'ethnicity': ethnicity,
      'contacts': contacts,
      'maritalStatus': maritalStatus,
      'childrenCount': childrenCount,
      'education': education,
      'job': job,
      'languages': languages,
      'testimony': testimony,
      'role': role,
      'createdBy': createdBy,
      'createdByUid': createdByUid,
      'createdAt': createdAt,
    };
  }
}
