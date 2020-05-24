import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:todoist/app/landing_page.dart';
import 'package:todoist/app/lists/add_list_page.dart';
import 'package:http/http.dart' as http;

class DisplayListOfUser extends StatefulWidget {
  // final String
  // final Function totalTasks;
  // DisplayListOfUser({@required this.totalTasks});
  @override
  _DisplayListOfUserState createState() => _DisplayListOfUserState();
}

class _DisplayListOfUserState extends State<DisplayListOfUser> {
  SharedPreferences sharedPreference;
  List finalData = [];
  TextEditingController _controller;
  bool sorted = false;
  bool loading = false;
  void _addNewTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) {
            return AddListPage();
          }),
    );
  }

  @override
  void initState() {
    super.initState();

    checkLoginStatus();
    listOfTasks();
  }

  // this gives list of all the tasks by a user

  listOfTasks() async {
    setState(() {
      loading = true;
    });
    String validateUrl =
        "https://todoistapi.000webhostapp.com/validate_token.php";
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
          "https://todoistapi.000webhostapp.com/user_stats.php";
      Map dataId = {"uid": uid};
      var jsonDataId = jsonEncode(dataId);
      var displayResponse =
          await http.post(Uri.encodeFull(displayTaskUrl), body: jsonDataId);
      if (displayResponse.statusCode == 200) {
        print(displayResponse.body);
        setState(() {
          finalData = jsonDecode(
              displayResponse.body.toString().substring(30))["allTasksdata"];
          loading = false;
        });
        print(finalData);
      }
    }
  }

  // this checks the login status of the user
  checkLoginStatus() async {
    sharedPreference = await SharedPreferences.getInstance();
    if (sharedPreference.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LandingPage()),
          (Route<dynamic> route) => false);
    }
  }

  //this method deletes a particular task by a user
  void _delete(String id) async {
    setState(() {
      loading = true;
    });
    Map data = {"id": id};
    var jsonData = jsonEncode(data);
    String deleteUrl = "https://todoistapi.000webhostapp.com/delete_task.php";
    var response = await http.post(Uri.encodeFull(deleteUrl), body: jsonData);
    if (response.statusCode == 200) {
      print(response.body);
      await listOfTasks();
      if (sorted) {
        finalData = List.from(finalData.reversed);
      }
    }
    setState(() {
      loading = false;
    });
  }

  // this method updates the task name of the user
  void _updateTask(Map data) async {
    setState(() {
      loading = true;
    });
    var updateJsonData = jsonEncode(data);
    String url = "https://todoistapi.000webhostapp.com/update_task.php";
    var response = await http.post(Uri.encodeFull(url), body: updateJsonData);
    if (response.statusCode == 200) {
      print(response.body);
      await listOfTasks();
      if (sorted) {
        finalData = List.from(finalData.reversed);
      }
    }
    setState(() {
      loading = false;
    });
  }

  // this method is to set the priority of a task to 1
  void _starTask(Map data) async {
    setState(() {
      loading = true;
    });
    var updateJsonData = jsonEncode(data);
    String url = "https://todoistapi.000webhostapp.com/star_task.php";
    var response = await http.post(Uri.encodeFull(url), body: updateJsonData);
    if (response.statusCode == 200) {
      print(response.body);
      await listOfTasks();
      if (sorted) {
        finalData = List.from(finalData.reversed);
      }
    }
    setState(() {
      loading = false;
    });
  }

  // this method is to set the  of a task to completed
  void _completeTask(Map data) async {
    setState(() {
      loading = true;
    });
    var updateJsonData = jsonEncode(data);
    String url = "https://todoistapi.000webhostapp.com/complete_task.php";
    var response = await http.post(Uri.encodeFull(url), body: updateJsonData);
    if (response.statusCode == 200) {
      print(response.body);
      await listOfTasks();
      if (sorted) {
        finalData = List.from(finalData.reversed);
      }
    }
    setState(() {
      loading = false;
    });
  }

  void _timeWiseSortedTask() async {
    setState(() {
      loading = true;
    });
    await listOfTasks();
    setState(() {
      finalData = List.from(finalData.reversed);
      loading = false;
    });
  }

  void _todaysTask() async {
    setState(() {
      loading = true;
    });
    await listOfTasks();
    setState(() {
      for (var instance in finalData) {
        DateTime date = DateTime.parse(instance["date_time"]);
        DateTime now = DateTime.now();
        if (date.day != now.day ||
            date.month != now.month ||
            date.year != now.year) {
          instance["date_time"] = "not today";
        }
      }
      loading = false;
    });
  }

  void _allTasks() async {
    setState(() {
      loading = true;
    });
    await listOfTasks();
    setState(() {
      loading = false;
    });
  }

  void _prioritizedTasks() async {
    setState(() {
      loading = true;
    });
    await listOfTasks();
    setState(() {
      for (var instance in finalData) {
        if (instance["priority"] == "0") {
          instance["date_time"] = "not today";
        }
      }
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Tasks',
          style: TextStyle(
            color: Colors.teal,
            fontSize: 25,
          ),
        ),
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () {
              sharedPreference.clear();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LandingPage()),
                  (Route<dynamic> route) => false);
            },
            icon: Icon(
              Icons.people,
              color: Colors.teal,
            ),
            label: Text('Logout', style: TextStyle(color: Colors.teal)),
          ),
          FlatButton.icon(
            onPressed: () async {
              var result = await showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Container(
                        color: Colors.grey,
                        height: MediaQuery.of(context).size.height / 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Filter",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 25),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: 320.0,
                                height: 50,
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.pop(context, "Time");
                                  },
                                  child: Text(
                                    "Time Wise Sort",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width: 320.0,
                                height: 50,
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.pop(context, "Today");
                                  },
                                  child: Text(
                                    "Today\'s tasks",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width: 320.0,
                                height: 50,
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.pop(context, "Priority");
                                  },
                                  child: Text(
                                    "Prioritized tasks",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              SizedBox(
                                width: 320.0,
                                height: 50,
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.pop(context, "All");
                                  },
                                  child: Text(
                                    "All Tasks",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
              print(result);
              if (result == "Time") {
                _timeWiseSortedTask();
              }
              if (result == "Today") {
                _todaysTask();
              }
              if (result == "All") {
                _allTasks();
              }
              if (result == "Priority") {
                _prioritizedTasks();
              }
            },
            icon: Icon(
              Icons.filter_list,
              color: Colors.teal,
            ),
            label: Text('Sort', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
      body: loading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : finalData.isEmpty
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
                                            decoration:
                                                TextDecoration.lineThrough))
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

  Widget _onSortPressed() {
    print("hy");
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Filter",
                          style: TextStyle(color: Colors.teal, fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: 320.0,
                          child: RaisedButton(
                            onPressed: () {},
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
                );
              },
            ),
            backgroundColor: Colors.grey,
          );
        });
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
