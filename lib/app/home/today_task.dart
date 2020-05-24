import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:todoist/app/landing_page.dart';
import 'package:todoist/app/lists/add_list_page.dart';

class TodaysTasks extends StatefulWidget {
  @override
  _TodaysTasksState createState() => _TodaysTasksState();
}

class _TodaysTasksState extends State<TodaysTasks> {
  SharedPreferences sharedPreference;
  List finalData = [];
  TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    listOfTasks();
  }

  void _addNewTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) {
            return AddListPage();
          }),
    );
  }

  listOfTasks() async {
    String validateUrl = "http://192.168.0.103/auth_api/api/validate_token.php";
    sharedPreference = await SharedPreferences.getInstance();
    String jwtToken = sharedPreference.getString("token");
    Map data = {"jwt": jwtToken};
    var jsonDataEncode = jsonEncode(data);
    var response =
        await http.post(Uri.encodeFull(validateUrl), body: jsonDataEncode);
    if (response.statusCode == 200) {
      var userDataDecoded = jsonDecode(response.body);
      Map userData = userDataDecoded["data"];
      String uid = userData["id"];
      String displayTaskUrl =
          "http://192.168.0.103/auth_api/api/user_stats.php";
      Map dataId = {"uid": uid};
      var jsonDataId = jsonEncode(dataId);
      var displayResponse =
          await http.post(Uri.encodeFull(displayTaskUrl), body: jsonDataId);
      if (displayResponse.statusCode == 200) {
        print(displayResponse.body);
        setState(() {
          finalData = jsonDecode(
              displayResponse.body.toString().substring(15))["allTasksdata"];
          for (var instance in finalData) {
            DateTime date = DateTime.parse(instance["date_time"]);
            DateTime now = DateTime.now();
            if (date.day != now.day ||
                date.month != now.month ||
                date.year != now.year) {
              instance["date_time"] = "not today";
            }
          }
        });
        print(finalData);
      }
    }
  }

  checkLoginStatus() async {
    sharedPreference = await SharedPreferences.getInstance();
    if (sharedPreference.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LandingPage()),
          (Route<dynamic> route) => false);
    }
  }

  void _delete(String id) async {
    Map data = {"id": id};
    var jsonData = jsonEncode(data);
    String deleteUrl = "http://192.168.0.103/auth_api/api/delete_task.php";
    var response = await http.post(Uri.encodeFull(deleteUrl), body: jsonData);
    if (response.statusCode == 200) {
      print(response.body);
      await listOfTasks();
    }
  }

  void _updateTask(Map data) async {
    var updateJsonData = jsonEncode(data);
    String url = "http://192.168.0.103/auth_api/api/update_task.php";
    var response = await http.post(Uri.encodeFull(url), body: updateJsonData);
    if (response.statusCode == 200) {
      print(response.body);
      await listOfTasks();
    }
  }

  void _starTask(Map data) async {
    var updateJsonData = jsonEncode(data);
    String url = "http://192.168.0.103/auth_api/api/star_task.php";
    var response = await http.post(Uri.encodeFull(url), body: updateJsonData);
    if (response.statusCode == 200) {
      print(response.body);
      await listOfTasks();
    }
  }

  void _completeTask(Map data) async {
    var updateJsonData = jsonEncode(data);
    String url = "http://192.168.0.103/auth_api/api/complete_task.php";
    var response = await http.post(Uri.encodeFull(url), body: updateJsonData);
    if (response.statusCode == 200) {
      print(response.body);
      await listOfTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Todays Tasks',
          style: TextStyle(
            color: Colors.teal,
            fontSize: 25,
          ),
        ),
      ),
      body: finalData.isEmpty
          ? _emptyPageContent()
          : SafeArea(
              child: ListView.builder(
                itemCount: finalData.length,
                itemBuilder: (BuildContext context, index) {
                  return finalData[index]["date_time"] == "not today"
                      ? Container()
                      : Dismissible(
                          key: Key('task-${DateTime.now()}'),
                          background: Container(color: Colors.red),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) =>
                              _delete(finalData[index]["id"]),
                          child: ListTile(
                            leading: FlatButton(
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 11,
                                  backgroundColor:
                                      finalData[index]["status"] == "0"
                                          ? Colors.black
                                          : Colors.teal,
                                ),
                              ),
                              onPressed: () {
                                if (finalData[index]["status"] == "0") {
                                  _completeTask({
                                    "id": finalData[index]["id"],
                                    "status": "1"
                                  });
                                } else {
                                  _completeTask({
                                    "id": finalData[index]["id"],
                                    "status": "0"
                                  });
                                }
                              },
                            ),
                            title: finalData[index]["status"] == "1"
                                ? Text('${finalData[index]["task"]}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        decoration: TextDecoration.lineThrough))
                                : Text('${finalData[index]["task"]}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18)),
                            trailing: FlatButton(
                              child: Icon(
                                Icons.star,
                                color: finalData[index]["priority"] == "0"
                                    ? Colors.grey[300]
                                    : Colors.teal,
                              ),
                              onPressed: () {
                                if (finalData[index]["priority"] == "0") {
                                  _starTask({
                                    "id": finalData[index]["id"],
                                    "priority": "1"
                                  });
                                } else {
                                  _starTask({
                                    "id": finalData[index]["id"],
                                    "priority": "0"
                                  });
                                }
                              },
                            ),
                            onTap: () {
                              _controller = new TextEditingController(
                                  text: '${finalData[index]["task"]}');
                              _updateTaskDialog(finalData[index]["id"]);
                            },
                          ),
                        );
                },
              ),
            ),
      floatingActionButton: FlatButton(
        child: Row(
          children: <Widget>[
            Icon(
              Icons.add_circle_outline,
              color: Colors.tealAccent,
            ),
            Text(
              'Add new task',
              style: TextStyle(color: Colors.tealAccent),
            ),
          ],
        ),
        onPressed: _addNewTask,
      ),
    );
  }

  Widget _emptyPageContent() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Nothing Here',
                style: TextStyle(fontSize: 45, color: Colors.grey)),
            Text('Add new task',
                style: TextStyle(fontSize: 25, color: Colors.grey))
          ],
        ),
      ),
    );
  }

  void _updateTaskDialog(String id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Update task",
                      style: TextStyle(color: Colors.teal, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      cursorColor: Colors.black,
                      style: TextStyle(color: Colors.black),
                      controller: _controller,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[400],
                          border: InputBorder.none,
                          hintText: 'Task'),
                      onSubmitted: (value) {
                        print("value = $value");
                        _updateTask({"id": id, "task": "$value"});
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 320.0,
                      child: RaisedButton(
                        onPressed: () {
                          print('text = ${_controller.text}');
                          _updateTask(
                              {"id": id, "task": "${_controller.text}"});
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.teal,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
