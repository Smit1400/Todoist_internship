import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class BlockedUserPage extends StatefulWidget {
  final Function totalUser;

  const BlockedUserPage({Key key, @required this.totalUser}) : super(key: key);

  @override
  _BlockedUserPageState createState() => _BlockedUserPageState();
}

class _BlockedUserPageState extends State<BlockedUserPage> {
  List totalBlockedUser = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listOfBlockedUser();
  }

  listOfBlockedUser() async {
    String url = "http://192.168.0.104/auth_api/api/admin_stats.php";
    Map data = {"id": "2"};
    var jsonData = jsonEncode(data);
    var response = await http.post(Uri.encodeFull(url), body: jsonData);
    if (response.statusCode == 200) {
      var finalData = jsonDecode(response.body.substring(15));
      print(finalData);
      setState(() {
        totalBlockedUser = finalData["allBLockedUsersdata"];
      });
    }
  }

  void updateUserStatus(String id, String username) async {
    String url = "http://192.168.0.104/auth_api/api/status_user.php";
    print("id = $id");
    Map data = {"id": id, "status": "1"};
    var jsonData = jsonEncode(data);
    var response = await http.post(Uri.encodeFull(url), body: jsonData);
    if (response.statusCode == 200) {
      print(response.body);
      listOfBlockedUser();
      Toast.show('$username is removed from blocked list', context,
          gravity: Toast.TOP, backgroundColor: Colors.green);
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
        itemCount: totalBlockedUser.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: FlatButton(
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 11,
                  backgroundColor: totalBlockedUser[index]["status"] == "0"
                      ? Colors.black
                      : Colors.teal,
                ),
              ),
              onPressed: () {
                // setState(() {
                //   totalBlockedUser[index]["status"] = "1";
                // });
                updateUserStatus(totalBlockedUser[index]["id"],
                    totalBlockedUser[index]["username"]);
              },
            ),
            title: Text(
              '${totalBlockedUser[index]["username"]}',
              style: TextStyle(
                color: Colors.tealAccent,
                fontSize: 17,
              ),
            ),
            subtitle: Text(
              '${totalBlockedUser[index]["email"]}',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
