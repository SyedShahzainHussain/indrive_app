import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_uber_app/assistants/assistants_method.dart';
import 'package:user_uber_app/extension/screenWidthHeight/mediaquery.dart';
import 'package:user_uber_app/provider/app_info_provider.dart';
import 'package:user_uber_app/provider/user_provider.dart';
import 'package:user_uber_app/resources/app_colors.dart';
import 'package:user_uber_app/widget/dragagble_sheet.dart';
import 'package:user_uber_app/widget/drawer_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<GoogleMapController> _googleMapController = Completer();
  GoogleMapController? newGoogleMapController;
  Position? userCurrentPosition;
  var geolocator = Geolocator();
  LocationPermission? _locationPermission;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  void blackThemeGoogleMap() {
    newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  void locateUserPositioned() async {
    Position cPositioned = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPositioned;
    LatLng latLngPositioned =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    newGoogleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLngPositioned, zoom: 14),
      ),
    );

    // ignore: use_build_context_synchronously
    await AsistantsMethod.searchAddressFromLangitudeandLatitude(
        userCurrentPosition!, context);
  }

  void checkIfLocationPermissionAllowes() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      key: sKey,
      drawer: Consumer<UserProvider>(
        builder: (context, value, _) => SizedBox(
          width: context.screenWidth * .6,
          child: DrawerWidget(
            name: value.user?.name ?? "Loading...",
            email: value.user?.email ?? "Loading...",
          ),
        ),
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            padding: EdgeInsets.only(
              top: context.screenHeight * .05,
            ),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _googleMapController.complete(controller);
              newGoogleMapController = controller;
              blackThemeGoogleMap();
              if (context.read<AppInfo>().userPickUpAddress == null) {
                locateUserPositioned();
              }
            },
          ),
          // custom hamburger button for menu
          Positioned(
            top: context.screenHeight * .05,
            left: 20,
            child: CircleAvatar(
              backgroundColor: AppColors.greyColor,
              child: IconButton(
                  onPressed: () {
                    sKey.currentState!.openDrawer();
                  },
                  icon: const Icon(
                    Icons.menu,
                    color: AppColors.blackColor,
                  )),
            ),
          )
          // ui for searching locations
          ,
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 120),
              curve: Curves.bounceIn,
              child: Container(
                height: context.screenHeight * .3,
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(22.0),
                    topLeft: Radius.circular(22.0),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(children: [
                    InkWell(
                      onTap: () async {
                        var result =
                            await BottomDraggableSheet().show(context, true);
                        if (result != null) {
                          if (kDebugMode) {
                            print("pop");
                          }
                        } else {
                          if (kDebugMode) {
                            print("not pop");
                          }
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_location_alt_outlined,
                            color: AppColors.greyColor,
                          ),
                          const Gap(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "From",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(
                                        color: AppColors.greyColor,
                                      ),
                                ),
                                Consumer<AppInfo>(
                                    builder: (context, value, _) => value
                                                .userPickUpAddress !=
                                            null
                                        ? Text(
                                            value
                                                .userPickUpAddress!.locationName
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium!
                                                .copyWith(
                                                    color: AppColors.greyColor,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                          )
                                        : Text(
                                            "your current location",
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium!
                                                .copyWith(
                                                    color: AppColors.greyColor,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                          )),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const Gap(10),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.greyColor,
                    ),
                    const Gap(16),
                    InkWell(
                      onTap: () async {
                        var result =
                            await BottomDraggableSheet().show(context, false);
                        if (result != null) {
                          if (kDebugMode) {
                            print("pop");
                          }
                        } else {
                          if (kDebugMode) {
                            print("not pop");
                          }
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_location_alt_outlined,
                            color: AppColors.greyColor,
                          ),
                          const Gap(16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "To",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(
                                        color: AppColors.greyColor,
                                      ),
                                ),
                                Consumer<AppInfo>(
                                  builder: (context, value, _) => value
                                              .dropOfPickUpAddress !=
                                          null
                                      ? Text(
                                          value.dropOfPickUpAddress!
                                              .locationName!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .copyWith(
                                                  color: AppColors.greyColor,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                        )
                                      : Text(
                                          "where to go?",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .copyWith(
                                                  color: AppColors.greyColor,
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                        ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const Gap(10),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.greyColor,
                    ),
                    const Gap(16),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0))),
                        onPressed: () {},
                        child: Text(
                          "Request a Ride",
                          style:
                              Theme.of(context).textTheme.labelMedium!.copyWith(
                                    color: AppColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ))
                  ]),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
