import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import '../../GPS/gps.dart';
import '../Home/markers.dart';

class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return HomeState();
  }
}

class HomeState extends State<Home>{
  Map _locationData = GPS.startingLocationData;
  GoogleMapController _mapController;
  StreamSubscription _locStream;
  Markers markers;
  
  @override
  void initState() {
    markers = Markers(_locationData);
    super.initState();
  }

  @override
  void dispose(){
    _mapController?.dispose();
    _locStream?.cancel();
    super.dispose();
  }

  void _setMap(){
      // Zoom to current position
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_locationData['latitude'], _locationData['longitude']),
          zoom: 15,
        )
      ));
  }

  _setMarkers() async {
    await markers.createMarkers().then((_){
      markers.people.forEach((person){
        setState(() {
          _mapController.addMarker(person.options);
        });
      });
    });

    return;
  }

  void _updateCurrentMarker(){
    Marker currentLoc = _mapController.markers.elementAt(0);

    // Update the location of the current user on the map
    _mapController.updateMarker(currentLoc, MarkerOptions(
      position: LatLng(_locationData['latitude'], _locationData['longitude']),
      infoWindowText: currentLoc.options.infoWindowText,
      icon: currentLoc.options.icon
    ));
  }

  void _setLocationUpdater(){
    // When the users's GPS coordinates change 5 times, update the location data and update the marker pos
    _locStream = GPS.location.onLocationChanged().listen((locationData){
      if (_locationData['latitude'] != locationData['latitude'] ||
          _locationData['longitude'] != locationData['longitude']){
            setState(() {
              _locationData = locationData;
              _updateCurrentMarker();
            });
        }     
    });
  }

  @override
  Widget build(BuildContext context){
    return Center(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children:<Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
                child: GoogleMap(
                  onMapCreated: (controller) { // onMapCreated needs a function to pass in a map controller
                    setState(() {
                      _mapController = controller;
                      if (_mapController != null){
                        _setMarkers().then((_){
                            _setMap();
                            _setLocationUpdater();
                        });
                      }
                    });
                  },
                ),
              ),
            ],
          )
        ]
      )
    );
  }
}