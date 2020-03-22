import 'package:google_maps_flutter/google_maps_flutter.dart';

class Virus{

  String provicestate;
  String countryregion;
  String lastupdate;
  LatLng location;
  int confirmed;
  int deaths;
  int recovered;

  Virus.fromJson(Map<String, dynamic> json) :
      provicestate = json['provincestate'],
      countryregion = json['countryregion'],
      lastupdate = json['countryregion'],
      location = LatLng(json['location']['lat'].toDouble(), json['location']['lng'].toDouble()),
      confirmed = json['confirmed'],
      deaths = json['deaths'],
      recovered = json['recovered'];


}