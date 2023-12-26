import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_uber_app/model/distance_info_model.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? firebasecurrentUser;
List driverslist = [];
DistanceInfoModel? tripDistanceInfoModel;
String? chooseDriverId;
String? destinationAddress;
String? cloudMessagingId =
    "key=AAAA53FNSew:APA91bFjJYzhmYwvc-GI4JA_Q836AyxxTNY4LZckzbI2XxywXsQ1PZ6dg3i4uu4ZXyVM7aOvghrT6dV7URuIgGiJTJMSU5DosFjnaBe40MiJyFvIo8xWjX48yVgKg7w167YrAGcpgk-B";

String? cardetails = "";
String? driverName = "";
String? driverPhone = "";
double countRatingStars = 0.0;
String titleRating = "";
