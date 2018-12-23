import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class Markers{
  List<Marker> _people = new List();
  Map<String,double> _locationData;

  List<Marker> get people => _people;

  Markers(Map<String,double> locationData){
    _locationData = locationData;
  }

  createMarkers() async {
    // Remove all previous markers
    _people.clear();

    // Add the users current position
    _people.add(
        Marker('0', MarkerOptions(
        position: LatLng(_locationData['latitude'], _locationData['longitude']),
        infoWindowText: InfoWindowText('Me', ''),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
        ),
      ))
    );

    final FirebaseAuth auth = FirebaseAuth.instance;
    final DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('users');
    final FirebaseUser currentUser = await auth.currentUser();

    Map friends;
    int markerIndex = 1;

    await usersRef.child(currentUser.uid).child('friends').once().then((DataSnapshot snap){
      friends = snap.value as Map;
    });

    if (friends != null){
      // Using foreach stops await from working correctly for some reason
      List friendKeys = friends.keys.toList();

      for (int i = 0; i < friendKeys.length; i++){
        await usersRef.child(friendKeys[i]).child('location').once().then((DataSnapshot locSnap){
            final locData = locSnap.value as Map;

            if (locData != null && friends[friendKeys[i]]['tracking']){
                _people.add(
                  Marker(
                      markerIndex.toString(),
                      MarkerOptions(
                        position: LatLng(locData['latitude'], locData['longitude']),
                        infoWindowText: InfoWindowText(friends[friendKeys[i]]['username'], "updated: " + locData['updated']),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          Random().nextDouble() * 359.0 // Random double (0 <-> 1.0) normalized to the colour range
                        ),
                    )
                  )
              );
            }
          markerIndex++;
        });
      }
    }

    return _people;
  }
}