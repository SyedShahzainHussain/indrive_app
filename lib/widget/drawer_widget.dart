import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:user_uber_app/global/global.dart';
import 'package:user_uber_app/resources/app_colors.dart';
import 'package:user_uber_app/resources/routes/routes_name.dart';

class DrawerWidget extends StatefulWidget {
  final String? name, email;
  const DrawerWidget({super.key, this.name, this.email});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.blackColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // drawer header
            Container(
              height: 150,
              color: AppColors.greyColor,
              child: DrawerHeader(
                  decoration: const BoxDecoration(color: AppColors.blackColor),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.greyColor,
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name!,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(
                                      color: AppColors.greyColor,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis),
                            ),
                            const Gap(5),
                            Text(
                              widget.email!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    color: AppColors.greyColor,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            )
                          ],
                        ),
                      )
                    ],
                  )),
            ),
            const Gap(12),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, RouteNames.tripsHistoryScreen);
              },
              leading: const Icon(
                Icons.history,
                color: Colors.white54,
              ),
              title: const Text(
                "History",
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
            const Gap(12),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, RouteNames.profileScreen);
              },
              leading: const Icon(
                Icons.person,
                color: Colors.white54,
              ),
              title: const Text(
                "Profile",
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
            const Gap(12),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, RouteNames.aboutScreen);
              },
              leading: const Icon(
                Icons.info,
                color: Colors.white54,
              ),
              title: const Text(
                "About",
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
            const Gap(12),
            ListTile(
              onTap: () {
                firebaseAuth.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, RouteNames.splashScreen, (route) => false);
              },
              leading: const Icon(
                Icons.logout,
                color: Colors.white54,
              ),
              title: const Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
