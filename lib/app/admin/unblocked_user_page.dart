import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class UnBlockedUserPage extends StatefulWidget {
  final Function totalUser;

  const UnBlockedUserPage({Key key, @required this.totalUser})
      : super(key: key);
  @override
  _UnBlockedUserPageState createState() => _UnBlockedUserPageState();
}

class _UnBlockedUserPageState extends State<UnBlockedUserPage> {
  List totalUnBlockedUser = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listOfUnBlockedUser();
  }

  listOfUnBlockedUser() async {
    String url = "http://192.168.0.104/auth_api/api/admin_stats.php";
    Map data = {"id": "2"};
    var jsonData = jsonEncode(data);
    var response = await http.post(Uri.encodeFull(url), body: jsonData);
    if (response.statusCode == 200) {
      var finalData = jsonDecode(response.body.substring(15));
      print(finalData);
      setState(() {
        totalUnBlockedUser = finalData["allUnblockedUsersdata"];
      });
    }
  }

  void updateUserStatus(String id, String username) async {
    String url = "http://192.168.0.104/auth_api/api/status_user.php";
    print("id = $id");
    Map data = {"id": id, "status": "0"};
    var jsonData = jsonEncode(data);
    var response = await http.post(Uri.encodeFull(url), body: jsonData);
    if (response.statusCode == 200) {
      print(response.body);
      listOfUnBlockedUser();
      Toast.show(
        '$username is Blocked', context,
        gravity: Toast.TOP,
        backgroundColor: Colors.red,
        // textColor: Colors.black
      );
      widget.totalUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Blocked Users'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Container(),
        ),
      ),
      body: ListView.builder(
        itemCount: totalUnBlockedUser.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: FlatButton(
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 11,
                  backgroundColor: totalUnBlockedUser[index]["status"] == "0"
                      ? Colors.black
                      : Colors.teal,
                ),
              ),
              onPressed: () {
                // setState(() {
                //   totalBlockedUser[index]["status"] = "1";
                // });
                updateUserStatus(totalUnBlockedUser[index]["id"],
                    totalUnBlockedUser[index]["username"]);
              },
            ),
            title: Text(
              '${totalUnBlockedUser[index]["username"]}',
              style: TextStyle(
                color: Colors.tealAccent,
                fontSize: 17,
              ),
            ),
            subtitle: Text(
              '${totalUnBlockedUser[index]["email"]}',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
