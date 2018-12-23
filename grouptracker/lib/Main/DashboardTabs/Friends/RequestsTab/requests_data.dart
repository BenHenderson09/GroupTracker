import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestsData{
  DatabaseReference requestsRef = FirebaseDatabase.instance.reference().child('requests');
  DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('users');
  FirebaseUser currentUser;
  
  getRecievedRequests() async { 
    currentUser = await FirebaseAuth.instance.currentUser();
    List userRequests = List();


    await requestsRef.child(currentUser.uid).child('recieved').once().then((DataSnapshot snap){
      final requests = snap.value as Map;
    
      if (requests != null){
        requests.forEach((key,value){
          userRequests.add({'uid':key, 'username':requests[key]['username'], 'email':requests[key]['email']});
        });
      }
    });

    return userRequests;
  }

  getSentRequests() async { 
    currentUser = await FirebaseAuth.instance.currentUser();
    List userRequests = List();

    await requestsRef.child(currentUser.uid).child('sent').once().then((DataSnapshot snap){
      final requests = snap.value as Map;
    
      if (requests != null){
        requests.forEach((key,value){
          userRequests.add({'uid':key, 'username':requests[key]['username'], 'email':requests[key]['email']});
        });
      }
    });

    return userRequests;
  }

  cancelRequest(String uid) async {
    await requestsRef.child(currentUser.uid).child('sent').child(uid).remove();
    await requestsRef.child(uid).child('recieved').child(currentUser.uid).remove();
    return;
  }

  handleRequest(bool accepted, String uid, String username, String email) async {
    Map userDetails;

    await usersRef.child(currentUser.uid).once().then((DataSnapshot snap){
      userDetails = snap.value as Map;
    });

    // Remove request data from both users
    await requestsRef.child(currentUser.uid).child('recieved').child(uid).remove();
    await requestsRef.child(uid).child('sent').child(currentUser.uid).remove();

    if (accepted){
      // Become friends
      await usersRef.child(currentUser.uid).child('friends').child(uid).set({
        'username': username,
        'email': email,
        'tracking':false
      });

      await usersRef.child(uid).child('friends').child(currentUser.uid).set({
        'username': userDetails['username'],
        'email': userDetails['email'],
        'tracking':false
      });
    }
  }
}