import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

class GeoController{

  static final Location _locationController = new Location();
  static LocationData actualLocation;
  static List<String> actualCountry;


  static Future<void> getActualLocation({bool request = true}) async{
    try {
      actualLocation = await _locationController.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  static Future<void> getCountryAndCode(LocationData location)async{
    List<String> res = List();
    try{
      final coordinates = new Coordinates(location.latitude, location.longitude);
      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      if(addresses.isEmpty) return;
      var first = addresses.first;
      if(first == null) return;
      res.add(first.countryName);
      res.add(first.countryCode);
      actualCountry = res;
    } catch(error){
      return;
    }
  }
}