import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:user_uber_app/global/global.dart';

class RateDriverScreen extends StatefulWidget {
  final String? assignedDriverId;
  const RateDriverScreen({super.key, this.assignedDriverId});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white60,
        child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
              "Rate Trip Experience",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const Gap(22),
            const Divider(
              height: 4.0,
              thickness: 4.0,
            ),
            const Gap(22.0),
            RatingBar(
                itemCount: 5,
                minRating: 0,
                updateOnDrag: true,
                ratingWidget: RatingWidget(
                    full: const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    half: const Icon(
                      Icons.star_half,
                      color: Colors.amber,
                    ),
                    empty: const Icon(
                      Icons.star_border_purple500_outlined,
                      color: Colors.amber,
                    )),
                onRatingUpdate: (newValue) {
                  countRatingStars = newValue;
                  if (countRatingStars == 1) {
                    setState(() {
                      titleRating = "Very Bad";
                    });
                  }
                  if (countRatingStars == 2) {
                    setState(() {
                      titleRating = "Bad";
                    });
                  }
                  if (countRatingStars == 3) {
                    setState(() {
                      titleRating = "Good";
                    });
                  }
                  if (countRatingStars == 4) {
                    setState(() {
                      titleRating = "Very Good";
                    });
                  }
                  if (countRatingStars == 5) {
                    setState(() {
                      titleRating = "Excellent";
                    });
                  }
                }),
            const Gap(12.0),
            Text(
              titleRating,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(12.0),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  DatabaseReference databaseReference = FirebaseDatabase
                      .instance
                      .ref()
                      .child("drivers")
                      .child(widget.assignedDriverId!)
                      .child("ratings");
                  databaseReference.once().then((value) {
                    if (value.snapshot.value == null) {
                      databaseReference.set(countRatingStars.toString());
                      SystemNavigator.pop();
                    } else {
                      double pastRatings =
                          double.parse(value.snapshot.value.toString());
                      double totalRating = (pastRatings + countRatingStars) / 2;
                      databaseReference.set(totalRating.toString());
                      SystemNavigator.pop();
                    }
                  });
                },
                child: Text(
                  "Submit",
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: Colors.white,
                      ),
                ))
          ]),
        ),
      ),
    );
  }
}
