import 'dart:convert';

import 'package:delevery_app/data/repository/location_repo.dart';
import 'package:delevery_app/models/response_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/address_model.dart';

class LocationController extends GetxController implements GetxService{
  LocationRepo locationRepo;
  LocationController({
    required this.locationRepo
  });

  bool _loading = false;
  late Position _position;
  late Position _pickPosition;

  Placemark _placeMark = Placemark();
  Placemark get placeMark => _placeMark;
  Placemark _pickPlaceMark = Placemark();
  Placemark get pickPlaceMark => _pickPlaceMark;

  bool get loading => _loading;
  Position get position => _position;
  Position get pickPosition => _pickPosition;

  List<AddressModel> _addressList = [];
  List<AddressModel> get addressList => _addressList;

  late List<AddressModel> _allAddressList;
  List<AddressModel> get allAddressList=>_allAddressList;

  final List<String> _addressTypeList = ["Home", "Work", "Others"];
  List<String> get addressTypeList=>_addressTypeList;

  int _addressTypeIndex = 1;
  int get addressTypeIndex=>_addressTypeIndex;

  late Map<String, dynamic> _getAddress;
  Map get getAddress=> _getAddress;


  late GoogleMapController _mapController;
  GoogleMapController get mapController=>_mapController;
  bool _updateAddressData = true;
  bool _changeAddress = true;

  void setMapController(GoogleMapController mapController){
    _mapController=mapController;
  }

  Future<void> updatePosition(CameraPosition position, bool fromAddress) async {
   if(_updateAddressData){
     _loading = true;
     update();
     try{
       if(fromAddress){
         //from the small page 140
         _position = Position(
             longitude: position.target.longitude,
             latitude: position.target.latitude,
             timestamp: DateTime.now(),
             accuracy: 1,
             altitude: 1,
             heading: 1,
             speed: 1,
             speedAccuracy: 1
         );
       }else{
         //from another page (when pick the location)
         _pickPosition = Position(
           //we will send the longitude and latitude to our server
           //then from our server to google server
           //google server will send a string value for both long/lat
             longitude: position.target.longitude,
             latitude: position.target.latitude,
             timestamp: DateTime.now(),
             accuracy: 1,
             altitude: 1,
             heading: 1,
             speed: 1,
             speedAccuracy: 1
         );
       }if(_changeAddress){
         //talk to the server
         String _address = await getAddressFromGeocode(
           LatLng(
               position.target.latitude,
               position.target.longitude
           )
         );
         if(_changeAddress){
           fromAddress?
            _placeMark=Placemark(name: _address):
            _pickPlaceMark=Placemark(name: _address);
         }
       }

     }catch(e){
       print(e);
     }
     _loading=false;
     update();
   }
  }

  Future<String> getAddressFromGeocode(LatLng latlng) async{
    String _address = "Unknown location found";
    Response response = await locationRepo.getAddressFromGeocode(latlng);
    print(response.statusCode.toString() + response.statusText.toString());
    print(response.body["status"].toString());
    if(response.body["status"]=="OK"){
      _address = response.body["results"][0]["formatted_address"].toString();
      print("Address: $_address");
    }else{
      print("Error getting the google api");
    }
    update();
    return _address;
  }

  AddressModel getUserAddress(){
    late AddressModel _addressModel;
    //convert String to map
    _getAddress= jsonDecode(locationRepo.getUserAddress());
    try{
      //convert String to AddressModel
      _addressModel = AddressModel.fromJson(jsonDecode(locationRepo.getUserAddress()));
    }catch(e){
      print(e);
    }
    return _addressModel;
  }

  void setAddressTypeIndex(int index){
    _addressTypeIndex=index;
    update();
  }

  Future<ResponseModel> addAddress(AddressModel addressModel)async{
    _loading=true;
    update();
    ResponseModel responseModel;
    Response response = await locationRepo.addAddress(addressModel);
    if(response.statusCode==200){
      await getAddressList();
      String message = response.body["message"];
      responseModel=ResponseModel(true, message);
      await saveUserAddress(addressModel);
    }else{
      print("Couldn't save the address");
      responseModel = ResponseModel(false, response.statusText!);
    }
    update();
    return responseModel;
  }

  Future<void> getAddressList()async{
    Response response = await locationRepo.getAllAddress();
    if(response.statusCode==200){
      _addressList = [];
      _allAddressList = [];
      response.body.forEach((address){
        _addressList.add(AddressModel.fromJson(address));
        _allAddressList.add(AddressModel.fromJson(address));
      });
    }else{
      _addressList=[];
      _allAddressList=[];
    }
    update();
  }

  Future<bool> saveUserAddress(AddressModel addressModel)async{
    //grape addressModel object and save it in the local storage
    //SP save only String data // convert to String
    String userAddress = jsonEncode(addressModel.toJson());
    return await locationRepo.saveUserAddress(userAddress);

  }

  String getUserAddressFromLocalStorage(){
    return locationRepo.getUserAddress();
  }
}