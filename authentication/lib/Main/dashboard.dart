import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import  './DashboardTabs/Home/home.dart';
import  './DashboardTabs/Tracking/tracking.dart';
import  './DashboardTabs/Friends/friends_home.dart';
import  '../Auth/Firebase/auth_functions.dart';
import  './Theme/colour_theme.dart';

class Dashboard extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return DashboardState();
  }
}

class DashboardState extends State<Dashboard>{
  AuthFunctions _auth = AuthFunctions();
  String _currentTheme = ColourTheme.theme['normal'] == Colors.blue ? 'blue' : 'green';
  Map _userDetails;
  int _tabIndex = 0;

  @override
  void initState() {
    _loadUserDetails();
    super.initState();
  }


  void _loadUserDetails() async {
    await _auth.setCurrentUser().then((_){
      FirebaseUser currentUser = _auth.currentUser;

      FirebaseDatabase.instance.reference().child('users').child(currentUser.uid).once().then((DataSnapshot snap){
        final userData = snap.value as Map;
        setState(() {
            _userDetails = userData;
        });
      });
    });
    
  }

  Widget _currentTab(int index){
    switch (index){
      case 0:
        return Home();
      case 1:
        return Tracking();
      case 2:
        return FriendsHome();
      default:
        return Home();
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomPadding:false,
      appBar: AppBar(
        title: Text(
            "GroupTracker",
            style: TextStyle(
              fontWeight: FontWeight.w400
            ),
          ),
          backgroundColor: ColourTheme.theme['normal'],
      ),

      drawer: Drawer(
        child: ListView(
          children: <Widget>[
           UserAccountsDrawerHeader(
              accountName: Text(_userDetails != null ? _userDetails['username']:"..."),
              accountEmail: Text(_userDetails != null ? _userDetails['email']:"..."),
              currentAccountPicture: CircleAvatar(
                child: Text(
                    _userDetails != null ? _userDetails['username'][0].toUpperCase():"?",
                    style: TextStyle(
                      fontSize: 30.0
                    ),
                  ),
                  backgroundColor: _currentTheme == 'blue' ? Colors.green : Colors.blue,
              ),
              decoration: BoxDecoration(
                color: ColourTheme.theme['normal'],
              ),
            ),

            ListTile(
              title: Row(
                children:<Widget>[
                  Icon(
                    Icons.palette,
                    color: Colors.grey[700],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child:Text(
                      "Theme",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ]
              ),
              onTap: (){
                _showThemeDialog();
              },
            ),

            ListTile(
              title: Row(
                children: <Widget>[
                  Icon(
                    Icons.account_circle,
                    color: Colors.grey[700],
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child:Text(
                      "Edit Account",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ]
              ),
              onTap: (){
                Navigator.of(context).pushNamed('/edit_account');
              },
            ),

            ListTile(
              title: Row(
                children: <Widget>[
                  Icon(
                    Icons.exit_to_app,
                    color: Colors.grey[700],
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child:Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ]
              ),
              onTap: (){
                _auth.signOut().then((result){
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_)=>false);
                });
              },
            ),

            ListTile(
              title: Row(
                children: <Widget>[
                  Icon(
                    Icons.delete,
                    color: Colors.grey[700],
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child:Text(
                      "Delete Account",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ]
              ),
              onTap: (){
                _showDeleteAccountDialog();
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        fixedColor: ColourTheme.theme['light'],
        onTap: (index){
          setState((){
            _tabIndex = index;
          });
        },
        items:<BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home")
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text("Tracking")
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin),
            title: Text("Friends")
          ),
        ]
      ),

      body: _currentTab(_tabIndex),
    );
  }

    void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Switch Theme?",
            textAlign: TextAlign.center,
          ),
          content: Text(
            "Switching theme will restart application with a new " +
             (_currentTheme == 'blue' ? 'Green':'Blue')
            + " theme being applied."
            ),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Switch Theme"),
              onPressed: () async {
                final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
                final DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('users');

                _userDetails['theme'] = _currentTheme == 'blue' ? 'green':'blue';

                usersRef.child(currentUser.uid).set(_userDetails).then((response){
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (_)=>false);
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Account?",
            textAlign: TextAlign.center,
          ),
          content: Text(
            "By performing this action your account and its data will be removed, consider your "+
            "choice carefully."
            ),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Delete Account"),
              onPressed: () async {
                final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
                final DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('users');
                final DatabaseReference requestsRef = FirebaseDatabase.instance.reference().child('requests');

                // Remove all friend references of the user.
                await usersRef.child(currentUser.uid).child('friends').once().then((DataSnapshot snap){
                  final friends = snap.value as Map;

                  if (friends != null){
                    friends.forEach((key,val){
                      usersRef.child(key).child('friends').child(currentUser.uid).remove();                      
                    });
                  } 
                });

                // Remove all friend request references

                // Remove pending requests from oter user's accounts
                await requestsRef.child(currentUser.uid).child('recieved').once().then((DataSnapshot snap){
                  final Map recievedRequests = snap.value as Map;

                  if (recievedRequests != null){
                    recievedRequests.forEach((key,val){
                      requestsRef.child(key).child('sent').child(currentUser.uid).remove();
                    });
                  }
                });

                // Remove received requests from other user's accounts
                await requestsRef.child(currentUser.uid).child('sent').once().then((DataSnapshot snap){
                  final Map sentRequests = snap.value as Map;

                  if (sentRequests != null){
                    sentRequests.forEach((key, val){
                      requestsRef.child(key).child('recieved').child(currentUser.uid).remove();
                    });
                  }
                });

                // Remove user's data
                usersRef.child(currentUser.uid).remove();
                requestsRef.child(currentUser.uid).remove();
                currentUser.delete();

                // Go back to app home
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_)=>false);
              },
            ),
          ],
        );
      },
    );
  }
}