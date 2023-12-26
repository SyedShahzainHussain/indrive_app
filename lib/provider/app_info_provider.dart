import 'package:flutter/widgets.dart';
import 'package:user_uber_app/model/directon.dart';
import 'package:user_uber_app/model/trip_history_model.dart';

class AppInfo with ChangeNotifier {
  Directions? userPickUpAddress, dropOfPickUpAddress;
  int countTotalTrip = 0;
  List<String> tripKey = [];
  List<TripHistoryModel> tripHistory = [];
  updatePickUpAddressLocation(Directions userPickUpAddress) {
    this.userPickUpAddress = userPickUpAddress;
    notifyListeners();
  }

  updateDropUpAddressLocation(Directions dropOfPickUpAddress) {
    this.dropOfPickUpAddress = dropOfPickUpAddress;
    notifyListeners();
  }

  updateCountTrip(int overAllTrip) {
    countTotalTrip = overAllTrip;
    notifyListeners();
  }

  updateAllOverUpdateTrip(List<String> tripKey) {
    this.tripKey = tripKey;
    notifyListeners();
  }

  updateAllOverUpdateTripInformation(TripHistoryModel tripHistoryModel) {
    tripHistory.add(tripHistoryModel);
    notifyListeners();
  }
}
