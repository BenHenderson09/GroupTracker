import 'package:flutter/material.dart';

import '../../Theme/colour_theme.dart';
import './tracking_data.dart';

class Tracking extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return TrackingState();
  }
}

class TrackingState extends State<Tracking>{
  TrackingData _trackingData = TrackingData();
  bool _checkLoading = false;
  List _friends;

  @override
  void initState(){
    _trackingData.getFriends().then((friends){
      setState(() {
        if (friends != null){
          _friends = friends;    
        }
        else{
          _friends = List();
        }   
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Center(
          child: ListView(
            physics: NeverScrollableScrollPhysics(),
            children:<Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 0.0),
                    child: Column(
                      children: <Widget>[

                        Divider(
                          color: Colors.grey[500],
                        ),

                        Text(
                          "Tracked Users",
                          style: TextStyle(
                            fontSize: 30.0,
                            color: Colors.grey[700]
                          ),
                        ),

                        Divider(
                          color: Colors.grey[500],
                        ),

                      ],
                    ),
                  ),
                  
                  _body(),
                ],
              )
            ]
        ),
    );
  }

  Widget _body(){
    if (_friends == null){
      return Padding(
        padding: EdgeInsets.all(30.0),
        child: CircularProgressIndicator()
      );
    }
    else if (_friends.length == 0){
      return Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          "Make some friends first!",
          style: TextStyle( 
            fontSize: 20.0,
            fontWeight: FontWeight.w400,
            color: Colors.grey[500]
          ),
        ),
      );
    }

    return ConstrainedBox(
          child: _trackList(),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
        );
  }

  Widget _trackList(){
    return ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (BuildContext ctx, int index){

        return Row(
          children:<Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(5.0, 0.5, 5.0, 0.5),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Card(
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
                                    _friends[index]['username'][0].toUpperCase(),
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
                                      _friends[index]['username'],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 23.0,
                                      ),
                                    ),
                                    Text(
                                      _friends[index]['email'],
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

                        Checkbox(
                          activeColor: ColourTheme.theme['normal'] == Colors.blue ? Colors.green : Colors.blue,
                          value: _friends[index]['tracking'] ?? false,

                          onChanged: (bool val){ 
                            setState(() {
                              _checkLoading = true;                     
                            });
                            
                            _trackingData.setTracked(_friends[index]['uid'], !_friends[index]['tracking']).then((_){
                              setState(() {
                                _friends[index]['tracking'] = !_friends[index]['tracking'];
                                _checkLoading = false;
                              });
                            });
                          },
                        )
                      ]
                    ),
                  ),

                  (){
                    if (_checkLoading){
                      return Stack(
                        children: <Widget>[
                          Positioned(
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircularProgressIndicator(),
                            )
                          )
                          
                        ],
                      );
                    }
                    return Container();
                  }()
                ],
              )
             ),
            ]
          );
        }
      );
  }
}
