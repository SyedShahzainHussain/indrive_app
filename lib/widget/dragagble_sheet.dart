import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:user_uber_app/assistants/request_assistant.dart';
import 'package:user_uber_app/constants/constant.dart';
import 'package:user_uber_app/extension/screenWidthHeight/mediaquery.dart';
import 'package:user_uber_app/model/predicted_places.dart';
import 'package:user_uber_app/widget/place_prediction_tile.dart';

class BottomDraggableSheet extends StatefulWidget {
  final bool? isPickUp;
  const BottomDraggableSheet({
    super.key,
    this.isPickUp,
  });

  Future<dynamic> show(BuildContext context, bool isPickUp) async {
    return await showModalBottomSheet(
      backgroundColor: const Color(0xff1c1f24),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
            initialChildSize: 0.9,
            expand: false,
            builder:
                (BuildContext context, ScrollController scrollController) =>
                    SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        controller: scrollController,
                        child: BottomDraggableSheet(
                          isPickUp: isPickUp,
                        )));
      },
    );
  }

  @override
  State<BottomDraggableSheet> createState() => _BottomDraggableSheetState();
}

class _BottomDraggableSheetState extends State<BottomDraggableSheet> {
  TextEditingController mapControllerText = TextEditingController();
  late FocusNode _focusNode;
  List<PredictedPlace> placePredicted = [];
  
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

// ! places Api
  Future<List<PredictedPlace>> findPlaceApiAddress(
    String inputText,
  ) async {
    if (inputText.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:PK";

      var response = await RequestAssistant.receivedRequest(autoCompleteUrl);
      if (response == "Error Occured, Failed. No Response") {
        return [];
      }
      if (response["status"] == "OK") {
        var placePrediction = response["predictions"];
        var placeFound = (placePrediction as List)
            .map((jsonData) => PredictedPlace.fromJson(jsonData))
            .toList();
        setState(() {
          placePredicted = placeFound;
        });
        return placeFound;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 10,
          child: Container(
            width: context.screenWidth * .15,
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: const Color(0xff4b5563),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const Gap(10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Gap(10),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.adjust_sharp,
                        color: Color(0xff75b8f6),
                        size: 30,
                      )),
                  const Gap(10),
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      cursorColor: Colors.lightGreenAccent,
                      controller: mapControllerText,
                      onChanged: (value) {
                        if (value.isEmpty) {
                          setState(() {});
                          placePredicted = [];
                        } else {}
                        findPlaceApiAddress(value);
                      },
                      style: const TextStyle(color: Color(0xffe7e8e9)),
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              mapControllerText.clear();

                              placePredicted = [];
                            });
                          },
                          child: const Icon(
                            Icons.clear,
                            size: 20,
                            color: Color(0xfffeffff),
                          ),
                        ),
                        border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffe7e8e9))),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffe7e8e9))),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffe7e8e9))),
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(10),
              // Row(
              //   children: [
              //     const Gap(10),
              //     const Icon(
              //       Icons.location_on_outlined,
              //       color: Color(0xff75b8f6),
              //       size: 30,
              //     ),
              //     const Gap(10),
              //     Expanded(
              //       child: GestureDetector(
              //         onTap: () {
              //           Navigator.pushNamed(context, RouteNames.chooseLocation,
              //               arguments: widget.isPickUp as bool);
              //         },
              //         child: Text(
              //           "Choose on map",
              //           style:
              //               Theme.of(context).textTheme.labelMedium!.copyWith(
              //                     color: const Color(0xff75b8f6),
              //                   ),
              //         ),
              //       ),
              //     )
              //   ],
              // ),
              // const Gap(10),
              (placePredicted.isNotEmpty)
                  ? SizedBox(
                      height: 500,
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return PlacePredictionTile(
                            predictedPlace: placePredicted[index],
                            isPickUp: widget.isPickUp,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const Gap(10);
                        },
                        itemCount: placePredicted.length,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        )
      ],
    );
  }
}
