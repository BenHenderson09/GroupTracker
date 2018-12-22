import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsData{
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference usersRef = FirebaseDatabase.instance.reference().child('users');
  DatabaseReference requestsRef = FirebaseDatabase.instance.reference().child('requests');
  DatabaseReference friendsRef;

  FirebaseUser currentUser;

  getFriends() async {
    currentUser = await auth.currentUser();
    List friends;

    await usersRef.child(currentUser.uid).once().then((DataSnapshot snap){
      final userData = snap.value as Map;

      if (userData['friends'] != null){
          friendsRef = usersRef.child(currentUser.uid).child('friends');
          friends = _toList(userData['friends']);
      }
    });

    return friends;
  }

  List _toList(Map data){
      List friends = List();

      data.forEach((key, val){
        friends.add({'uid':key, 'username':val['username'], 'email':val['email']});
      });

      return friends;
  }

  searchPeople(String query) async {
    List<Map> searchItems = List();
    List sentRequestKeys;
    List recievedRequestKeys;
    List friendKeys;

    // Do not include users in search if they already have been requested, or have requested the current user
      await requestsRef.child(currentUser.uid).child('sent').once().then((DataSnapshot snap){
        sentRequestKeys = (snap.value as Map)?.keys?.toList() ?? List();
      });

      await requestsRef.child(currentUser.uid).child('recieved').once().then((DataSnapshot snap){
        recievedRequestKeys = (snap.value as Map)?.keys?.toList() ?? List();
      });

    // Do not include users that are already friends in the search results
      await usersRef.child(currentUser.uid).child('friends').once().then((DataSnapshot snap){
        friendKeys = (snap.value as Map)?.keys?.toList() ?? List();
      });

    await usersRef.once().then((DataSnapshot snap){
      final users = snap.value as Map;
      
      users.forEach((key, value){
        String email = users[key]['email'].toString().toLowerCase();
        String username = users[key]['username'].toString().toLowerCase();

        if (username.contains(query.toLowerCase()) || email.contains(query.toLowerCase())){
          Map searchItem = {'uid': key, 'username': users[key]['username'], 'email': users[key]['email']};
          searchItems.add(searchItem);
        }
      });
    });

    return _validateSearch(searchItems, recievedRequestKeys, sentRequestKeys, friendKeys);
  }

  _validateSearch(List<Map> searchItems, List recievedRequestKeys, List sentRequestKeys, List friendKeys){
    List<Map> filteredSearch = searchItems.toList();

    searchItems.forEach((item){

      if (item['uid'] == currentUser.uid){
        filteredSearch.remove(item);
      }

      recievedRequestKeys.forEach((recievedKey){
        if (item['uid'] == recievedKey){
          filteredSearch.remove(item);          
        }
      });

      sentRequestKeys.forEach((sentKey){
        if (item['uid'] == sentKey){
          filteredSearch.remove(item);
        }
      });

      friendKeys.forEach((friendKey){
        if (item['uid'] == friendKey){
          filteredSearch.remove(item);
        }
      });
    });

    return filteredSearch;
  }

  removeFriend(String uid) async {
    if (friendsRef != null){

      // Delete friend from current user's list
      await friendsRef.once().then((DataSnapshot snap){
        final friends = snap.value as Map;

        friends.forEach((key, value){
          if (key == uid){
            friendsRef.child(key).remove();
          }
        });
      });

      // Delete current user from other friend's list
      await usersRef.once().then((DataSnapshot snap){
        final users = snap.value as Map;

        users.forEach((key, val){
          if (key == uid){
            final friends = users[key]['friends'] as Map;

            if (friends != null){
              friends.forEach((friendKey,friendVal){
                if (friendKey == currentUser.uid){
                  usersRef.child(key).child('friends').child(currentUser.uid).remove();
                }
              });
            }
          }
        });
      });
    }

    return;
  }  

  sendFriendRequest(String uid, String username, String email) async {
    Map userDetails;

    await usersRef.child(currentUser.uid).once().then((DataSnapshot snap){
      userDetails = snap.value as Map;
    });

    // Save request to current users's "sent requests"
    await requestsRef.child(currentUser.uid).child('sent').child(uid).set({
      'username':username,
      'email':email,
    });

    // Save request to other user's "recieved requests"
    await requestsRef.child(uid).child('recieved').child(currentUser.uid).set({
      'username':userDetails['username'],
      'email':userDetails['email'],
    });

    return;
  }
}