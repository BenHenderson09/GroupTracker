import 'package:flutter/material.dart';

import './root.dart';
import './Main/dashboard.dart';
import './Auth/login.dart';
import './Auth/registration.dart';
import './Auth/edit_account.dart';

void main() {
  runApp(FamilyTracker());
}

class FamilyTracker extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Root(),
      routes: <String, WidgetBuilder>{
        '/register': (BuildContext context) => Registration(),
        '/login': (BuildContext context) => Login(),
        '/dashboard': (BuildContext context) => Dashboard(),
        '/edit_account': (BuildContext context) => EditAccount()
      },
    );
  }
}