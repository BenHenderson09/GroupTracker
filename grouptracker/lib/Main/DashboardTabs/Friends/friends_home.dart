import 'package:flutter/material.dart';

import './FriendsTab/friends.dart';
import './RequestsTab/requests.dart';

class FriendsHome extends StatefulWidget{
  @override
  State<StatefulWidget> createState(){
    return FriendsHomeState();
  }
}

class FriendsHomeState extends State<FriendsHome>{

  final tab = TabBar(tabs: <Tab>[
    Tab(icon: Icon(Icons.arrow_forward)),
    Tab(icon: Icon(Icons.arrow_downward)),
    Tab(icon: Icon(Icons.arrow_back)),
  ]);

  @override
  Widget build(BuildContext context){
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight/1.7),
          child: Container(
            color: Colors.grey[200],
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(child: Container()),
                  TabBar(
                    tabs: [
                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child:Text(
                          "Friends",
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600]
                          ),
                        ),
                      ),
                      
                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child:Text(
                          "Requests",
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600]

                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Friends(),
            Requests()
          ],
        ),
      ),
    );
  }
}