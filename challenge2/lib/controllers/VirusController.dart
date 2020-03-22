import 'dart:convert';

import 'package:challenge2/models/Virus.dart';
import 'package:http/http.dart' as http;


class VirusController{

  static const String _entryPoint =
      "https://wuhan-coronavirus-api.laeyoung.endpoint.ainize.ai";
  static const String _briefPoint = "/jhu-edu/brief";
  static const String _latestPoint = "/jhu-edu/latest";
  static List<Virus> actualCountryVirusLocation;
  static List<Virus> latestVirusLocation;
  static Map<String, dynamic> actualBrief;


  static Future<void> getBrief() async{
    Map<String, dynamic> res = {
      'confirmed': 0,
      'deaths': 0,
      'recovered': 0,
    };
    String url = _entryPoint + _briefPoint;
    final response = await http.get(url);
    if(response.statusCode == 200){
      actualBrief =  json.decode(response.body);
    }
    else{
      actualBrief = res;
    }
  }

  static Future<List<Virus>> getVirusLocation({String countryCode}) async{
    List<Virus> res = List();
    String url = _entryPoint + _latestPoint;
    if(countryCode != null) url += "?iso2=" + countryCode;
    final response = await http.get(url);
    if(response.statusCode == 200){
      List<dynamic> values = List();
      values = json.decode(response.body);
      if(values.isNotEmpty){
        for(int i = 0; i < values.length; i++){
          Map<String, dynamic> map = values[i];
          res.add(Virus.fromJson(map));
        }
      }
    }
    return res;
  }
}