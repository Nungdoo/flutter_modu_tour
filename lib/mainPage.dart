import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'main/favoritePage.dart';
import 'main/mapPage.dart';
import 'main/settingPage.dart';
import 'package:sqflite/sqflite.dart';

class MainPage extends StatefulWidget {
  final Future<Database> database;
  MainPage(this.database);

  @override
  State<StatefulWidget> createState() => _MainPage();
}

class _MainPage extends State<MainPage> with SingleTickerProviderStateMixin{
  TabController? controller;
  FirebaseDatabase? _database;
  DatabaseReference? reference;
  String _databaseURL = 'https://modu-tour-df958-default-rtdb.firebaseio.com/';
  String? id;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    _database = FirebaseDatabase(databaseURL: _databaseURL);
    reference = _database!.reference();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 로그인할 때 전달받은 아이디값 저장
    id = ModalRoute.of(context)!.settings.arguments as String?;
    return Scaffold(
      body: TabBarView(
        children: <Widget>[
          MapPage(
            databaseReference: reference,
            db: widget.database,
            id: id,
          ),
          FavoritePage(
            databaseReference: reference,
            db: widget.database,
            id: id,
          ),
          SettingPage(
            databaseReference: reference,
            id: id
          ),
        ],
        controller: controller,
      ),
      bottomNavigationBar: TabBar(
        tabs: <Tab>[
          Tab(icon: Icon(Icons.map),),
          Tab(icon: Icon(Icons.star),),
          Tab(icon: Icon(Icons.settings),),
        ],
        labelColor: Colors.amber,
        indicatorColor: Colors.deepOrangeAccent,
        controller: controller,
      ),
    );
  }
}