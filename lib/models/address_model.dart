class AddressModel{
  late int? _id;
  late String _addressType;
  late String _address;
  late String? _contactPersonName;
  late String? _contactPersonNumber;
  late String _longitude;
  late String _latitude;

  AddressModel({
    //this value don't have an (_) because will pass the value from outside
    id,
    required addressType,
    address,
    contactPersonName,
    contactPersonNumber,
    longitude,
    latitude,
  }){
    _id=id;
    _addressType=addressType;
    _address=address;
    _contactPersonName=contactPersonName;
    _contactPersonNumber=contactPersonNumber;
    _latitude=latitude;
    _longitude=longitude;
  }

  String get address=>_address;
  String get addressType=>_addressType;
  String? get contactPersonName=>_contactPersonName;
  String? get contactPersonNumber=>_contactPersonNumber;
  String get longitude=>_longitude;
  String get latitude=>_latitude;

  AddressModel.fromJson(Map<String, dynamic> json){
    _id=json["id"];
    _address=json["address"]??"";
    _addressType=json["address-type"]??"";
    _contactPersonName=json["contact_person_name"];
    _contactPersonNumber=json["contact_person_number"];
    _longitude=json["longitude"];
    _latitude=json["latitude"];
  }

  Map<String, dynamic> toJson(){
    Map<String, dynamic> data = <String, dynamic>{};
    data["id"]=this._id;
    data["address"]=this._address;
    data["addressType"]=this.addressType;
    data["contactPersonName"]=this._contactPersonName;
    data["contactPersonNumber"]=this._contactPersonNumber;
    data["latitude"]=this._latitude;
    data["longitude"]=this._longitude;
    return data;
  }
}