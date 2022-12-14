import 'package:delevery_app/data/api/api_client.dart';
import 'package:delevery_app/models/address_model.dart';
import 'package:delevery_app/utils/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationRepo{
  ApiClient apiClient;
  SharedPreferences sharedPreferences;

  LocationRepo({
    required this.apiClient,
    required this.sharedPreferences
  });

  Future<Response> getAddressFromGeocode(LatLng latlng) async{
    return await apiClient.getData(
      //when send in one url
    //https/localhost:3000/api/v1/config/geocode-api?lat=00&lng=00
        '${AppConstants.GEOCODE_URI}'
        '?lat=${latlng.latitude}&lng=${latlng.longitude}'
    );
  }

  String getUserAddress(){
    return sharedPreferences.getString(AppConstants.USER_ADDRESS)??"";
  }

  Future<Response> addAddress(AddressModel addressModel)async{
    Response response = await apiClient.postData(AppConstants.ADD_USER_ADDRESS, addressModel.toJson());
    return response;
  }

  Future<Response> getAllAddress()async{
    return await apiClient.getData(AppConstants.ADDRESS_LIST_URI);
  }

  Future<bool> saveUserAddress(String address)async{
    apiClient.updateHeaders(AppConstants.TOKEN);
    return await sharedPreferences.setString(AppConstants.USER_ADDRESS, address);
  }

}