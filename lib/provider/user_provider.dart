import 'package:flutter/widgets.dart';
import 'package:user_uber_app/model/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _userModel;

  UserModel? get user => _userModel;

  setUserModel(UserModel users) {
    _userModel = users;
    notifyListeners();
  }
}
