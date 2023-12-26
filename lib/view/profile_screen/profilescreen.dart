import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:user_uber_app/provider/user_provider.dart';
import 'package:user_uber_app/widget/info_design_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final data = context.read<UserProvider>();
    return Scaffold(
      
        appBar: AppBar(
           backgroundColor: Colors.black,
           iconTheme:const  IconThemeData(color: Colors.white),
          title: const Text(
            "Profile Screen",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // * name
            Text(
              data.user!.name!,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.white,
                thickness: 2,
                height: 2,
              ),
            ),
            const Gap(38),
            // * phone
            DesignInfoWidget(
              title: data.user!.phone!,
              iconData: Icons.phone_iphone,
            ),

            // * email
            DesignInfoWidget(
              title: data.user!.email!,
              iconData: Icons.email,
            ),

            Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Text("Close",
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: Colors.white,
                          ))),
            )
          ],
        )));
  }
}
