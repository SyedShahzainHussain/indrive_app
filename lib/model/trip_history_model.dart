import 'package:firebase_database/firebase_database.dart';

class TripHistoryModel {
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? carDetails;
  String? driverName;

  TripHistoryModel({
    this.time,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.fareAmount,
    this.carDetails,
    this.driverName,
  });

  TripHistoryModel.fromSnapSHot(DataSnapshot snapshot) {
    time = (snapshot.value as Map)["time"];
    originAddress = (snapshot.value as Map)["originAddress"];
    destinationAddress = (snapshot.value as Map)["destinationAddress"];
    status = (snapshot.value as Map)["status"];
    fareAmount = (snapshot.value as Map)["fareAmount"];
    carDetails = (snapshot.value as Map)["car_details"];
    driverName = (snapshot.value as Map)["driverName"];
  }
}
