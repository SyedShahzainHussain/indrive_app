
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:user_uber_app/assistants/request_assistant.dart';
import 'package:user_uber_app/constants/constant.dart';
import 'package:user_uber_app/global/global.dart';
import 'package:user_uber_app/model/directon.dart';
import 'package:user_uber_app/model/user_model.dart';
import 'package:user_uber_app/provider/app_info_provider.dart';
import 'package:user_uber_app/provider/user_provider.dart';

class AsistantsMethod {
  static Future<String> searchAddressFromLangitudeandLatitude(
      Position position, BuildContext context) async {
    String humanReadableAddress = "";
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    var requestResponse = await RequestAssistant.receivedRequest(apiUrl);
    if (requestResponse != "Error Occured, Failed. No Response") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];
      Directions userPickUpaddress = Directions();

      userPickUpaddress.locationLatitude = position.latitude;
      userPickUpaddress.locationLongitude = position.longitude;
      userPickUpaddress.locationName = humanReadableAddress;
      // ignore: use_build_context_synchronously
      context.read<AppInfo>().updatePickUpAddressLocation(userPickUpaddress);
    }
    return humanReadableAddress;
  }

  static void readCurrentOnlineUserInfo(BuildContext context) async {
    firebasecurrentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(firebasecurrentUser!.uid);
    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        UserModel users = UserModel.fromJson(snap.snapshot);
        context.read<UserProvider>().setUserModel(users);
      }
    });
  }
}
