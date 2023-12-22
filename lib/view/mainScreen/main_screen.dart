import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_uber_app/assistants/assistants_method.dart';
import 'package:user_uber_app/assistants/geofire_assistant.dart';
import 'package:user_uber_app/extension/screenWidthHeight/mediaquery.dart';
import 'package:user_uber_app/global/global.dart';
import 'package:user_uber_app/main.dart';
import 'package:user_uber_app/model/active_nearby_available_drivers.dart';
import 'package:user_uber_app/provider/app_info_provider.dart';
import 'package:user_uber_app/provider/user_provider.dart';
import 'package:user_uber_app/resources/app_colors.dart';
import 'package:user_uber_app/resources/routes/routes_name.dart';
import 'package:user_uber_app/widget/dragagble_sheet.dart';
import 'package:user_uber_app/widget/drawer_widget.dart';
import 'package:user_uber_app/widget/progress_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // ! map controllers 
  final Completer<GoogleMapController> _googleMapController = Completer();
  GoogleMapController? newGoogleMapController;
  // ! scaffold state 
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  var geolocator = Geolocator();
  LocationPermission? _locationPermission;
  Position? userCurrentPosition;
  // ! points
  List<LatLng> points = [];
  Set<Polyline> pLineCordinates = {};
  // ! markers
  Set<Marker> marker = {};
  // ! circle
  Set<Circle> circle = {};

  bool openNavigationDrawer = true;
  bool activeNearByDriverKeyLoaded = false;
  BitmapDescriptor? activeNearbyIcon;
  List<ActiveNearByAvalableDrivers> onlineNearbyDrivers = [];
  DatabaseReference? referenceRideRequest;

  // ! initial camereposition

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowes();
  }

  @override
  Widget build(BuildContext context) {
    createActiveNearbyAssesImage();
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      key: sKey,
      // * drawer widget
      drawer: Consumer<UserProvider>(
        builder: (context, value, _) => SizedBox(
          width: context.screenWidth * .6,
          child: DrawerWidget(
            name: value.user!.name,
            email: value.user!.email,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // * Google Map
            GoogleMap(
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              mapType: MapType.normal,
              markers: marker,
              circles: circle,
              initialCameraPosition: _kGooglePlex,
              polylines: pLineCordinates,
              onMapCreated: (GoogleMapController controller) {
                _googleMapController.complete(controller);
                newGoogleMapController = controller;
                blackThemeGoogleMap();
                locateUserPositioned();

                // * getting the user profile data
                firebaseAuth.currentUser != null
                    ? AsistantsMethod.readCurrentOnlineUserInfo(context)
                    : null;
              },
            ),
            // * custom hamburger button for menu
            Positioned(
              top: context.screenHeight * .02,
              left: 20,
              child: CircleAvatar(
                backgroundColor: AppColors.greyColor,
                child: IconButton(
                    onPressed: () {
                      if (openNavigationDrawer) {
                        sKey.currentState!.openDrawer();
                      } else {
                        SystemNavigator.pop();
                      }
                    },
                    icon: Icon(
                      openNavigationDrawer ? Icons.menu : Icons.close,
                      color: AppColors.blackColor,
                    )),
              ),
            )
            // * ui for searching locations
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    child: Column(children: [
                      InkWell(
                        onTap: () async {
                          var result =
                              await BottomDraggableSheet().show(context, true);
                          if (result != null) {
                            setState(() {
                              openNavigationDrawer = false;
                            });
                            await drawPolyline();
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
                                      builder: (context, value, _) =>
                                          value.userPickUpAddress != null
                                              ? Text(
                                                  value.userPickUpAddress!
                                                      .locationName
                                                      .toString(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium!
                                                      .copyWith(
                                                          color: AppColors
                                                              .greyColor,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                )
                                              : Text(
                                                  "your current location",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium!
                                                      .copyWith(
                                                          color: AppColors
                                                              .greyColor,
                                                          overflow: TextOverflow
                                                              .ellipsis),
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
                            setState(() {
                              openNavigationDrawer = false;
                            });
                            await drawPolyline();

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
                          onPressed: () {
                            if (context.read<AppInfo>().dropOfPickUpAddress ==
                                    null ||
                                context.read<AppInfo>().userPickUpAddress ==
                                    null) {
                              Fluttertoast.showToast(
                                  msg: "Please selected location");
                            } else {
                              saveRideRequestInformation();
                            }
                          },
                          child: Text(
                            "Request a Ride",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
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
      ),
    );
  }

  // ! black theme in google map

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

  // ! save ride information

  void saveRideRequestInformation() {
    // ! save the ride request

    referenceRideRequest =
        FirebaseDatabase.instance.ref().child("All Ride Request").push();

    var originLocation = context.read<AppInfo>().userPickUpAddress;
    var pickUpLocation = context.read<AppInfo>().dropOfPickUpAddress;

    Map originMapLocation = {
      "latitude": originLocation!.locationLatitude,
      "longitude": originLocation.locationLongitude
    };
    Map destinationMapLocation = {
      "latitude": pickUpLocation!.locationLatitude,
      "longitude": pickUpLocation.locationLongitude
    };

    Map userInformaionMap = {
      "origin": originMapLocation,
      "destination": destinationMapLocation,
      "time": DateTime.now().toString(),
      "userName": context.read<UserProvider>().user!.name,
      "userPhone": context.read<UserProvider>().user!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": pickUpLocation.locationName,
      "driverId": "waiting",
    };

    referenceRideRequest!.set(userInformaionMap);

    onlineNearbyDrivers = GeoFireAssistant.activeNearByAvailableDriversList;
    searchNeariestDriver();
  }

  // ! search nearest drivers

  searchNeariestDriver() async {
    if (onlineNearbyDrivers.isEmpty) {
      referenceRideRequest!.remove();

      setState(() {
        marker.clear();
        circle.clear();
        points.clear();
        pLineCordinates.clear();
      });

      await Fluttertoast.showToast(msg: "No Online drivers are available")
          .then((value) {
        context.read<AppInfo>().dropOfPickUpAddress = null;

        return MyApp.restartApp(context);
      });

      return;
    }
    return await reteriveOnlineDriver(onlineNearbyDrivers);
  }

  // ! reteriveOnlinedriver

  Future<void> reteriveOnlineDriver(List onlinesNearbyDrivers) async {
    DatabaseReference databaseReference =
        FirebaseDatabase.instance.ref().child("drivers");
    for (int i = 0; i < onlinesNearbyDrivers.length; i++) {
      await databaseReference
          .child(onlinesNearbyDrivers[i].driverId.toString())
          .once()
          .then((datasnapshot) async {
        var driverInfo = datasnapshot.snapshot.value;
        driverslist.clear();
        driverslist.add(driverInfo);
        var response = await Navigator.pushNamed(
            context, RouteNames.selectedDriver,
            arguments: referenceRideRequest);
        if (response == "driverChoosed") {
          FirebaseDatabase.instance
              .ref()
              .child("drivers")
              .child(chooseDriverId!)
              .once()
              .then((snapshot) {
            if (snapshot.snapshot.value != null) {
              sendNotificationToDriver(chooseDriverId!);
            }
          });
        } else {
          Fluttertoast.showToast(msg: "This driver do not exists. Try again.");
        }
      });
    }
  }

  // ! send notification to driver

  sendNotificationToDriver(String chooseDriver) {
    // * saving the rider request id
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(chooseDriver)
        .child("newRideStatus")
        .set(referenceRideRequest!.key);
  }

  // ! user current location

  void locateUserPositioned() async {
    Position cPositioned = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPositioned;
    LatLng latLngPositioned = LatLng(
      userCurrentPosition!.latitude,
      userCurrentPosition!.longitude,
    );

    newGoogleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLngPositioned,
          zoom: 14,
        ),
      ),
    );

    // * get the formatted address 
    // ignore: use_build_context_synchronously
    await AsistantsMethod.searchAddressFromLangitudeandLatitude(
        userCurrentPosition!, context);

    getDriverLiveLocation();
  }

  // ! user location permission

  void checkIfLocationPermissionAllowes() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  // ! drawe polyline

  Future<void> drawPolyline() async {
    var originPositioned = context.read<AppInfo>().userPickUpAddress!;
    var destinationPositioned = context.read<AppInfo>().dropOfPickUpAddress!;

    var origindestination = LatLng(originPositioned.locationLatitude!,
        originPositioned.locationLongitude!);
    var destinationLatLng = LatLng(destinationPositioned.locationLatitude!,
        destinationPositioned.locationLongitude!);
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait...",
            ));
    var directionDetailInfo =
        await AsistantsMethod.obtainedOriginToDestinationDirectionDetails(
      origindestination,
      destinationLatLng,
    );
    setState(() {
      tripDistanceInfoModel = directionDetailInfo;
    });
    Navigator.pop(context);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePpointsResult =
        polylinePoints.decodePolyline(directionDetailInfo!.e_points!);

    points.clear();
    if (decodePpointsResult.isNotEmpty) {
      for (var position in decodePpointsResult) {
        points.add(LatLng(position.latitude, position.longitude));
      }
    }
    pLineCordinates.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("PolylineId"),
        points: points,
        color: const Color(0xff7fbefb),
        geodesic: true,
        jointType: JointType.round,
        width: 2,
        endCap: Cap.roundCap,
        startCap: Cap.roundCap,
      );
      pLineCordinates.add(polyline);
    });
    LatLngBounds latLngBounds;
    if (origindestination.latitude > destinationLatLng.latitude &&
        origindestination.longitude > destinationLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest: destinationLatLng,
        northeast: origindestination,
      );
    } else if (origindestination.latitude > destinationLatLng.latitude) {
      latLngBounds = LatLngBounds(
        southwest:
            LatLng(destinationLatLng.latitude, origindestination.longitude),
        northeast:
            LatLng(origindestination.latitude, destinationLatLng.longitude),
      );
    } else if (origindestination.longitude > destinationLatLng.longitude) {
      latLngBounds = LatLngBounds(
        southwest:
            LatLng(origindestination.latitude, destinationLatLng.longitude),
        northeast:
            LatLng(destinationLatLng.latitude, origindestination.longitude),
      );
    } else {
      latLngBounds = LatLngBounds(
        southwest: origindestination,
        northeast: destinationLatLng,
      );
    }
    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(
      latLngBounds,
      100,
    ));

    Marker originMarker = Marker(
        markerId: const MarkerId("originMarker"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: origindestination,
        infoWindow: InfoWindow(
            title: originPositioned.locationName, snippet: "Origin"));

    Marker destinationMarker = Marker(
        markerId: const MarkerId("destinationMarker"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: destinationLatLng,
        infoWindow: InfoWindow(
            title: destinationPositioned.locationName, snippet: "Destination"));

    setState(() {
      marker.add(originMarker);
      marker.add(destinationMarker);
    });

    Circle orginCircle = Circle(
      circleId: const CircleId("originCircle"),
      center: origindestination,
      radius: 18,
      strokeWidth: 2,
      strokeColor: AppColors.whiteColor,
      fillColor: const Color(0xff7fbefb),
    );
    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationCircle"),
      center: destinationLatLng,
      radius: 18,
      strokeWidth: 2,
      strokeColor: AppColors.whiteColor,
      fillColor: const Color(0xff7fbefb),
    );

    setState(() {
      circle.add(orginCircle);
      circle.add(destinationCircle);
    });
  }

  // ! get driver live location
  void getDriverLiveLocation() {
    Geofire.initialize("activeDrivers");
    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered: // ! check when the drivers is online
            ActiveNearByAvalableDrivers activeNearByAvalableDrivers =
                ActiveNearByAvalableDrivers();

            activeNearByAvalableDrivers.latitude = map['latitude'];
            activeNearByAvalableDrivers.longitude = map['longitude'];
            activeNearByAvalableDrivers.driverId = map['key'];
            GeoFireAssistant.activeNearByAvailableDriversList.clear();
            GeoFireAssistant.activeNearByAvailableDriversList
                .add(activeNearByAvalableDrivers);
            if (activeNearByDriverKeyLoaded == true) {
              displayActiveDriversOnUserApp();
            }

            break;
          // ! whenever any driver become none active
          case Geofire.onKeyExited:
            GeoFireAssistant.removeActiveDriverNearby(map['key']);
            displayActiveDriversOnUserApp();
            break;
          // ! whenever driver move
          case Geofire.onKeyMoved:
            ActiveNearByAvalableDrivers activeNearByAvalableDrivers =
                ActiveNearByAvalableDrivers();

            activeNearByAvalableDrivers.driverId = map['key'];
            activeNearByAvalableDrivers.latitude = map['latitude'];
            activeNearByAvalableDrivers.longitude = map['longitude'];
            GeoFireAssistant.updateActiveDriverNearby(
                activeNearByAvalableDrivers);
            displayActiveDriversOnUserApp();
            break;

          case Geofire.onGeoQueryReady:
          // ! when driver is ready to go 
            activeNearByDriverKeyLoaded = true;
            displayActiveDriversOnUserApp();
            break;
        }
      }

      setState(() {});
    });
  }

  // ! display active drivers on map
  Future<void> displayActiveDriversOnUserApp() async {
    setState(() {
      Set<Marker> driversMarkerSet = Set<Marker>();

      for (ActiveNearByAvalableDrivers activeNearByAvalableDrivers
          in GeoFireAssistant.activeNearByAvailableDriversList) {
        final LatLng eachDriveLatLng = LatLng(
          activeNearByAvalableDrivers.latitude!,
          activeNearByAvalableDrivers.longitude!,
        );

        Marker markers = Marker(
          markerId: MarkerId(activeNearByAvalableDrivers.driverId!),
          position: eachDriveLatLng,
          rotation: 360,
          icon: activeNearbyIcon!,
        );
        driversMarkerSet.add(markers);
      }
      setState(() {
        marker = driversMarkerSet;
      });
    });
  }

  // ! create assets image
  void createActiveNearbyAssesImage() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/car.png")
          .then((value) {
        activeNearbyIcon = value;
      });
    }
  }
}
