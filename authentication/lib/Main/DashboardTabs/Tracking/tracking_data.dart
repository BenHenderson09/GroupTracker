import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TrackingData{
  DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('users');
  DatabaseReference friendsRef;
  FirebaseUser currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  
  getFriends() async {
    currentUser = await auth.currentUser();
    List friends = List();

    await usersRef.child(currentUser.uid).once().then((DataSnapshot snap){
      final userData = snap.value as Map;

      if (userData['friends'] != null){
          friendsRef = usersRef.child(currentUser.uid).child('friends');
          
          userData['friends'].forEach((key,val){
            friends.add({
              'uid':key,
              'username':  userData['friends'][key]['username'],
              'email':  userData['friends'][key]['email'],
              'tracking':  userData['friends'][key]['tracking']
              });
          });
      }
    });

    return friends;
  }

  setTracked(String uid, bool val) async {
    await friendsRef.child(uid).once().then((DataSnapshot snap){
      final Map friendDetails = snap.value as Map;

      friendsRef.child(uid).set({
        'username':friendDetails['username'],
        'email':friendDetails['email'],
        'tracking':val
      });
    });
    return;
  }
}