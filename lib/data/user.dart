import 'package:firebase_database/firebase_database.dart';

class User {
  String? id;
  String? pw;
  String? createTime;

  User(this.id, this.pw, this.createTime);

  User.fromSnapshot(DataSnapshot snapshot) {
    var data = snapshot.value as Map?;
    if (data != null) {
      id = data['id'];
      pw = data['pw'];
      createTime = data['createTime'];
    }
  }

  toJson() {
    return {
      'id': id,
      'pw': pw,
      'creatTime': createTime,
    };
  }
}