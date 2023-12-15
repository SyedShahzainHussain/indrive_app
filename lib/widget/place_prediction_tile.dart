import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:user_uber_app/assistants/request_assistant.dart';
import 'package:user_uber_app/constants/constant.dart';
import 'package:user_uber_app/model/directon.dart';
import 'package:user_uber_app/model/predicted_places.dart';
import 'package:user_uber_app/provider/app_info_provider.dart';
import 'package:user_uber_app/resources/app_colors.dart';
import 'package:user_uber_app/widget/progress_dialog.dart';
import "package:provider/provider.dart";

class PlacePredictionTile extends StatefulWidget {
  final PredictedPlace? predictedPlace;
  final bool? isPickUp;
  const PlacePredictionTile({super.key, this.predictedPlace, this.isPickUp});

  @override
  State<PlacePredictionTile> createState() => _PlacePredictionTileState();
}

class _PlacePredictionTileState extends State<PlacePredictionTile> {
  getPlaceDirectionDetails(String placeId, BuildContext context) async {
    widget.isPickUp!
        ? showDialog(
            context: context,
            builder: (context) => ProgressDialog(
              message: "Setting Up Pick-Up, Please wait...",
            ),
          )
        : showDialog(
            context: context,
            builder: (context) => ProgressDialog(
              message: "Setting Up Drop-Off, Please wait...",
            ),
          );
    // ! place details api
    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseAPi =
        await RequestAssistant.receivedRequest(placeDirectionDetailsUrl);
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    if (responseAPi == "Error Occured, Failed. No Response") {
      return;
    }
    if (responseAPi["status"] == "OK") {
      Directions directions = Directions();

      directions.locationId = placeId;
      directions.locationName = responseAPi["result"]["formatted_address"];
      directions.locationLatitude =
          responseAPi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude =
          responseAPi["result"]["geometry"]["location"]["lng"];
      // ignore: use_build_context_synchronously
      widget.isPickUp!
          ? context.read<AppInfo>().updatePickUpAddressLocation(directions)
          : context.read<AppInfo>().updateDropUpAddressLocation(directions);
      Navigator.pop(context, "obtainedDropOff");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor: const Color(0xff1c1f24),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(8.0),
              topLeft: Radius.circular(8.0),
            ),
          ),
        ),
        onPressed: () {
          getPlaceDirectionDetails(widget.predictedPlace!.place_id!, context);
        },
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(8),
                Text(
                  widget.predictedPlace!.main_text!,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: AppColors.whiteColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Gap(8),
                Text(
                  widget.predictedPlace!.secondary_text!,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Colors.white54,
                      ),
                ),
                const Gap(8),
              ],
            ))
          ]),
        ));
  }
}
