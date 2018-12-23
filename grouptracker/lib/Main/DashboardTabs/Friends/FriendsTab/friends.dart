import 'package:flutter/material.dart';

import './friends_data.dart';
import '../../../Theme/colour_theme.dart';

class Friends extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return FriendsState();
  }
}

class FriendsState extends State<Friends>{
  final TextEditingController _searchTextController = TextEditingController();
  final FriendsData _friendsData = FriendsData();
  List _friends;

  List _searchItems = List();
  bool _searching = false;


  @override
  void initState(){
    _setFriends();
    super.initState();
  }

  void _setFriends(){
    _friends = null;
    _searchItems = null;

    _friendsData.getFriends().then((friends){
       setState(() {
          if (friends != null){
            _friends = friends;
          } 
          else {
            _friends = List();
          }
        });
      });
  }

  @override
  void dispose(){
    _searchTextController.dispose();
    super.dispose();
  }

  void _search(String query) async {
    if (query != ''){
        setState(() {
          _searching = true;
        });
      
      await _friendsData.searchPeople(query).then((items){
        setState(() {
          _searchItems = items/*_validateSearch(items)*/;
          _searching = false;    
        });
      });
    }
    else {
      _searchItems.clear();
    }
  }

  List _validateSearch(List items){
    List filteredItems = List();

    items.forEach((item){
        final bool friend = (){
          bool isFriend = false;

          _friends.forEach((friend){
            if (item['uid'] == friend['uid']){
              isFriend = true;
            }
          });
          
          return isFriend;
        }();

        // Add to list if the user is not already a friend.
        if (!friend) filteredItems.add(item);
    });

    return filteredItems;
  }
  
  @override
  Widget build(BuildContext context){
    if (_friends == null){ // If no friends in db, _friends is initialized as empty list. Will be null until callback.
      return Center(
        child: CircularProgressIndicator()
      );
    }

    return ListView(
            physics: NeverScrollableScrollPhysics(),
            children:<Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:<Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                        child: Column(
                          children: <Widget>[
                            Card(
                              child: ListTile(

                                leading: IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: () => _search(_searchTextController.text),
                                ),

                                title: TextField(
                                    decoration: InputDecoration(hintText: 'Search', border: InputBorder.none),
                                    controller: _searchTextController,
                                    onSubmitted: (String text) => _search(text),
                                ),
                                
                                trailing: IconButton(
                                  icon: Icon(Icons.cancel),
                                  onPressed: (){
                                    setState(() {
                                      _searchTextController.text = "";
                                      _searchItems.clear();                        
                                    });
                                  },
                                ),
                              ),
                            ),
                          ]
                        )
                      ),
                    ),
                    _body()
                ],
            ),
        ]
    );
  }

  Widget _body(){
    return Column(
      children: <Widget>[
        _searchBody(),
        _peopleBody()
      ],
    );
  }

  Widget _searchBody(){
    if (_searching){
      return CircularProgressIndicator();
    }
    else if (_searchItems != null && _searchItems.length > 0){
        return Column(
        children: <Widget>[
          Center(
            child: Column(
            children: <Widget>[
                Divider(
                  color: Colors.grey[500],
                ),
                Text(
                  "Search Results",
                ),
                Divider(
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),

          ConstrainedBox(
            child: _searchList(_searchItems),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height),
          )
        ],
      );
    }
    return Container();
  }

  Widget _peopleBody(){
    return Column(
      children: <Widget>[
        (){
          if (_friends != null && _friends.length > 0){
            return Center(
              child: Column(
              children: <Widget>[
                  Divider(
                    color: Colors.grey[600],
                  ),
                ],
              ),
            );
          } 
          else if (_friends.length == 0){
            return Center(
              heightFactor: 1.0,
              child: Text(
                  "Search for some friends!",
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[500]
                  ),
                )
            );
          }
          return Container();
        }(),

        ConstrainedBox(
          child: _peopleList(_friends),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height),
        )
      ],
    );
  }

  Widget _peopleList(friends){
    if (friends != null && friends.length > 0){
      return ListView.builder(
        itemCount: friends.length,
        itemBuilder: (BuildContext ctx, int index){

          return Row(
            children:<Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(5.0, 0.5, 5.0, 0.5),
                width: MediaQuery.of(context).size.width,
                child:Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircleAvatar(
                                backgroundColor: ((){
                                  if (ColourTheme.theme['normal'] == Colors.blue){
                                    return Colors.green;
                                  }
                                    return Colors.blue;
                                }()),
                                minRadius: 25.0,

                                child: Text(
                                  friends[index]['username'][0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 30.0
                                  ),
                                ),
                              ),
                            ),
                            
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    friends[index]['username'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 23.0,
                                    ),
                                  ),
                                  Text(
                                    friends[index]['email'],
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.grey[500],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ),

                    Container(
                      width: 30.0,
                      margin: EdgeInsets.all(5.0),
                      child: FloatingActionButton(
                        child: Text(
                          "-",
                          style: TextStyle(
                            fontSize: 20.0
                          ),
                        ),
                        backgroundColor: Colors.red,
                        onPressed: (){
                          // Ask user before deleting friend
                          showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return AlertDialog(
                                title: Text(
                                  "Remove friend",
                                  textAlign: TextAlign.center,
                                ),
                                content: Text(
                                  "By performing this action you will remove the selected friend. "+
                                  "This will prevent both of you from accessing each other's location."
                                  ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("Remove User"),
                                    onPressed: () {
                                      _friendsData.removeFriend(friends[index]['uid']).then((_){
                                        Navigator.of(context).pop();
                                        _setFriends();
                                      });
                                    }
                                  ),
                                ],
                              );
                            }
                          );        
                        },
                      )
                    )
                  ]
                ),
              ),
             )
            ]
          );
        }
      );
    }
    return Container();
  }

Widget _searchList(searchItems){
  return ListView.builder(
    itemCount: searchItems.length,
    itemBuilder: (BuildContext ctx, int index){
      return Row(
            children:<Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(5.0, 0.5, 5.0, 0.5),
                width: MediaQuery.of(ctx).size.width,
                child:Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircleAvatar(
                                backgroundColor: ((){
                                  if (ColourTheme.theme['normal'] == Colors.blue){
                                    return Colors.green;
                                  }
                                    return Colors.blue;
                                }()),
                                minRadius: 25.0,

                                child: Text(
                                  searchItems[index]['username'][0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 30.0
                                  ),
                                ),
                              ),
                            ),
                            
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    searchItems[index]['username'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 23.0,
                                    ),
                                  ),
                                  Text(
                                    searchItems[index]['email'],
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.grey[500],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      ),

                    Container(
                      width: 30.0,
                      margin: EdgeInsets.all(5.0),
                      child: FloatingActionButton(
                        child: Text(
                          "+",
                          style: TextStyle(
                            fontSize: 20.0
                          ),
                        ),
                        backgroundColor: Colors.green,
                        onPressed: (){
                          showDialog(
                            context: ctx,
                            builder: (BuildContext context){
                              return AlertDialog(
                                title: Text(
                                  "Send friend request?",
                                  textAlign: TextAlign.center,
                                ),
                                content: Text(
                                  "By performing this action you will send a friend request to the selected user. "+
                                  "If they accept the request, you will both have access to each other's location and will become friends."
                                  ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("Send Request"),
                                    onPressed: () {
                                      _friendsData
                                      .sendFriendRequest(_searchItems[index]['uid'],
                                                     _searchItems[index]['username'],
                                                     _searchItems[index]['email'],).then((_){

                                        Navigator.of(context).pop();
                                        _setFriends();
                                      });
                                    }
                                  ),
                                ],
                              );
                            }
                          );   
                        },
                      )
                    )
                  ]
                ),
              ),
             )
           ]
          );
        },
      );
    }
  }