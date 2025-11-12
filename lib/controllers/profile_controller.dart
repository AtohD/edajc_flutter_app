import 'package:get/get.dart';
import '../models/user_profile_model.dart';

class ProfileController extends GetxController {
  var profile = Rxn<UserProfileModel>();

  void setProfile(UserProfileModel newProfile) {
    profile.value = newProfile;
  }
}
