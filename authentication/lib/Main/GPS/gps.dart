import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

class GPS{
  static final location = Location();
  static Map startingLocationData;
  static int locationChanges = 0;
  static final platform = MethodChannel('tracker/gps/background_location_updater'); // Check MainActivity.java

  static DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('users');
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseUser currentUser;

  static setStartingLocation() async {
    Map startingLoc = await location.getLocation();
    startingLocationData = startingLoc;
    return;
  }

  static void setLocationUpdater(){
    // Set android native background updating using platform channels
    platform.invokeMethod('setBackgroundLocationUpdater');
  }
}