import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoist/app/home/datetime_sorted_task.dart';
import 'package:todoist/app/home/today_task.dart';
import 'package:todoist/app/lists/display_list_of_user.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences sharedPreference;
  int allTasksOfUser = 0;
  @override
  void initState() {
    super.initState();
    totalTasks();
  }

  void totalTasks() async {
    String validateUrl =
        "https://todoistapi.000webhostapp.com/validate_token.php";
    sharedPreference = await SharedPreferences.getInstance();
    String jwtToken = sharedPreference.getString("token");
    Map data = {"jwt": jwtToken};
    var jsonDataEncode = jsonEncode(data);
    var validateResponse =
        await http.post(Uri.encodeFull(validateUrl), body: jsonDataEncode);
    if (validateResponse.statusCode == 200) {
      var userDataDecoded = jsonDecode(validateResponse.body);
      Map userData = userDataDecoded["data"];
      String uid = userData["id"];
      String url = "https://todoistapi.000webhostapp.com/user_stats.php";
      Map data = {"uid": uid};
      var jsonData = jsonEncode(data);
      var response = await http.post(Uri.encodeFull(url), body: jsonData);
      if (response.statusCode == 200) {
        print(response.body);
        var finalData = jsonDecode(response.body);
        setState(() {
          allTasksOfUser = finalData["allTasksOfUser"];
        });
        // setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        centerTitle: true,
        titleSpacing: 1.0,
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 4,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'All Tasks',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            "$allTasksOfUser",
                            textAlign: TextAlign.start,
                          )
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              DisplayListOfUser.create(context),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 4,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Todays\'s tasks',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            "$allTasksOfUser",
                            textAlign: TextAlign.start,
                          )
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              DisplayListOfUser.create(context, today: true),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 4,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Prioritized task',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            "$allTasksOfUser",
                            textAlign: TextAlign.start,
                          )
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              DisplayListOfUser.create(context, priority: true),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
