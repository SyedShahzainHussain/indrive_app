import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_uber_app/assistants/request_assistant.dart';
import 'package:user_uber_app/constants/constant.dart';
import 'package:user_uber_app/global/global.dart';
import 'package:user_uber_app/model/directon.dart';
import 'package:user_uber_app/model/distance_info_model.dart';
import 'package:user_uber_app/model/user_model.dart';
import 'package:user_uber_app/provider/app_info_provider.dart';
import 'package:user_uber_app/provider/user_provider.dart';

class AsistantsMethod {
  // ! geocode api
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

// ! get user profile
  static void readCurrentOnlineUserInfo(BuildContext context) async {
    firebasecurrentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(firebasecurrentUser!.uid);
    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        UserModel? users = UserModel.fromJson(snap.snapshot);
        context.read<UserProvider>().setUserModel(users);
      }
    });
  }

// ! Direction api

  static Future<DistanceInfoModel?> obtainedOriginToDestinationDirectionDetails(
    LatLng origin,
    LatLng destination,
  ) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$mapKey";
    var response = await RequestAssistant.receivedRequest(
        urlOriginToDestinationDirectionDetails);
    if (response == "Error Occured, Failed. No Response") {
      return null;
    }
    DistanceInfoModel distanceInfoModel = DistanceInfoModel();
    distanceInfoModel.e_points =
        response['routes'][0]["overview_polyline"]["points"];

    distanceInfoModel.distance_text =
        response['routes'][0]["legs"][0]["distance"]["text"];

    distanceInfoModel.distance_value =
        response['routes'][0]["legs"][0]["distance"]["value"];

    distanceInfoModel.duration_text =
        response['routes'][0]["legs"][0]["duration"]["text"];

    distanceInfoModel.duration_value =
        response['routes'][0]["legs"][0]["duration"]["value"];

    return distanceInfoModel;
  }

// ! calculate the amount fare

  static double calculatetheTotalAmountFareFromOriginToDestination(
      DistanceInfoModel distanceInfoModel) {
    // * per minutes
    double timeTraveledFareAmountPerMinutes =
        (distanceInfoModel.duration_value! / 60) * 0.1;
    // * per distance
    double distanceTravelFareAmountPerKilometer =
        (distanceInfoModel.duration_value! / 1000) * 0.1;

    // * calculate the total fare amount
    double totalFareAmount =
        timeTraveledFareAmountPerMinutes + distanceTravelFareAmountPerKilometer;

    // * calculate the total local amount
    double totalLocalFareAmount = totalFareAmount * 278.60;
    
    // * and return the local fare amount
    return double.parse(totalLocalFareAmount.toStringAsFixed(1));
  }
}
