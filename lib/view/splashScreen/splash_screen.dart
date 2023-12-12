import 'dart:async';

import 'package:flutter/material.dart';
import 'package:user_uber_app/assistants/assistants_method.dart';

// ! file import

import 'package:user_uber_app/extension/screenWidthHeight/mediaquery.dart';
import 'package:user_uber_app/resources/app_colors.dart';

// ! package
import 'package:gap/gap.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:user_uber_app/global/global.dart';
import 'package:user_uber_app/resources/routes/routes_name.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
 @override
void didChangeDependencies() {
  super.didChangeDependencies();
  startTimer();
}

  startTimer() {
    firebaseAuth.currentUser != null
        ? AsistantsMethod.readCurrentOnlineUserInfo(context)
        : null;
    Timer(const Duration(seconds: 3), () async {
      if (firebaseAuth.currentUser != null) {
        firebasecurrentUser = firebaseAuth.currentUser;
        Navigator.pushNamedAndRemoveUntil(
            context, RouteNames.mainScreen, (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, RouteNames.logInScreen, (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.blackColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                "assets/images/logo1.png",
                width: context.screenWidth * .8,
              ),
              const Gap(10),
              Text("Uber & inDriver Clone App",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.bold,
                      )),
              const Spacer(),
              const SpinKitCircle(
                size: 20,
                color: AppColors.whiteColor,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
