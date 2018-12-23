import 'package:flutter/material.dart';

import './requests_data.dart';
import '../../../Theme/colour_theme.dart';

class Requests extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return RequestsState();
  }
}

class RequestsState extends State<Requests>{
  final RequestsData _requestsData = RequestsData();
  List _recievedRequests;
  List _sentRequests;

  @override
  void initState(){
    _setRequestData();
    super.initState();
  }

  void _setRequestData(){
    _recievedRequests = null;
    _sentRequests = null;

    _requestsData.getRecievedRequests().then((requests){
      setState(() {
        if (requests != null){
          _recievedRequests = requests;
        }        
        else {
          _recievedRequests = List();
        }
      });
    });

    _requestsData.getSentRequests().then((requests){
       setState(() {
        if (requests != null){
          _sentRequests = requests;
        }        
        else {
          _sentRequests = List();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return ListView(
      children: <Widget>[
        _body()  
      ],
    );
  }

  Widget _body(){
    return Column(
      children: <Widget>[
        Center(
          child: Column(
            children: <Widget>[
              Divider(color: Colors.grey[500]),
              Text(
                "Friend Requests",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              Divider(color: Colors.grey[500]),
            ],
          )
        ),

        ConstrainedBox(
          child: _recievedRequestsList(),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
        ),

        Center(
          child: Column(
            children: <Widget>[
              Divider(color: Colors.grey[500],),
              Text(
                "Your Pending Requests",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              Divider(color: Colors.grey[500],),
            ],
          )
        ),

        ConstrainedBox(
          child: _sentRequestsList(),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
        ),
      ],
    );
  }

  Widget _recievedRequestsList(){
    if (_recievedRequests == null){
      return CircularProgressIndicator();
    }
    if (_recievedRequests.length == 0){
      return Padding(
        child: Text(
          "No friend requests yet",
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.grey[600]
          ) 
        ),
        padding: EdgeInsets.all(20.0),
      );
    }
    return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _recievedRequests.length,
          itemBuilder: (BuildContext context, int index){
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
                                  _recievedRequests[index]['username'][0].toUpperCase(),
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
                                    _recievedRequests[index]['username'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 23.0,
                                    ),
                                  ),
                                  Text(
                                    _recievedRequests[index]['email'],
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

                      Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(5.0),
                            width: 30.0,
                            child: FloatingActionButton(
                              child: Text(
                                "-",
                                style: TextStyle(
                                  fontSize: 20.0
                                ),
                              ),
                              backgroundColor: Colors.red,
                              onPressed: (){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context){
                                    return AlertDialog(
                                      title: Text(
                                        "Reject Request?",
                                        textAlign: TextAlign.center,
                                      ),
                                      content: Text(
                                        "By performing this action you will reject the friend request. "+
                                        "This means that the user will not gain access to your location and will " +
                                        "not be saved as a friend."
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        FlatButton(
                                          child: Text("Reject Request"),
                                          onPressed: () {
                                            _requestsData
                                            .handleRequest(
                                                          false, 
                                                          _recievedRequests[index]['uid'],
                                                          _recievedRequests[index]['username'],
                                                          _recievedRequests[index]['email'],).then((_){

                                              Navigator.of(context).pop();
                                              _setRequestData();
                                            });
                                          }
                                        ),
                                      ],
                                    );
                                  }
                                );        
                              },
                            ),
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
                                  context: context,
                                  builder: (BuildContext context){
                                    return AlertDialog(
                                      title: Text(
                                        "Accept Request?",
                                        textAlign: TextAlign.center,
                                      ),
                                      content: Text(
                                        "By performing this action you will become a friend of the selected user. "+
                                        "This will allow both of you to access each other's location"
                                        ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        FlatButton(
                                          child: Text("Accept Request"),
                                          onPressed: () {
                                            _requestsData.handleRequest(
                                                          true, 
                                                          _recievedRequests[index]['uid'],
                                                          _recievedRequests[index]['username'],
                                                          _recievedRequests[index]['email'],).then((_){

                                              Navigator.of(context).pop();
                                              _setRequestData();
                                            });
                                          }
                                        ),
                                      ],
                                    );
                                  }
                                );        
                              },
                            ),
                          ),
                        ],
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

  Widget _sentRequestsList(){
    if (_sentRequests == null){
      return CircularProgressIndicator();
    }
    if (_sentRequests.length == 0){
      return Padding(
        child: Text(
          "No pending friend requests",
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.grey[600]
          ) 
        ),
        padding: EdgeInsets.all(20.0),
      );
      
    }
    return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _sentRequests.length,
          itemBuilder: (BuildContext context, int index){
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
                                  _sentRequests[index]['username'][0].toUpperCase(),
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
                                    _sentRequests[index]['username'],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 23.0,
                                    ),
                                  ),
                                  Text(
                                    _sentRequests[index]['email'],
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
                      width: 100.0,
                      margin: EdgeInsets.all(5.0),
                      child: RaisedButton(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 15.0
                          ),
                        ),

                        color: Colors.red,
                        textColor: Colors.white,
                        onPressed: (){
                          showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return AlertDialog(
                                title: Text(
                                  "Cancel Request?",
                                  textAlign: TextAlign.center,
                                ),
                                content: Text(
                                  "By performing this action you will remove the selected request. "+
                                  "This will remove the request from your list and the other user's list."
                                  ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("Remove Request"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _requestsData.cancelRequest(_sentRequests[index]['uid']).then((_){
                                        _setRequestData();
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