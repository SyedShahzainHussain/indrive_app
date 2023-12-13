import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_uber_app/extension/screenWidthHeight/mediaquery.dart';
import 'package:user_uber_app/model/directon.dart';
import 'package:user_uber_app/provider/app_info_provider.dart';
import 'package:user_uber_app/resources/app_colors.dart';
import 'package:user_uber_app/resources/routes/routes_name.dart';

class ChooseLocationFromMap extends StatefulWidget {
  final bool? isPickUp;
  const ChooseLocationFromMap({
    super.key,
    this.isPickUp,
  });

  @override
  State<ChooseLocationFromMap> createState() => _ChooseLocationFromMapState();
}

class _ChooseLocationFromMapState extends State<ChooseLocationFromMap> {
  Completer<GoogleMapController> googleMapController = Completer();
  GoogleMapController? newGoogleMapController;
  LatLng selectedLocation = const LatLng(0, 0);
  Position? userCurrentPosition;
  String address = '';
  void currentPositioned() async {
    Position? positioned = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = positioned;
    newGoogleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
              userCurrentPosition!.latitude, userCurrentPosition!.longitude),
          zoom: 14,
        ),
      ),
    );
  }

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

  @override
  void initState() {
    super.initState();
    currentPositioned();
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          address =
              '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching address: $e');
      }
    }
  }

  Timer? debounceTimer;
  void _onCameraMove(CameraPosition position) {
    // Cancel the previous timer to avoid multiple timer instances
    debounceTimer?.cancel();

    // Start a new timer for 1 second to wait for the user to stop moving the camera
    debounceTimer = Timer(const Duration(seconds: 1), () {
      // Fetch the address for the selected location
      _getAddressFromLatLng(position.target);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: context.screenHeight * .15),
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 15,
            ),
            onCameraMove: _onCameraMove,
            onMapCreated: (GoogleMapController controller) {
              googleMapController.complete(controller);
              newGoogleMapController = controller;
              blackThemeGoogleMap();
              currentPositioned();
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: context.screenWidth * .5,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    color: const Color(0xff7fbefb),
                    borderRadius: BorderRadius.circular(5.0)),
                child: Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff152633),
                      ),
                ),
              ),
              const Gap(10),
              Image.asset(
                "assets/images/map_icon.png",
                width: 50,
                height: 50,
                color: const Color(0xff7fbefb),
              ),
            ],
          ),
          Positioned(
            top: context.screenHeight * .02,
            left: 20,
            child: CircleAvatar(
              backgroundColor: const Color(0xff272c32),
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.whiteColor,
                  )),
            ),
          ),
          Positioned(
              bottom: context.screenHeight * .02,
              child: GestureDetector(
                onTap: address.isEmpty
                    ? null
                    : () {
                        final direction = Directions(
                          locationName: address,
                          
                        );
                        widget.isPickUp!
                            ? context
                                .read<AppInfo>()
                                .updatePickUpAddressLocation(direction)
                            : context
                                .read<AppInfo>()
                                .updateDropUpAddressLocation(direction);
                        Navigator.pushNamedAndRemoveUntil(
                            context, RouteNames.mainScreen, (route) => false);
                      },
                child: Container(
                  width: context.screenWidth * .9,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xff88da09),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    "Done",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: const Color(0xff29363e),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              )),
          Positioned(
            bottom: context.screenHeight * .15,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xff272c32),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: IconButton(
                onPressed: () {
                  currentPositioned();
                },
                icon: const Icon(
                  Icons.send_sharp,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
