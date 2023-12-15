import 'package:flutter/material.dart';
import 'package:user_uber_app/resources/routes/routes_name.dart';
import 'package:user_uber_app/view/chosse_location_from_map/choose_location_from_map.dart';
import 'package:user_uber_app/view/loginScreen/login_screen.dart';
import 'package:user_uber_app/view/mainScreen/main_screen.dart';
import 'package:user_uber_app/view/selected_drivers_screen/selected_drivers_screen.dart';
import 'package:user_uber_app/view/signUpScreen/sign_up_screen.dart';
import 'package:user_uber_app/view/splashScreen/splash_screen.dart';

class Routes {
  static Route<dynamic> generatesRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splashScreen:
        return MaterialPageRoute(builder: (context) => const MySplashScreen());
      case RouteNames.mainScreen:
        return MaterialPageRoute(builder: (context) => const MainScreen());
      case RouteNames.signupScreen:
        return MaterialPageRoute(
          builder: (context) => const SignupScreen(),
        );

      case RouteNames.logInScreen:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      case RouteNames.chooseLocation:
        final bool isPickUp = settings.arguments as bool;
        return MaterialPageRoute(
          builder: (context) => ChooseLocationFromMap(isPickUp: isPickUp),
        );
      case RouteNames.selectedDriver:
        return MaterialPageRoute(
          builder: (context) =>  const  SelectedDriversScreen(),
        );
      default:
        return MaterialPageRoute(builder: (ctx) {
          return const Scaffold(
            body: Center(
              child: Text('No route defined'),
            ),
          );
        });
    }
  }
}
