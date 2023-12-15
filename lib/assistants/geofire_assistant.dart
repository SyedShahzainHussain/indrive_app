import 'package:user_uber_app/model/active_nearby_available_drivers.dart';

class GeoFireAssistant {
  static List<ActiveNearByAvalableDrivers> activeNearByAvailableDriversList =
      [];

  static void removeActiveDriverNearby(String driverId) {
    final removeIndex = activeNearByAvailableDriversList
        .indexWhere((driver) => driver.driverId == driverId);
    activeNearByAvailableDriversList.removeAt(removeIndex);
  }

  static void updateActiveDriverNearby(
      ActiveNearByAvalableDrivers driveWhoMove) {
    final indexNumber = activeNearByAvailableDriversList
        .indexWhere((driver) => driver.driverId == driveWhoMove.driverId);

    activeNearByAvailableDriversList[indexNumber].latitude =
        driveWhoMove.latitude;

    activeNearByAvailableDriversList[indexNumber].longitude =
        driveWhoMove.longitude;

  
  }
}
