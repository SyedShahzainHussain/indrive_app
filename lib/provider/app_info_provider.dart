import 'package:flutter/widgets.dart';
import 'package:user_uber_app/model/directon.dart';

class AppInfo with ChangeNotifier {
  Directions? userPickUpAddress , dropOfPickUpAddress;

  updatePickUpAddressLocation(Directions userPickUpAddress) {
    this.userPickUpAddress = userPickUpAddress;
    notifyListeners();
  }
   updateDropUpAddressLocation(Directions dropOfPickUpAddress) {
    this.dropOfPickUpAddress = dropOfPickUpAddress;
    notifyListeners();
  }
}
