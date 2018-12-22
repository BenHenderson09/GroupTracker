import 'package:flutter/material.dart';

import './Firebase/auth_functions.dart';

class EditAccount extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return EditAccountState();
  }
}

class EditAccountState extends State<EditAccount>{
  final AuthFunctions _auth = AuthFunctions();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();

  final GlobalKey<ScaffoldState>  key =  GlobalKey<ScaffoldState>();
  Map userData;
  bool _loading = false;

  @override
  void initState() {
    _setUserDetails();
    super.initState();
  }

  @override
  void dispose(){
    _usernameController.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _setUserDetails(){
    _auth.setCurrentUser().then((_){
      _auth.getUserData().then((data){
        setState(() {
          userData = data;     
          _usernameController.text = userData['username'];
          _emailController.text = userData['email'];
          _fullnameController.text = userData['fullname'];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: key,
      body: _body(key)
    );
  }

  Map _validateInput(){
    String username = _usernameController.text;
    String fullname = _fullnameController.text;
    String email    = _emailController.text;
    
    // Username
    if (username.length <= 4) return {"message":"Usernames must be longer than 4 characters.", "success":false};

    if (username.length >= 35) return {"message":"Usernames must be shorter than 35 characters", "success":false};

    // Fullname
    if (fullname.length <= 1) return {"message":"Names must be longer than 1 character.", "success":false};

    if (fullname.length >= 50) return {"message":"Names must be shorter than 50 characters", "success":false};

    // Email
    if (email.length <= 5) return {"message":"Emails must be longer than 5 character.", "success":false};

    if (email.length >= 50) return {"message":"Emails must be shorter than 50 characters", "success":false};

    if (!email.contains('@')) return {"message":"Emails must be valid.", "success":false};

    return {"message":"", "success":true};
  }

  Widget _body(GlobalKey scaffoldStateKey){
    if (userData == null){
      return Center(child: CircularProgressIndicator());
    }

    return Center(
        child:ListView(   
          children:<Widget>[
            
            Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Image.asset(
                'assets/tracker.png',
                height: 180.0,
                width: 180.0,
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children:<Widget>[
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 5.0),
                  child: Column(
                    children: <Widget>[

                        Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: "Username",
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(35.0))),
                            ),
                            controller: _usernameController,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: "Fullname",
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(35.0))),
                            ),
                            controller: _fullnameController,
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(bottom: 10.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: "Email",
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(35.0))),
                            ),
                            controller: _emailController,
                          ),
                        ),

                        ButtonTheme(
                          minWidth: double.infinity,
                          padding: EdgeInsets.all(15.0),
                          child: RaisedButton(
                            child:  Text(
                              "Update Information",
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16.0,
                                ),
                              ),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(35.0))),
                            color: Colors.lightBlueAccent,
                            textColor: Colors.white,
                            onPressed: (){
                              setState(() {
                                _loading = true;                
                              });

                              Map input = _validateInput();

                              if (input['success']){

                                Map user = {
                                  'username': _usernameController.text,
                                  'fullname': _fullnameController.text,
                                  'email': _emailController.text,
                                };

                              _auth.uniqueUsername(user['username'], user['username'] == userData['username']).then((unique){
                                  if (unique){
                                    _auth.updateAccountInformation(user).then((_){
                                      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (_)=>false);
                                    });
                                  }  
                                  else{
                                    setState(() {
                                      _loading = false;                      
                                    });
                                    key.currentState.showSnackBar(SnackBar(
                                        content: Text("Username is already taken."),
                                        duration: Duration(seconds: 1),
                                     )
                                    );
                                  }
                                });  

                              }
                              else{
                                setState(() {
                                  _loading = false;                      
                                });
                                key.currentState.showSnackBar(SnackBar(
                                  content: Text(input['message']),
                                  duration: Duration(seconds: 1),
                                 )
                                );
                              } 
                            }
                          )
                        ),

                      FlatButton(
                        child:Text(
                          "Home",
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            color: Colors.black
                          ),
                        ),

                        onPressed: (){
                          Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (_)=>false);
                        },
                      ),
                      _loadingStatus(),
                    ],
                  )
                ), 
              ]
            ),
          ]
        ),
      );
  }

  Widget _loadingStatus(){
    if (_loading){
      return Container(
        child: CircularProgressIndicator()
      );
    }
    return Container();
  }
}