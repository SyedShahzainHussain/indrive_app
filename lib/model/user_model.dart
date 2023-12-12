import 'package:firebase_database/firebase_database.dart';

class UserModel {
  String? id;
  String? email;
  String? name;
  String? phone;

  UserModel({this.id, this.email, this.name, this.phone});

  UserModel.fromJson(DataSnapshot snap) {
    id = snap.key;
    email = (snap.value as dynamic)["email"];
    name = (snap.value as dynamic)["name"];
    phone = (snap.value as dynamic)["phone"];
  }
}
