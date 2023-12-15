import 'package:firebase_auth/firebase_auth.dart';
import 'package:user_uber_app/model/distance_info_model.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? firebasecurrentUser;
List driverslist = [];
DistanceInfoModel? tripDistanceInfoModel;
