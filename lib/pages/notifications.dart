import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sgny/utils/timeAgoCalculator.dart';

class Notifications extends StatefulWidget{
  
  @override
  State<StatefulWidget> createState() {
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.deepPurpleAccent, // Color for Android
                statusBarBrightness: Brightness.light // Dark == white status bar -- for IOS.
              ));
    } else if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.white, // Color for Android
                statusBarBrightness: Brightness.light // Dark == white status bar -- for IOS.
              ));
    }
    return _NotificationsState();
  }

}

class _NotificationsState extends State<Notifications>{

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  TimeAgoCalculator timeAgo = new TimeAgoCalculator();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: Center(
        child: notificationsList(context),
    ));
  }

  Widget notificationsList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("notifications").orderBy("timestamp", descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(!snapshot.hasData){
          return CircularProgressIndicator();
        } else {
          return renderNotificationsList(snapshot);
        }
      },
    );
  }

  renderNotificationsList(AsyncSnapshot<QuerySnapshot> snapshot){
      return CustomScrollView(
        slivers: <Widget>[
          snapshot.data.documents.length == 0
            ? SliverFillRemaining(
              child:Card(
                child: Center(
                  child: Text("No notifications available!!"),
                ),
              ))
        : SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Card(
                child: new Container(
                  padding: EdgeInsets.all(10.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          notificationIcon(),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(snapshot.data.documents[index]["event"] != null ?
                                    snapshot.data.documents[index]["event"]:"",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepPurpleAccent
                                    )),
                                ),
                                displayTimeAgo(snapshot.data.documents[index]["timestamp"]),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(snapshot.data.documents[index]["title"] != null ?
                                  snapshot.data.documents[index]["title"]:"",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.blueGrey
                                    )),
                                ),
                              ],
                            ),
                            Text(snapshot.data.documents[index]["body"]),
                          ],
                        )
                      )
                    ],
                  )
                ),
              );
            },
            childCount: snapshot.data.documents.length
            ),
          )
        ],
      );
  }

  displayTimeAgo(Timestamp timestamp){
    return timestamp != null ? Text(
            timeAgo.calculate(timestamp.toDate()),
            style: TextStyle(
              fontStyle: FontStyle.italic
            ),
          ) : Text("");
  }

  notificationIcon(){
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Image.asset(
                 "assets/images/notification.png",
                width: 30,
              ));
  }

}