import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class BaseFunctions{
  Future<Map> createUser(Map info);
  Future<Map> authenticateUser(String email, String password);
  Future<Map> getUserData();
  Future<bool> uniqueUsername(String username, bool unchangedUpdateUsername);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future setCurrentUser();
  Future updateAccountInformation(Map userData);
}

class AuthFunctions implements BaseFunctions{
  final DatabaseReference _requestsRef  = FirebaseDatabase.instance.reference().child("requests");
  final DatabaseReference _usersRef  = FirebaseDatabase.instance.reference().child("users");
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FirebaseUser currentUser;
  Map userDetails;

  Future<Map> createUser(Map info) async {
     FirebaseUser user;
     Map response = {"message":null, "success":false};

     try{
       user = await _firebaseAuth.createUserWithEmailAndPassword(email: info['email'], password: info['password']);

       _usersRef.child(user.uid).set({
         'username':info['username'],
         'fullname':info['fullname'],
         'email':info['email'],
         'authID':user.uid
       });

        response["success"] = true;
     } 
     catch(err){
       response["message"] = err.message;
     }

    return response;
  }

  Future<Map> authenticateUser(String email, String password) async {
    FirebaseUser user;
    Map response = {"message":"", "success":false};

    try {
      user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      response["success"] = true;
    }
    catch(err) {
      response["message"] = err.message;
    }

    return response;
  }

  Future<Map> getUserData() async {
    return await _usersRef.child(currentUser.uid).once().then((DataSnapshot snap){
      final Map userDetails = snap.value as Map;

      if (userDetails != null){
        return {'username':userDetails['username'], 'email':userDetails['email'], 'fullname':userDetails['fullname']};
      }
    });
  }

  Future<bool> uniqueUsername(String username, bool unchangedUpdateUsername) async {
    return unchangedUpdateUsername ? true : await _usersRef.once().then((DataSnapshot snapshot) {
      final users = snapshot.value as Map;
      bool unique = true;

      users.forEach((var key, var value){
        if(users[key]['username'] == username){
          unique = false;
        }
      });

      return unique;
    });
  }

  Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email){
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future setCurrentUser() async {
    currentUser = await _firebaseAuth.currentUser();
    return;
  }

  Future updateAccountInformation(Map newUserData) async {
    // Update user's own details
    await _usersRef.child(currentUser.uid).once().then((DataSnapshot snap){
      final Map userData = snap.value as Map;

      userData['username'] = newUserData['username'];
      userData['fullname'] = newUserData['fullname'];
      userData['email'] = newUserData['email'];
      
      _usersRef.child(currentUser.uid).set(userData);
    });

    // Update user's information for friends
    List friendKeys = await _usersRef.child(currentUser.uid).child('friends').once().then((DataSnapshot snap){
      return (snap.value as Map)?.keys?.toList() ?? List();
    });

    for(int i = 0; i < friendKeys.length; i++){
          await _usersRef.child(friendKeys[i]).child('friends').child(currentUser.uid).once().then((DataSnapshot snap){
            final Map friendData = snap.value as Map;
            
            friendData['username'] = newUserData['username'];
            friendData['fullname'] = newUserData['fullname'];
            friendData['email']    = newUserData['email'];

            _usersRef.child(friendKeys[i]).child('friends').child(currentUser.uid).set(friendData);
        });
    }

    // Update recieved request details
    List recievedRequestKeys = await _requestsRef.child(currentUser.uid).child('recieved').once().then((DataSnapshot snap){
      return (snap.value as Map)?.keys?.toList() ?? List();
    });

    for(int i = 0; i < recievedRequestKeys.length; i++){
      await _requestsRef.child(recievedRequestKeys[i]).child('sent').child(currentUser.uid).once().then((DataSnapshot snap){
        final Map requestData = snap.value as Map;

        requestData['username'] = newUserData['username'];
        requestData['email']    = newUserData['email'];

        _requestsRef.child(recievedRequestKeys[i]).child('sent').child(currentUser.uid).set(requestData);
      });
    }

    // Update sent request details
    List sentRequestKeys = await _requestsRef.child(currentUser.uid).child('sent').once().then((DataSnapshot snap){
      return (snap.value as Map)?.keys?.toList() ?? List();
    });

    for(int i = 0; i < sentRequestKeys.length; i++){
      await _requestsRef.child(sentRequestKeys[i]).child('recieved').child(currentUser.uid).once().then((DataSnapshot snap){
        final Map requestData = snap.value as Map;

        requestData['username'] = newUserData['username'];
        requestData['email']    = newUserData['email'];

        _requestsRef.child(sentRequestKeys[i]).child('recieved').child(currentUser.uid).set(requestData);
      });
    }

    return;
  }
}

