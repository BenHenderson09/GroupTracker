import 'package:flutter/material.dart';

import './Auth/login.dart';
import './Main/dashboard.dart';
import './Auth/Firebase/auth_functions.dart';
import './Main/Theme/colour_theme.dart';
import './Main/GPS/gps.dart';

class Root extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
      return RootState();
  }
}

class RootState extends State<Root>{
  final AuthFunctions auth = AuthFunctions();
  bool authorized = false;
  bool unauthorized = false;

  @override
  void initState(){
    auth.setCurrentUser().then((_){
        if (auth.currentUser != null){
          ColourTheme.setTheme().then((_){
            GPS.setStartingLocation().then((_){
              GPS.setLocationUpdater();
              setState(() {
              authorized = true;
            });
           });
        });
      } 
      else {
        setState(() {
          unauthorized = true;
        });
      }

    });
    super.initState();
  }

  
  @override
  Widget build(BuildContext context){
    if (authorized){
      return Dashboard();
    }
    if (unauthorized){
       return Login();
    }
    return Scaffold(
      body:Center(
        child: CircularProgressIndicator(),
      )
    );
  }
}