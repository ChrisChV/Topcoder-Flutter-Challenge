import 'package:challenge2/controllers/GeoController.dart';
import 'package:challenge2/controllers/VirusController.dart';
import 'package:challenge2/models/Virus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await GeoController.getActualLocation();
  if(GeoController.actualLocation == null){
    GeoController.actualLocation = LocationData.fromMap({
      'latitude': 45.521563,
      'longitude': -122.677433,
    });
  }
  else {
    await GeoController.getCountryAndCode(GeoController.actualLocation);
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget{

  @override
  State<StatefulWidget> createState(){
    return MyAppState();
  }

}

class MyAppState extends State<MyApp> {

  GoogleMapController mapController;
  final LatLng _center = LatLng(
      GeoController.actualLocation.latitude,
      GeoController.actualLocation.longitude);
  final Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final Map<String, Virus> viruces = <String, Virus>{};
  int actualId = 1;
  bool loading = true;

  @override
  void initState(){
    super.initState();
    VirusController.getVirusLocation().then((List<Virus> data){
      VirusController.latestVirusLocation = data;
      VirusController.getBrief().then((void _){
        setState(() {
          loading = false;
        });
      });
    });
  }

  void _addMarkers(List<Virus> virusList){
    for(Virus virus in virusList){
      String markerIdVal = actualId.toString();
      actualId++;
      viruces[markerIdVal] = virus;
      String title = virus.countryregion;
      if(virus.provicestate != null && virus.provicestate.isNotEmpty){
        title += ' (' + virus.provicestate + ')';
      }
      String snippet = 'C: ' + virus.confirmed.toString() +
                        ' D: ' + virus.deaths.toString() +
                        ' R: ' + virus.recovered.toString();
      final MarkerId markerId = MarkerId(markerIdVal);
      final Marker marker = Marker(
        markerId: markerId,
        position: virus.location,
        infoWindow: InfoWindow(
            title: virus.countryregion,
            snippet: snippet,
        ),
        onTap: (){
          onTouchMark(markerIdVal);
        },
      );
      setState(() {
        markers[markerId] = marker;
      });
    }
  }

  void onTouchMark(String markerId){
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Not in stock'),
          content: const Text('This item is no longer available'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _addMarkers(VirusController.latestVirusLocation);
  }

  @override
  Widget build(BuildContext context) {
    if(loading){
      return MaterialApp(
        title: 'Coronavirus Map',
        home: Scaffold(
          appBar: AppBar(
            title: Text('Coronavirus Map'),
            backgroundColor: Colors.green[700],
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(child: CircularProgressIndicator(),),
            ],
          ),
        ),
      );
    }
    return MaterialApp(
      title: 'Coronavirus Map',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Coronavirus Map'),
          backgroundColor: Colors.green[700],
        ),
        bottomNavigationBar:BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Confirmed (C): ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: VirusController.actualBrief['confirmed'].toString()),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Deaths (D): ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: VirusController.actualBrief['deaths'].toString()),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Recovered (R): ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: VirusController.actualBrief['recovered'].toString()),
                  ],
                )
              )
            ],
          ),
          color: Colors.green[700],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 4.5,
          ),
          markers: Set<Marker>.of(markers.values),
        ),
      ),
    );
  }
}

