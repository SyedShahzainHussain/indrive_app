import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:user_uber_app/assistants/assistants_method.dart';
import 'package:user_uber_app/global/global.dart';
import 'package:user_uber_app/main.dart';
import 'package:user_uber_app/resources/app_colors.dart';

class SelectedDriversScreen extends StatefulWidget {
  final DatabaseReference? referenceRideRequest;
  const SelectedDriversScreen({super.key, this.referenceRideRequest});

  @override
  State<SelectedDriversScreen> createState() => _SelectedDriversScreenState();
}

class _SelectedDriversScreenState extends State<SelectedDriversScreen> {
  String fareAmount = "";

  // ! getfareamountvechiletype

  getfareAmountAccordingToVechileType(int index) {
    if (tripDistanceInfoModel != null) {
      if (driverslist[index]["car_details"]["type"] == "bikes") {
        fareAmount =
            (AsistantsMethod.calculatetheTotalAmountFareFromOriginToDestination(
                        tripDistanceInfoModel!) /
                    2)
                .toStringAsFixed(1);
      }

      if (driverslist[index]["car_details"]["type"] == "uber-x") {
        fareAmount =
            (AsistantsMethod.calculatetheTotalAmountFareFromOriginToDestination(
                        tripDistanceInfoModel!) *
                    2)
                .toStringAsFixed(1);
      }
      if (driverslist[index]["car_details"]["type"] == "uber-go") {
        fareAmount =
            (AsistantsMethod.calculatetheTotalAmountFareFromOriginToDestination(
                    tripDistanceInfoModel!))
                .toStringAsFixed(1);
      }
    }
    return fareAmount;
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        title: const Text(
          "Nearest Online Drivers",
          style: TextStyle(
            color: AppColors.whiteColor,
          ),
        ),
        backgroundColor: Colors.white54,
        leading: IconButton(
            onPressed: () async {
              await widget.referenceRideRequest!.remove().then((value) {
                return MyApp.restartApp(context);
              });
            },
            icon: const Icon(Icons.close, color: AppColors.whiteColor)),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                chooseDriverId = driverslist[index]["id"];
              });
              Navigator.pop(context, "driverChoosed");
            },
            child: Card(
              color: Colors.grey,
              elevation: 3,
              shadowColor: Colors.green,
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Image.asset(
                    "assets/images/${driverslist[index]["car_details"]["type"]}.png",
                    width: 70,
                  ),
                ),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      driverslist[index]["name"],
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      driverslist[index]["car_details"]["car_model"],
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                    RatingBar(
                      onRatingUpdate: (rating) {},
                      initialRating: 3.75,
                      ratingWidget: RatingWidget(
                        full: const Icon(
                          Icons.star,
                          color: Colors.black,
                        ),
                        half: const Icon(
                          Icons.star,
                          color: Colors.black,
                        ),
                        empty: const Icon(
                          Icons.star,
                          color: Colors.black,
                        ),
                      ),
                      itemCount: 5,
                      itemSize: 15.0,
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "\$ ${getfareAmountAccordingToVechileType(index)}",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                    ),
                    const Gap(2),
                    Text(
                      tripDistanceInfoModel != null
                          ? tripDistanceInfoModel!.distance_text!
                          : "",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const Gap(2),
                    Text(
                      tripDistanceInfoModel != null
                          ? tripDistanceInfoModel!.duration_text!
                          : "",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        itemCount: driverslist.length,
      ),
    );
  }
}
