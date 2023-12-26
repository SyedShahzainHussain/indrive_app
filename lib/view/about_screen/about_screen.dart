import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "About Screen",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
        body: ListView(
          children: [
            // * image
            SizedBox(
              height: 230,
              child: Center(
                child: Image.asset(
                  "assets/images/car_logo.png",
                  width: 50,
                ),
              ),
            ),

            // * company name
            Column(
              children: [
                Text("Uber & inDriver Clone",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white54, fontWeight: FontWeight.bold)),
                const Gap(10),
                // * about you & your company - write some info
                Text(
                  "This app has been developed by Syed Shahzain Hussain",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Colors.white54,
                      ),
                ),
              ],
            ),
            const Gap(10),

            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text(
                    "Close",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
