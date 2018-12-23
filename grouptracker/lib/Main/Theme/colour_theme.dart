import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ColourTheme{
  static Map<String, Color> theme;

  static Map<String, Map<String, Color>> _themes = {
    'blue':{
      'normal': Colors.blue,
      'accent': Colors.blueAccent,
      'light': Colors.lightBlue,
      'lightAccent': Colors.lightBlueAccent,
    },
    'green':{
      'normal': Colors.green,
      'accent': Colors.greenAccent,
      'light': Colors.green,
      'lightAccent': Colors.lightGreenAccent,
    },
  };

  static Future<Map> setTheme() async {
    final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    final DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('users');

    await usersRef.child(currentUser.uid).once().then((DataSnapshot snap){
      final Map userData = snap.value as Map;

      if (userData['theme'] != null && userData['authID'] == currentUser.uid){
          theme = _themes[userData['theme']];
        } 
        else {
          theme = _themes['blue'];
        }
    });

    return theme;
  }
}