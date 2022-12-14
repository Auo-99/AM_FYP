import 'package:delevery_app/controllers/auth_controller.dart';
import 'package:delevery_app/controllers/location_controller.dart';
import 'package:delevery_app/controllers/user_controller.dart';
import 'package:delevery_app/models/address_model.dart';
import 'package:delevery_app/pages/location/pick_address_map.dart';
import 'package:delevery_app/widget/big_text.dart';
import 'package:delevery_app/widget/text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../routes/rout_helper.dart';
import '../../utils/colors.dart';
import '../../utils/dimension.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({Key? key}) : super(key: key);

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {

  TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactPersonName = TextEditingController();
  final TextEditingController _contactPersonNumber = TextEditingController();
  late bool _isLogged;
  CameraPosition _cameraPosition =  CameraPosition(
      target: LatLng(32.885353, 13.180161),
      zoom: 17
  );
  late LatLng _initialPosition = LatLng(32.885353, 13.180161);

  @override
  void initState() {
    //TODO: implement initState
    super.initState();
    _isLogged = Get.find<AuthController>().userLoggedIn();
    //var userModel = Get.find<UserController>().userModel;
    //var addressList = Get.find<LocationController>().addressList;
    //var getAddress = Get.find<LocationController>().getAddress;
    if(_isLogged && Get.find<UserController>().userModel==null){
      Get.find<UserController>().getUserInfo();
    }
    if(Get.find<LocationController>().addressList.isNotEmpty){
      if(Get.find<LocationController>().getUserAddressFromLocalStorage()==""){
        Get.find<LocationController>().saveUserAddress(Get.find<LocationController>().addressList.last);
      }
      Get.find<LocationController>().getUserAddress();
      _cameraPosition = CameraPosition(target: LatLng(
        double.parse(Get.find<LocationController>().getAddress["longitude"]),
        double.parse(Get.find<LocationController>().getAddress["latitude"]),
      ));
      _initialPosition = LatLng(
        double.parse(Get.find<LocationController>().getAddress["longitude"]),
        double.parse(Get.find<LocationController>().getAddress["latitude"]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
        backgroundColor: AppColors.mainColor,
      ),
      body: GetBuilder<UserController>(builder: (userController){
        if(userController.userModel!=null&&_contactPersonNumber.text.isNotEmpty){
          _contactPersonName.text = "${userController.userModel?.name}";
          _contactPersonNumber.text = "${userController.userModel?.phone}";
          if(Get.find<LocationController>().addressList.isEmpty){
            //if user don't change the address use the old one we save in (SP)
            _addressController.text = Get.find<LocationController>().getUserAddress().address;
          }
        }
        return GetBuilder<LocationController>(builder: (locationController){
          //when user change his address catch the changes in the controller
          _addressController.text = "${locationController.placeMark.name??""}"
              "${locationController.placeMark.locality??""}"
              "${locationController.placeMark.postalCode??""}"
              "${locationController.placeMark.country??""}";
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //map showing container
                Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          width: 2, color: AppColors.mainColor,
                      )
                  ),
                  child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _initialPosition, zoom: 17,
                          ),
                          onTap: (LatLng){
                            Get.toNamed(
                                RouteHelper.getPickAddressMap(),
                                arguments: PickAddressMap(
                                  fromAddress: true,
                                  fromSignIn: false,
                                  mapController: locationController.mapController
                              )
                            );
                          },
                          zoomControlsEnabled: false,
                          compassEnabled: false,
                          indoorViewEnabled: true,
                          mapToolbarEnabled: false,
                          myLocationEnabled: true,
                          onCameraIdle: (){
                            //when choose in the map after you stop the function call
                            locationController.updatePosition(_cameraPosition, true);
                          },
                          onCameraMove: ((position)=>_cameraPosition=position),
                          onMapCreated: (GoogleMapController controller){
                            //one time setup
                            //calls when map created for the first time
                            locationController.setMapController(controller);
                          },
                        ),
                      ]
                  ),
                ),
                //3Button addressType index
                Padding(
                  padding: EdgeInsets.only(left: Dimention.width20, top: Dimention.width20),
                  child: SizedBox(height: 70, child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: locationController.addressTypeList.length,
                    itemBuilder: (context, index){
                      return InkWell(
                        onTap: (){
                          locationController.setAddressTypeIndex(index);
                        },
                        child: Container(
                          margin: EdgeInsets.only(right : Dimention.width20),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical:10),
                          decoration:BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimention.heigt15),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                ),
                              ]
                          ),
                          child: Icon(
                            index==0?Icons.home_filled:index==1?Icons.work:Icons.location_on,
                            color: locationController.addressTypeIndex==index?
                            AppColors.mainColor:Theme.of(context).disabledColor,
                            size: 30,
                          ),
                        ),
                      );
                    },
                    ),
                  ),
                ),
                SizedBox(height: Dimention.heigt30),
                //text Delivery Address
                Padding(
                  padding: EdgeInsets.only(left: Dimention.width20),
                  child: BigText(text: "Delivery Address", color: Colors.grey[700],),
                ),
                SizedBox(height: Dimention.heigt10),
                //location field
                TextFieldWidget(
                    textController: _addressController,
                    hintText: "address",
                    prefix: Icons.location_on),
                SizedBox(height: Dimention.heigt30),
                //Text person Name
                Padding(
                  padding: EdgeInsets.only(left: Dimention.width20),
                  child: BigText(text: "Name", color: Colors.grey[700],),
                ),
                SizedBox(height: Dimention.heigt10),
                //Name field
                TextFieldWidget(
                    textController: _contactPersonName,
                    hintText: "Name",
                    prefix: Icons.person),
                SizedBox(height: Dimention.heigt30),
                //Text person phone number
                Padding(
                  padding: EdgeInsets.only(left: Dimention.width20),
                  child: BigText(text: "Phone Number", color: Colors.grey[700],),
                ),
                SizedBox(height: Dimention.heigt10),
                //Phone field
                TextFieldWidget(
                    textController: _contactPersonNumber,
                    hintText: "Phone Number",
                    prefix: Icons.phone),

              ],
            ),
          );
        });
      }),
        bottomNavigationBar:
        GetBuilder<LocationController>(builder: (locationController) {
          return Container(
            height: Dimention.heigt20*7,
            width: double.maxFinite,
            padding: EdgeInsets.only(
                top: Dimention.heigt30,
                bottom: Dimention.heigt30,
                left: Dimention.width20*4,
                right: Dimention.width20*4),
            decoration: BoxDecoration(
                color: AppColors.buttonBackgroundColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(Dimention.heigt20),
                  topLeft: Radius.circular(Dimention.heigt20),
                )),
            child: GestureDetector(
              onTap: (){
                //create model to pass it in addAddress method
                AddressModel _addressModel = AddressModel(
                    addressType: locationController.addressTypeList[locationController.addressTypeIndex],
                    address: _addressController.text,
                    contactPersonName: _contactPersonName.text,
                    contactPersonNumber: _contactPersonNumber.text,
                    longitude: locationController.position.longitude.toString(),
                    latitude: locationController.position.latitude.toString(),
                );
                //addAddress return responseModel
                print(_addressModel.contactPersonNumber);
                print(_addressModel.contactPersonName);
                locationController.addAddress(_addressModel).then((response) {
                  if(response.isSuccess){
                    Get.back();
                    Get.snackbar("Add Address", "Address Added Successfully");
                  }else{
                    Get.snackbar("Add Address", "Couldn't save the address");
                  }
                });
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(Dimention.width20),
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
                child: BigText(
                  text: "Save Address",
                  color: Colors.white,
                  size: Dimention.font26,
                ),
              ),
            ),
          );
        }));
  }
}
