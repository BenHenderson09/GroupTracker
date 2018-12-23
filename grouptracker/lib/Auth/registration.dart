import 'package:flutter/material.dart';

import '../Auth/Firebase/auth_functions.dart';

class Registration extends StatefulWidget{
  @override
  State createState() => RegistrationState();
}

class RegistrationState extends State<Registration>{
  final AuthFunctions _auth = AuthFunctions();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordResubmitController = TextEditingController();
  
  final GlobalKey<ScaffoldState>  key =  GlobalKey<ScaffoldState>();
  bool _loading = false;

  @override
  void dispose(){
    _usernameController.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordResubmitController.dispose();
    super.dispose();
  }

  Map _validateInput(){
    String username = _usernameController.text;
    String fullname = _fullnameController.text;
    String email    = _emailController.text;
    String password = _passwordController.text;
    String passwordResubmit = _passwordResubmitController.text;
    
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

    // Password
    if (password.length <= 5) return {"message":"Passwords must be longer than 5 character.", "success":false};

    if (password.length >= 50) return {"message":"Passwords must be shorter than 50 characters", "success":false};

    if (passwordResubmit != password) return {"message":"Passwords do not match", "success":false};

    return {"message":"", "success":true};
  }

  


  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: key,
      body: Center(
        child:ListView(   
          children:<Widget>[
            
            Padding(
              padding: EdgeInsets.only(top: 6.0),
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

                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: TextFormField(
                            obscureText: true,
                              decoration: InputDecoration(
                                hintText: "Password",
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(35.0))),
                              ),
                              controller: _passwordController,
                            ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: TextFormField(
                            obscureText: true,
                              decoration: InputDecoration(
                                hintText: "Resubmit Password",
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(35.0))),
                              ),
                              controller: _passwordResubmitController,
                            ),
                        ),

                        ButtonTheme(
                          minWidth: double.infinity,
                          padding: EdgeInsets.all(15.0),
                          child: RaisedButton(
                            child:  Text(
                              "Register",
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
                                  'password': _passwordController.text,
                                  'theme': 'blue'
                                };

                                _auth.uniqueUsername(_usernameController.text, false).then((result){
                                  if (result){
                                    _auth.createUser(user).then((result){
                                        if (result['success']){
                                          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
                                        }
                                        else{
                                          key.currentState.showSnackBar(SnackBar(
                                              content: Text(result['message']),
                                              duration: Duration(seconds: 2),
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
                            },
                          )
                        ),

                      FlatButton(
                        child:Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            color: Colors.black
                          ),
                        ),

                        onPressed: (){
                          Navigator.of(context).pushNamed('/login');
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
