import 'package:delevery_app/controllers/location_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../utils/colors.dart';
import '../../utils/dimension.dart';

class PickAddressMap extends StatefulWidget {
  bool fromAddress;
  bool fromSignIn;
  GoogleMapController? mapController;
  PickAddressMap({
    Key? key,
    required this.fromAddress,
    required this.fromSignIn,
    this.mapController,
  }) : super(key: key);

  @override
  State<PickAddressMap> createState() => _PickAddressMapState();
}

class _PickAddressMapState extends State<PickAddressMap> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(Get.find<LocationController>().addressList.isEmpty){
      _initialPosition = LatLng(32.885353, 13.180161);
      _cameraPosition = CameraPosition(target: _initialPosition, zoom: 17);
    }else{
      if(Get.find<LocationController>().addressList.isNotEmpty){
        _initialPosition = LatLng(
            double.parse(Get.find<LocationController>().getAddress["latitude"]),
            double.parse(Get.find<LocationController>().getAddress["longitude"]),
        );
        _cameraPosition = CameraPosition(target: _initialPosition, zoom: 17);
      }
    }
  }

  @override
  late LatLng _initialPosition;
  late GoogleMapController _mapController;
  late CameraPosition _cameraPosition;

  Widget build(BuildContext context) {
    return GetBuilder<LocationController>(builder: (locationController){
      return Scaffold(
        body: SafeArea(
            child: Center(
              child: SizedBox(
                width: double.maxFinite,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _initialPosition, zoom: 17,
                      ),
                      zoomControlsEnabled: false,
                      onCameraMove: (CameraPosition cameraPosition){
                        _cameraPosition = cameraPosition;
                      },
                      onCameraIdle: (){
                        Get.find<LocationController>().updatePosition(_cameraPosition, false);
                      },
                    ),
                    Center(
                      //use this after fixing the bug ..
                      // !locationController.loading?
                      // Image.asset("assets/image/pick_marker.png", width: 50, height: 50,):
                      // const CircularProgressIndicator()
                      child: Image.asset("assets/image/pick_marker.png", width: 50, height: 50,),
                    ),
                    Positioned(
                      top: Dimention.heigt45,
                        left: Dimention.width20,
                        right: Dimention.width20,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimention.heigt15),
                              color: AppColors.mainColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                ),
                              ]
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 26,

                                ),
                              ),
                              Expanded(
                                  child: Text(
                                    "${locationController.pickPlaceMark.name??"Tripoli Libya"}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: Dimention.font16,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  )
                              ),
                            ],
                          ),
                        ),
                    ),
                  ],
                ),
              ),
            )
        ),
      );
    });
  }
}
